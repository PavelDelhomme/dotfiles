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

# Activer le forwarding IP pour le NAT
if [ "$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null)" != "1" ]; then
    echo "Activation du forwarding IP pour le NAT..."
    echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf > /dev/null
    sudo sysctl -w net.ipv4.ip_forward=1
    echo "✓ Forwarding IP activé"
else
    echo "✓ Forwarding IP déjà activé"
fi

# Vérifier si le réseau default existe
if ! virsh net-list --all | grep -q "default"; then
    echo "Création du réseau par défaut (NAT)..."
    # Créer le réseau NAT par défaut
    sudo virsh net-define /usr/share/libvirt/networks/default.xml 2>/dev/null || \
    # Générer une adresse MAC aléatoire
    MAC_SUFFIX=$(od -An -N3 -tx1 /dev/urandom | sed 's/ /:/g' | cut -d: -f2-4)
    MAC_ADDRESS="52:54:00:$MAC_SUFFIX"
    
    cat <<EOF | sudo tee /tmp/default-network.xml > /dev/null
<network>
  <name>default</name>
  <uuid>$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid)</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='$MAC_ADDRESS'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
EOF
    sudo virsh net-define /tmp/default-network.xml
    sudo rm -f /tmp/default-network.xml
    echo "✓ Réseau par défaut créé"
fi

# Démarrer et activer le réseau
if ! virsh net-list | grep -q "default.*active"; then
    sudo virsh net-start default
    echo "✓ Réseau démarré"
else
    echo "✓ Réseau déjà actif"
fi

# Activer le démarrage automatique
sudo virsh net-autostart default
echo "✓ Réseau configuré avec NAT (accès Internet activé)"

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
