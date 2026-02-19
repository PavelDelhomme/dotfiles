#!/bin/zsh
# =============================================================================
# INSTALLATION PROTON MAIL - Module installman (Bridge ou client)
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/distro_detect.sh" ] && source "$INSTALLMAN_UTILS_DIR/distro_detect.sh"
[ -f "$INSTALLMAN_UTILS_DIR/package_manager.sh" ] && source "$INSTALLMAN_UTILS_DIR/package_manager.sh"

install_protonmail() {
    log_step "Installation de Proton Mail..."
    if command -v flatpak &>/dev/null; then
        flatpak install -y flathub ch.protonmail.protonmail-bridge 2>/dev/null || \
        flatpak install -y flathub com.protonmail.protonmail-bridge 2>/dev/null || {
            install_package "protonmail-bridge" "auto" 2>/dev/null || log_info "Installez depuis: https://proton.me/mail/bridge"
        }
    else
        install_package "protonmail-bridge" "auto" 2>/dev/null || log_info "Installez depuis: https://proton.me/mail/bridge ou Flatpak"
    fi
    log_info "✓ Proton Mail (Bridge) disponible"
    return 0
}
