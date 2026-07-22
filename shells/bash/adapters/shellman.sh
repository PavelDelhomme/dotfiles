#!/usr/bin/env bash
# SHELLMAN adapter — Bash
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
_CORE="$DOTFILES_DIR/core/managers/shellman/core/shellman.sh"
if [ -f "$_CORE" ]; then
    # shellcheck source=/dev/null
    . "$_CORE"
else
    echo "shellman core introuvable: $_CORE" >&2
    return 1 2>/dev/null || exit 1
fi
