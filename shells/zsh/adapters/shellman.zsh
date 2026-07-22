#!/bin/zsh
# SHELLMAN adapter — ZSH
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
_CORE="$DOTFILES_DIR/core/managers/shellman/core/shellman.sh"
if [ -f "$_CORE" ]; then
    # shellcheck source=/dev/null
    source "$_CORE"
else
    echo "shellman core introuvable: $_CORE" >&2
    return 1
fi
