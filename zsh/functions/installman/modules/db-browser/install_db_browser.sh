#!/bin/zsh
# =============================================================================
# INSTALLATION DB BROWSER FOR SQLITE - Module installman
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/package_manager.sh" ] && source "$INSTALLMAN_UTILS_DIR/package_manager.sh"

install_db_browser() {
    log_step "Installation de DB Browser for SQLite..."
    if command -v flatpak &>/dev/null; then
        flatpak install -y flathub org.sqlitebrowser.sqlitebrowser 2>/dev/null && { log_info "✓ DB Browser installé (Flatpak)"; return 0; }
    fi
    install_package "sqlitebrowser" "auto" || install_package "db-browser-for-sqlite" "auto" || {
        log_warn "Installez depuis Flathub: org.sqlitebrowser.sqlitebrowser"
        return 1
    }
    log_info "✓ DB Browser for SQLite installé"
    return 0
}
