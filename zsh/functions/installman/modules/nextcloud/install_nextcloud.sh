#!/bin/zsh
# =============================================================================
# INSTALLATION NEXTCLOUD CLIENT (sync) - Module installman
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/distro_detect.sh" ] && source "$INSTALLMAN_UTILS_DIR/distro_detect.sh"
[ -f "$INSTALLMAN_UTILS_DIR/package_manager.sh" ] && source "$INSTALLMAN_UTILS_DIR/package_manager.sh"

install_nextcloud() {
    log_step "Installation du client Nextcloud (synchronisation)..."
    if command -v flatpak &>/dev/null; then
        flatpak install -y flathub com.nextcloud.desktopclient.nextcloud 2>/dev/null && { log_info "✓ Nextcloud installé (Flatpak)"; return 0; }
    fi
    local distro=$(detect_distro)
    case "$distro" in
        arch) install_package "nextcloud-client" "auto" ;;
        debian) sudo apt-get update && sudo apt-get install -y nextcloud-client ;;
        fedora) sudo dnf install -y nextcloud-client ;;
        *) install_package "nextcloud-client" "auto" 2>/dev/null || log_warn "Installez depuis Flathub: com.nextcloud.desktopclient.nextcloud" ;;
    esac
    log_info "✓ Nextcloud client installé"
    return 0
}
