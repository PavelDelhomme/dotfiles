#!/bin/bash

################################################################################
# Configuration libvirt - Unitaire
# Configure les permissions et groupes libvirt
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

log_section "Configuration libvirt"

# Vérifier que libvirt est installé
if ! command -v virsh >/dev/null 2>&1; then
    log_error "libvirt n'est pas installé!"
    echo "Installez d'abord: sudo pacman -S libvirt"
    exit 1
fi

# 1. Démarrer libvirtd
if ! systemctl is-active --quiet libvirtd; then
    log_info "Démarrage de libvirtd..."
    sudo systemctl enable --now libvirtd
    log_info "✓ libvirtd démarré et activé"
else
    log_info "✓ libvirtd déjà actif"
fi

# 2. Configurer permissions libvirt
if ! grep -q "^unix_sock_group = \"libvirt\"" /etc/libvirt/libvirtd.conf 2>/dev/null; then
    log_info "Configuration des permissions libvirt..."
    sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
    sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf
    log_info "✓ Configuration libvirt modifiée"
    
    # Redémarrer libvirtd
    sudo systemctl restart libvirtd
    log_info "✓ libvirtd redémarré"
else
    log_info "✓ Permissions libvirt déjà configurées"
fi

# 3. Ajouter utilisateur au groupe libvirt
if ! groups | grep -q libvirt; then
    log_info "Ajout de l'utilisateur au groupe libvirt..."
    sudo usermod -aG libvirt $(whoami)
    log_warn "⚠ DÉCONNECTEZ-VOUS et RECONNECTEZ-VOUS pour que le groupe soit actif"
    log_warn "   Ou redémarrez: sudo reboot"
else
    log_info "✓ Utilisateur déjà dans le groupe libvirt"
fi

log_section "Configuration libvirt terminée!"
log_info "Vérifiez avec: groups | grep libvirt"

