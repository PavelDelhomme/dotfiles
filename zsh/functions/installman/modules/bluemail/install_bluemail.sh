#!/bin/zsh
# =============================================================================
# INSTALLATION BLUEMAIL - Module installman
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/package_manager.sh" ] && source "$INSTALLMAN_UTILS_DIR/package_manager.sh"

install_bluemail() {
    log_step "Installation de BlueMail..."
    if command -v flatpak &>/dev/null; then
        flatpak install -y flathub com.bluemailapp.BlueMail 2>/dev/null || \
        flatpak install -y flathub me.bluemailclient.BlueMail 2>/dev/null || {
            log_info "Recherche BlueMail sur Flathub..."
            install_package "bluemail" "auto" 2>/dev/null || log_warn "Installez BlueMail depuis Flathub ou le site officiel"
        }
    else
        install_package "bluemail" "auto" 2>/dev/null || log_warn "Installez Flatpak puis: flatpak install flathub com.bluemailapp.BlueMail"
    fi
    log_info "✓ BlueMail installé ou instructions affichées"
    return 0
}
