#!/bin/zsh
# =============================================================================
# INSTALLATION WINE - Module installman
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/distro_detect.sh" ] && source "$INSTALLMAN_UTILS_DIR/distro_detect.sh"
[ -f "$INSTALLMAN_UTILS_DIR/package_manager.sh" ] && source "$INSTALLMAN_UTILS_DIR/package_manager.sh"

install_wine() {
    log_step "Installation de Wine..."
    local distro=$(detect_distro)
    case "$distro" in
        arch)
            install_package "wine" "auto" || install_package "wine-staging" "auto"
            ;;
        debian)
            sudo apt-get update && sudo apt-get install -y wine64 wine32 || sudo apt-get install -y wine
            ;;
        fedora)
            sudo dnf install -y wine
            ;;
        *)
            log_error "Distribution non supportée. Installez Wine manuellement."
            return 1
            ;;
    esac
    log_info "✓ Wine installé"
    return 0
}
