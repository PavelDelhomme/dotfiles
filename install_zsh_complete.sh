#!/bin/sh
# Wrapper de compatibilite — logique dans scripts/install/install_zsh_complete.sh
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
exec bash "$DOTFILES_DIR/scripts/install/install_zsh_complete.sh" "$@"
