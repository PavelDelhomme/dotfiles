#!/bin/zsh
# =============================================================================
# INSTALLATION QEMU/KVM - Module installman
# =============================================================================
# Description: Installation complète de QEMU/KVM pour virtualisation
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger les utilitaires
INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"

# Charger les fonctions utilitaires
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/distro_detect.sh" ] && source "$INSTALLMAN_UTILS_DIR/distro_detect.sh"

# Chemins
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"
INSTALL_SCRIPT="$SCRIPTS_DIR/install/tools/install_qemu_full.sh"

# =============================================================================
# INSTALLATION QEMU/KVM
# =============================================================================
# DESC: Installe QEMU/KVM et libvirt pour virtualisation
# USAGE: install_qemu
# EXAMPLE: install_qemu
install_qemu() {
    log_step "Installation de QEMU/KVM et libvirt..."
    
    # Vérifier si déjà installé
    if command -v qemu-system-x86_64 &>/dev/null && command -v virsh &>/dev/null; then
        log_info "QEMU/KVM est déjà installé"
        read -p "Réinstaller? (o/N): " reinstall
        if [[ ! "$reinstall" =~ ^[oO]$ ]]; then
            return 0
        fi
    fi
    
    if [ -f "$INSTALL_SCRIPT" ]; then
        bash "$INSTALL_SCRIPT" || {
            log_error "Échec de l'installation de QEMU/KVM"
            return 1
        }
    else
        log_error "Script d'installation QEMU/KVM introuvable: $INSTALL_SCRIPT"
        return 1
    fi
    
    log_info "✓ QEMU/KVM installé avec succès!"
    log_info "💡 Utilisez 'configman qemu-packages' pour configurer les permissions"
    return 0
}

