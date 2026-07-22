#!/bin/sh
# Wrapper de compatibilite — logique dans scripts/test/test_docker.sh
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
exec bash "$DOTFILES_DIR/scripts/test/test_docker.sh" "$@"
