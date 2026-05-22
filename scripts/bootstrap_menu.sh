#!/usr/bin/env sh
# =============================================================================
# Menu bootstrap — même chemin que bootstrap.sh après clone
# =============================================================================
# bootstrap.sh appelle scripts/setup.sh ; ce script expose le même point
# d'entrée pour make, docs et scripts legacy qui voulaient "un menu install".
# =============================================================================

set -eu

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
_SETUP="${DOTFILES_DIR}/scripts/setup.sh"

if [ ! -f "$_SETUP" ]; then
    printf 'Erreur: setup introuvable: %s\n' "$_SETUP" >&2
    printf 'Clonez les dotfiles ou definissez DOTFILES_DIR.\n' >&2
    exit 1
fi

exec sh "$_SETUP" "$@"
