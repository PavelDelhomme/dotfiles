#!/bin/bash

################################################################################
# Configuration libvirt - Unitaire
# Configure les permissions et groupes libvirt
################################################################################

set +e  # Désactivé pour éviter fermeture terminal si sourcé

# Charger la bibliothèque commune
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
if [ -f "$DOTFILES_DIR/scripts/lib/common.sh" ]; then
    source "$DOTFILES_DIR/scripts/lib/common.sh"
else
    echo "Erreur: Impossible de charger la bibliothèque commune: $DOTFILES_DIR/scripts/lib/common.sh"
    return 1 2>/dev/null || exit 1
fi

log_section "Configuration libvirt"

# Vérifier que libvirt est installé
if ! command -v virsh >/dev/null 2>&1; then
    log_error "libvirt n'est pas installé!"
    echo "Installez d'abord: sudo pacman -S libvirt"
    return 1 2>/dev/null || exit 1
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
