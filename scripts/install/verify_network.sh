#!/bin/bash

################################################################################
# Script de vérification de la configuration réseau QEMU/KVM
# Vérifie que le réseau est bien configuré pour l'accès Internet
################################################################################

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

log_section "Vérification configuration réseau QEMU/KVM"

# 1. Vérifier forwarding IP
echo ""
echo "1. Forwarding IP (NAT):"
if [ "$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null)" = "1" ]; then
    log_info "Forwarding IP activé"
else
    log_error "Forwarding IP désactivé"
    echo "  Activez avec: sudo sysctl -w net.ipv4.ip_forward=1"
fi

# 2. Vérifier réseau libvirt
echo ""
echo "2. Réseau libvirt 'default':"
if virsh net-list --all 2>/dev/null | grep -q "default"; then
    log_info "Réseau 'default' existe"
    
    # Vérifier s'il est actif
    if virsh net-list 2>/dev/null | grep -q "default.*active"; then
        log_info "Réseau 'default' est actif"
        
        # Afficher les infos du réseau
        echo ""
        echo "  Informations du réseau:"
        virsh net-info default 2>/dev/null | grep -E "(Name|UUID|Active|Persistent|Autostart|Bridge)" || true
    else
        log_warn "Réseau 'default' existe mais n'est pas actif"
        echo "  Activez avec: sudo virsh net-start default"
    fi
    
    # Vérifier autostart
    if virsh net-list --all 2>/dev/null | grep "default" | grep -q "yes"; then
        log_info "Démarrage automatique activé"
    else
        log_warn "Démarrage automatique non activé"
        echo "  Activez avec: sudo virsh net-autostart default"
    fi
else
    log_error "Réseau 'default' n'existe pas"
    echo "  Créez-le avec le script d'installation QEMU"
fi

# 3. Vérifier bridge virtuel
echo ""
echo "3. Bridge virtuel (virbr0):"
if ip link show virbr0 >/dev/null 2>&1; then
    log_info "Bridge virbr0 existe"
    echo "  État: $(ip link show virbr0 | grep -oP 'state \K[^ ]+' || echo 'inconnu')"
else
    log_warn "Bridge virbr0 n'existe pas (normal si réseau non démarré)"
fi

# 4. Vérifier dnsmasq
echo ""
echo "4. Service dnsmasq (DHCP pour VMs):"
if systemctl is-active --quiet dnsmasq 2>/dev/null || pgrep -x dnsmasq >/dev/null 2>&1; then
    log_info "dnsmasq est actif"
else
    log_warn "dnsmasq n'est pas actif (sera démarré automatiquement par libvirt)"
fi

# 5. Vérifier iptables/firewall
echo ""
echo "5. Règles NAT (iptables):"
if sudo iptables -t nat -L -n 2>/dev/null | grep -q "192.168.122"; then
    log_info "Règles NAT configurées pour 192.168.122.0/24"
else
    log_warn "Règles NAT non détectées (seront créées automatiquement par libvirt)"
fi

# Résumé
echo ""
log_section "Résumé"

ALL_OK=true

if [ "$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null)" != "1" ]; then
    ALL_OK=false
fi

if ! virsh net-list 2>/dev/null | grep -q "default.*active"; then
    ALL_OK=false
fi

if [ "$ALL_OK" = true ]; then
    log_info "✓ Configuration réseau OK - Les VMs auront accès Internet"
    echo ""
    echo "Pour tester dans une VM:"
    echo "  1. Créez une VM avec virt-manager"
    echo "  2. Utilisez le réseau 'default' (par défaut)"
    echo "  3. Dans la VM: ping 8.8.8.8"
else
    log_warn "⚠ Configuration incomplète - Vérifiez les points ci-dessus"
    echo ""
    echo "Pour corriger:"
    echo "  bash ~/dotfiles/scripts/install/install_qemu_simple.sh"
fi

echo ""
