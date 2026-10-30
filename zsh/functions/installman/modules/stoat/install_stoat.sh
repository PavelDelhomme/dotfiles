#!/bin/zsh
# =============================================================================
# INSTALLATION STOAT (ex-Revolt) — AppImage GitHub releases
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
UPDATE_SCRIPT="${DOTFILES_DIR}/scripts/update/update-stoat-appimage.sh"

# DESC: Installe Stoat Desktop (AppImage) depuis GitHub
# USAGE: install_stoat
install_stoat() {
    log_step "Installation de Stoat (AppImage)…"

    if [ ! -f "$UPDATE_SCRIPT" ]; then
        log_error "Script introuvable: $UPDATE_SCRIPT"
        return 1
    fi
    chmod +x "$UPDATE_SCRIPT" 2>/dev/null || true

    bash "$UPDATE_SCRIPT" update || {
        log_error "Échec update-stoat-appimage"
        return 1
    }

    if command -v updateman &>/dev/null; then
        updateman stoat enable 2>/dev/null || true
    elif [ -f "$DOTFILES_DIR/core/managers/updateman/core/updateman.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/core/managers/updateman/core/updateman.sh"
        updateman stoat enable 2>/dev/null || true
    fi

    log_info "✓ Stoat prêt — lance: stoat  |  màj: updateman stoat"
    return 0
}
