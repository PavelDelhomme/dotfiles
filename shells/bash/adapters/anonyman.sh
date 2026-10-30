#!/usr/bin/env bash
# ANONYMAN adapter — charge le core POSIX (Bash)
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
_CORE="$DOTFILES_DIR/core/managers/anonyman/core/anonyman.sh"
if [ -f "$_CORE" ]; then
    # shellcheck source=/dev/null
    . "$_CORE"
else
    echo "anonyman core introuvable: $_CORE" >&2
    return 1 2>/dev/null || exit 1
fi
