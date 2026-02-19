#!/bin/zsh
# =============================================================================
# INSTALLATION PORTPROTON - Module installman (version native)
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"

install_portproton() {
    log_step "Installation de PortProton (native)..."
    local script="$DOTFILES_DIR/scripts/install/apps/install_portproton_native.sh"
    if [ -f "$script" ]; then
        bash "$script" || { log_error "Échec installation PortProton"; return 1; }
    else
        log_error "Script introuvable: $script"
        return 1
    fi
    log_info "✓ PortProton installé"
    return 0
}
