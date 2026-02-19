#!/bin/zsh
# =============================================================================
# INSTALLATION SNAP (snapd) - Module installman
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
[ -f "$INSTALLMAN_DIR/utils/logger.sh" ] && source "$INSTALLMAN_DIR/utils/logger.sh"

install_snap() {
    log_step "Installation de Snap (snapd)..."
    local script="$DOTFILES_DIR/scripts/install/system/package_managers.sh"
    if [ -f "$script" ]; then
        bash "$script" || {
            if command -v pacman &>/dev/null; then
                sudo pacman -S --noconfirm snapd
                sudo systemctl enable --now snapd.socket
                sudo ln -sf /var/lib/snapd/snap /snap 2>/dev/null || true
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y snapd
                sudo systemctl enable --now snapd.socket
            elif command -v apt-get &>/dev/null; then
                sudo apt-get update && sudo apt-get install -y snapd
            fi
        }
    else
        command -v pacman &>/dev/null && sudo pacman -S --noconfirm snapd && sudo systemctl enable --now snapd.socket
    fi
    log_info "✓ Snap (snapd) installé. Redémarrez la session si besoin pour 'snap'."
    return 0
}
