#!/bin/zsh
# =============================================================================
# INSTALLATION GOOGLE CHROME - Module installman
# =============================================================================
# Description: Installation de Google Chrome (navigateur officiel)
# Source: https://www.google.com/chrome/
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/distro_detect.sh" ] && source "$INSTALLMAN_UTILS_DIR/distro_detect.sh"

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"
INSTALL_SCRIPT="$SCRIPTS_DIR/install/apps/install_chrome.sh"

# DESC: Installe Google Chrome
# USAGE: install_chrome
install_chrome() {
    log_step "Installation de Google Chrome..."
    [ -f "$INSTALLMAN_DIR/utils/check_installed.sh" ] && source "$INSTALLMAN_DIR/utils/check_installed.sh"
    if [ "$(check_chrome_installed 2>/dev/null)" = "installed" ]; then
        log_info "Google Chrome est déjà installé"
        return 0
    fi
    if [ -f "$INSTALL_SCRIPT" ]; then
        bash "$INSTALL_SCRIPT" || { log_error "Échec de l'installation de Google Chrome"; return 1; }
    else
        log_error "Script introuvable: $INSTALL_SCRIPT"
        return 1
    fi
    log_info "✓ Google Chrome installé!"
    return 0
}
