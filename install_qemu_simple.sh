#!/bin/bash

################################################################################
# Installation QEMU/KVM/virt-manager pour Manjaro - Conflit résolu
################################################################################

set -e

echo "════════════════════════════════════════════════"
echo "Installation QEMU/KVM/virt-manager"
echo "════════════════════════════════════════════════"
echo ""

# Vérifier support virtualisation
echo "[1/7] Vérification support virtualisation..."
if grep -E '(vmx|svm)' /proc/cpuinfo >/dev/null 2>&1; then
    echo "✓ Support virtualisation détecté"
else
    echo "✗ ERREUR: Pas de support virtualisation!"
    echo "Activez Intel VT-x ou AMD-V dans le BIOS"
    exit 1
fi

# RÉSOUDRE CONFLIT IPTABLES
echo ""
echo "[2/7] Résolution conflit iptables..."
if pacman -Q iptables >/dev/null 2>&1; then
    echo "Suppression de iptables (ancien)..."
    sudo pacman -Rdd --noconfirm iptables 2>/dev/null || true
    echo "Installation de iptables-nft..."
    sudo pacman -S --noconfirm iptables-nft
    echo "✓ Conflit résolu"
else
    echo "✓ Pas de conflit"
fi

# Installer les paquets
echo ""
echo "[3/7] Installation des paquets QEMU/KVM..."
sudo pacman -S --needed --noconfirm \
    qemu-desktop \
    libvirt \
    virt-manager \
    virt-viewer \
    dnsmasq \
    bridge-utils \
    openbsd-netcat \
    ebtables

echo "✓ Paquets installés"

# Démarrer libvirtd
echo ""
echo "[4/7] Démarrage de libvirtd..."
sudo systemctl enable --now libvirtd
echo "✓ libvirtd démarré"

# Ajouter utilisateur au groupe
echo ""
echo "[5/7] Ajout au groupe libvirt..."
sudo usermod -aG libvirt $(whoami)
echo "✓ Utilisateur ajouté au groupe libvirt"

# Configurer réseau par défaut
echo ""
echo "[6/7] Configuration réseau..."
sleep 2
sudo virsh net-start default 2>/dev/null || echo "Réseau déjà démarré"
sudo virsh net-autostart default
echo "✓ Réseau configuré"

# Créer dossiers et scripts
echo ""
echo "[7/7] Création dossiers et scripts helper..."
mkdir -p ~/VMs
mkdir -p ~/ISOs
mkdir -p ~/.local/bin

# Scripts snapshots
cat > ~/.local/bin/vm-snapshot << 'SNAPEOF'
#!/bin/bash
if [ $# -lt 2 ]; then
    echo "Usage: vm-snapshot <vm> <name> [desc]"
    exit 1
fi
virsh snapshot-create-as "$1" "$2" --description "${3:-Snapshot $(date)}"
echo "✓ Snapshot '$2' créé pour $1"
SNAPEOF

cat > ~/.local/bin/vm-snapshot-list << 'LISTEOF'
#!/bin/bash
[ $# -lt 1 ] && echo "Usage: vm-snapshot-list <vm>" && exit 1
virsh snapshot-list "$1"
LISTEOF

cat > ~/.local/bin/vm-snapshot-restore << 'RESTEOF'
#!/bin/bash
[ $# -lt 2 ] && echo "Usage: vm-snapshot-restore <vm> <name>" && exit 1
virsh snapshot-revert "$1" "$2"
echo "✓ VM $1 restaurée au snapshot $2"
RESTEOF

cat > ~/.local/bin/vm-snapshot-delete << 'DELEOF'
#!/bin/bash
[ $# -lt 2 ] && echo "Usage: vm-snapshot-delete <vm> <name>" && exit 1
virsh snapshot-delete "$1" "$2"
echo "✓ Snapshot $2 supprimé"
DELEOF

chmod +x ~/.local/bin/vm-snapshot*

echo "✓ Dossiers et scripts créés"

echo ""
echo "════════════════════════════════════════════════"
echo "✓ Installation TERMINÉE!"
echo "════════════════════════════════════════════════"
echo ""
echo "⚠ IMPORTANT:"
echo "  1. DÉCONNECTEZ-VOUS et RECONNECTEZ-VOUS"
echo "     (ou redémarrez pour groupe libvirt actif)"
echo ""
echo "  2. Après reconnexion, vérifiez:"
echo "     groups | grep libvirt"
echo ""
echo "  3. Lancez virt-manager:"
echo "     virt-manager"
echo ""
echo "Scripts disponibles:"
echo "  vm-snapshot <vm> <name> [desc]"
echo "  vm-snapshot-list <vm>"
echo "  vm-snapshot-restore <vm> <name>"
echo "  vm-snapshot-delete <vm> <name>"
echo ""
