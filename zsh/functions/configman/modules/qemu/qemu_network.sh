#!/bin/bash

################################################################################
# Configuration réseau QEMU/KVM - Unitaire
# Configure uniquement le réseau NAT pour les VMs
################################################################################

set +e  # Désactivé pour éviter fermeture terminal si sourcé

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    return 1 2>/dev/null || exit 1
}

log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

log_section "Configuration réseau QEMU/KVM"

# Vérifier que libvirt est installé
if ! command -v virsh >/dev/null 2>&1; then
    log_error "libvirt n'est pas installé!"
    echo "Installez d'abord: sudo pacman -S libvirt"
    return 1 2>/dev/null || exit 1
fi

# 1. Activer forwarding IP
if [ "$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null)" != "1" ]; then
    log_info "Activation du forwarding IP pour le NAT..."
    echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf > /dev/null
    sudo sysctl -w net.ipv4.ip_forward=1
    log_info "✓ Forwarding IP activé"
else
    log_info "✓ Forwarding IP déjà activé"
fi

# 2. Créer réseau default si inexistant
if ! virsh net-list --all 2>/dev/null | grep -q "default"; then
    log_info "Création du réseau par défaut (NAT)..."
    
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
    log_info "✓ Réseau par défaut créé"
else
    log_info "✓ Réseau 'default' existe déjà"
fi

# 3. Démarrer le réseau
if ! virsh net-list 2>/dev/null | grep -q "default.*active"; then
    log_info "Démarrage du réseau..."
    sudo virsh net-start default
    log_info "✓ Réseau démarré"
else
    log_info "✓ Réseau déjà actif"
fi

# 4. Activer démarrage automatique
sudo virsh net-autostart default
log_info "✓ Démarrage automatique activé"

log_section "Configuration réseau terminée!"
log_info "Les VMs auront maintenant accès Internet via NAT (192.168.122.0/24)"
