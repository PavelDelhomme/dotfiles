#!/bin/zsh
INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
[ -f "$INSTALLMAN_DIR/utils/logger.sh" ] && source "$INSTALLMAN_DIR/utils/logger.sh"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

install_noita() {
    log_step "Installation Noita…"
    bash "$DOTFILES_DIR/scripts/install/games/install_noita.sh"
}
