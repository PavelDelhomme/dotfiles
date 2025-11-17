#!/bin/bash

################################################################################
# Installation QEMU/KVM avec virt-manager et gestion de snapshots
# Pour Manjaro Linux
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

################################################################################
# VÉRIFICATION DES PRÉREQUIS
################################################################################
log_section "Vérification des prérequis"

# Vérifier support virtualisation CPU
log_info "Vérification du support de virtualisation..."
if grep -E '(vmx|svm)' /proc/cpuinfo >/dev/null 2>&1; then
    log_info "✓ Support virtualisation matérielle détecté"
    lscpu | grep Virtualization
else
    log_error "Pas de support virtualisation matérielle!"
    log_error "Activez Intel VT-x ou AMD-V dans le BIOS"
    exit 1
fi

################################################################################
# INSTALLATION DES PAQUETS
################################################################################
log_section "Installation QEMU/KVM et virt-manager"

# Vérifier si déjà installé
if command -v virt-manager >/dev/null 2>&1 && command -v qemu-system-x86_64 >/dev/null 2>&1; then
    log_info "✓ QEMU/KVM et virt-manager déjà installés"
else
    log_info "Installation des paquets..."
    sudo pacman -S --noconfirm \
        qemu-desktop \
        libvirt \
        virt-manager \
        virt-viewer \
        dnsmasq \
        bridge-utils \
        openbsd-netcat \
        ebtables \
        iptables-nft \
        libguestfs \
        edk2-ovmf \
        swtpm

    log_info "✓ Paquets installés"
fi

################################################################################
# CONFIGURATION LIBVIRT
################################################################################
log_section "Configuration libvirt"

# Démarrer et activer le service
if ! systemctl is-active --quiet libvirtd; then
    log_info "Démarrage de libvirtd..."
    sudo systemctl enable --now libvirtd
    log_info "✓ libvirtd démarré et activé"
else
    log_info "✓ libvirtd déjà actif"
fi

# Modifier la configuration libvirt pour permettre les permissions
log_info "Configuration des permissions libvirt..."

if ! grep -q "^unix_sock_group = \"libvirt\"" /etc/libvirt/libvirtd.conf; then
    sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
    sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf
    log_info "✓ Configuration libvirt modifiée"

    # Redémarrer libvirtd
    sudo systemctl restart libvirtd
    log_info "✓ libvirtd redémarré"
else
    log_info "✓ Configuration libvirt déjà faite"
fi

# Ajouter l'utilisateur au groupe libvirt
if ! groups | grep -q libvirt; then
    log_info "Ajout de l'utilisateur au groupe libvirt..."
    sudo usermod -aG libvirt \$(whoami)
    log_warn "Vous devez vous déconnecter/reconnecter pour que le groupe soit actif"
else
    log_info "✓ Utilisateur déjà dans le groupe libvirt"
fi

################################################################################
# CONFIGURATION RÉSEAU PAR DÉFAUT
################################################################################
log_section "Configuration réseau"

# Activer et démarrer le réseau par défaut
if ! virsh net-list --all | grep -q "default.*active"; then
    log_info "Activation du réseau par défaut..."
    sudo virsh net-start default 2>/dev/null || true
    sudo virsh net-autostart default
    log_info "✓ Réseau par défaut activé"
else
    log_info "✓ Réseau par défaut déjà actif"
fi

################################################################################
# CRÉATION DOSSIERS DE STOCKAGE
################################################################################
log_section "Configuration stockage"

# Créer dossiers pour VMs et ISOs
VM_DIR="$HOME/VMs"
ISO_DIR="$HOME/ISOs"

mkdir -p "\$VM_DIR"
mkdir -p "\$ISO_DIR"

log_info "✓ Dossiers créés:"
log_info "  - VMs: \$VM_DIR"
log_info "  - ISOs: \$ISO_DIR"

# Créer pool de stockage pour ISOs si pas déjà fait
if ! virsh pool-list --all | grep -q "ISO"; then
    log_info "Création du pool de stockage pour ISOs..."

    cat > /tmp/iso-pool.xml <<EOF
<pool type='dir'>
  <name>ISO</name>
  <target>
    <path>\$ISO_DIR</path>
  </target>
</pool>
EOF

    sudo virsh pool-define /tmp/iso-pool.xml
    sudo virsh pool-start ISO
    sudo virsh pool-autostart ISO
    rm /tmp/iso-pool.xml

    log_info "✓ Pool ISO créé et activé"
else
    log_info "✓ Pool ISO déjà existant"
fi

################################################################################
# SCRIPT HELPER POUR SNAPSHOTS
################################################################################
log_section "Création des scripts helper"

mkdir -p ~/.local/bin

# Script pour créer un snapshot
cat > ~/.local/bin/vm-snapshot <<'SNAPSCRIPT'
#!/bin/bash
# Créer un snapshot d'une VM

if [ \$# -lt 2 ]; then
    echo "Usage: vm-snapshot <vm-name> <snapshot-name> [description]"
    exit 1
fi

VM_NAME="\$1"
SNAPSHOT_NAME="\$2"
DESCRIPTION="\${3:-Snapshot created on \$(date)}"

virsh snapshot-create-as "\$VM_NAME" "\$SNAPSHOT_NAME" --description "\$DESCRIPTION"
echo "✓ Snapshot '\$SNAPSHOT_NAME' créé pour \$VM_NAME"
SNAPSCRIPT

# Script pour lister les snapshots
cat > ~/.local/bin/vm-snapshot-list <<'LISTSCRIPT'
#!/bin/bash
# Lister les snapshots d'une VM

if [ \$# -lt 1 ]; then
    echo "Usage: vm-snapshot-list <vm-name>"
    exit 1
fi

VM_NAME="\$1"
virsh snapshot-list "\$VM_NAME"
LISTSCRIPT

# Script pour restaurer un snapshot
cat > ~/.local/bin/vm-snapshot-restore <<'RESTORESCRIPT'
#!/bin/bash
# Restaurer un snapshot

if [ \$# -lt 2 ]; then
    echo "Usage: vm-snapshot-restore <vm-name> <snapshot-name>"
    exit 1
fi

VM_NAME="\$1"
SNAPSHOT_NAME="\$2"

virsh snapshot-revert "\$VM_NAME" "\$SNAPSHOT_NAME"
echo "✓ VM \$VM_NAME restaurée au snapshot \$SNAPSHOT_NAME"
RESTORESCRIPT

# Script pour supprimer un snapshot
cat > ~/.local/bin/vm-snapshot-delete <<'DELETESCRIPT'
#!/bin/bash
# Supprimer un snapshot

if [ \$# -lt 2 ]; then
    echo "Usage: vm-snapshot-delete <vm-name> <snapshot-name>"
    exit 1
fi

VM_NAME="\$1"
SNAPSHOT_NAME="\$2"

virsh snapshot-delete "\$VM_NAME" "\$SNAPSHOT_NAME"
echo "✓ Snapshot \$SNAPSHOT_NAME supprimé de \$VM_NAME"
DELETESCRIPT

# Rendre les scripts exécutables
chmod +x ~/.local/bin/vm-snapshot*

log_info "✓ Scripts helper créés:"
log_info "  - vm-snapshot <vm> <name> [desc]"
log_info "  - vm-snapshot-list <vm>"
log_info "  - vm-snapshot-restore <vm> <name>"
log_info "  - vm-snapshot-delete <vm> <name>"

################################################################################
# GUIDE RAPIDE
################################################################################
log_section "Installation terminée!"

cat <<EOF

${GREEN}✓ QEMU/KVM et virt-manager installés et configurés${NC}

${YELLOW}ACTIONS REQUISES:${NC}
  1. Déconnectez-vous et reconnectez-vous (groupe libvirt)
  2. Lancez virt-manager pour créer des VMs

${BLUE}EMPLACEMENTS:${NC}
  - Dossier VMs: \$VM_DIR
  - Dossier ISOs: \$ISO_DIR

${BLUE}COMMANDES UTILES:${NC}

Gestion VMs:
  virsh list --all                    # Lister toutes les VMs
  virsh start <vm-name>               # Démarrer une VM
  virsh shutdown <vm-name>            # Arrêter une VM
  virsh destroy <vm-name>             # Forcer l'arrêt d'une VM

Snapshots (via scripts helper):
  vm-snapshot <vm> <name> [desc]      # Créer snapshot
  vm-snapshot-list <vm>               # Lister snapshots
  vm-snapshot-restore <vm> <name>     # Restaurer snapshot
  vm-snapshot-delete <vm> <name>      # Supprimer snapshot

Snapshots (via virsh):
  virsh snapshot-create-as <vm> <name> --description "desc"
  virsh snapshot-list <vm>
  virsh snapshot-revert <vm> <name>
  virsh snapshot-delete <vm> <name>
  virsh snapshot-info <vm> <name>

Gestion réseau:
  virsh net-list --all                # Lister réseaux
  virsh net-start default             # Démarrer réseau
  virsh net-autostart default         # Auto-démarrer réseau

${BLUE}CRÉER UNE VM MANJARO DE TEST:${NC}
  1. Téléchargez l'ISO Manjaro dans \$ISO_DIR
  2. Lancez: virt-manager
  3. Cliquez sur '+' pour créer une nouvelle VM
  4. Sélectionnez l'ISO Manjaro
  5. Configurez: 2-4 Go RAM, 20+ Go disque
  6. Une fois installée, créez des snapshots régulièrement!

${BLUE}EXEMPLE WORKFLOW SNAPSHOTS:${NC}
  # Créer snapshot avant test
  vm-snapshot manjaro-test "clean-install" "Installation propre"

  # Tester des modifications...

  # Si problème, restaurer
  vm-snapshot-restore manjaro-test "clean-install"

${YELLOW}Note:${NC} Les snapshots sont stockés dans l'image QCOW2 de la VM
      Utilisez le format QCOW2 pour bénéficier des snapshots!

EOF
