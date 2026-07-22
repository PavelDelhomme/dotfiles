#!/bin/zsh
# ANONYMAN adapter — charge le core POSIX (ZSH)
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
_CORE="$DOTFILES_DIR/core/managers/anonyman/core/anonyman.sh"
if [ -f "$_CORE" ]; then
    # shellcheck source=/dev/null
    source "$_CORE"
else
    echo "anonyman core introuvable: $_CORE" >&2
    return 1
fi
