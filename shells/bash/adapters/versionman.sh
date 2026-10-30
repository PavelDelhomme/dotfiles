#!/usr/bin/env bash
# Adapter Bash — versionman
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
_core="$DOTFILES_DIR/core/managers/versionman/core/versionman.sh"
if [ -f "$_core" ]; then
    # shellcheck source=/dev/null
    . "$_core"
    alias vm='versionman'
    alias versions='versionman'
else
    echo "versionman core introuvable: $_core" >&2
    unset _core
    return 1 2>/dev/null || exit 1
fi
unset _core
