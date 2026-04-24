#!/bin/sh
# Affiche les racines après bootstrap DOTFILES_GOOD (debug / dry-run humain).
# Usage : DOTFILES_DIR=/chemin/vers/dotfiles sh DOTFILES_GOOD/scripts/print_roots.sh

__here=$(CDPATH= cd "$(dirname "$0")" && pwd) || exit 1
__repo=$(CDPATH= cd "$__here/../.." && pwd) || exit 1
export DOTFILES_DIR="${DOTFILES_DIR:-$__repo}"
# shellcheck disable=SC1090
. "$__repo/DOTFILES_GOOD/lib/bootstrap_posix.sh" || exit 1
printf 'DOTFILES_DIR=%s\n' "$DOTFILES_DIR"
printf 'DOTFILES_GOOD_ROOT=%s\n' "$DOTFILES_GOOD_ROOT"
printf 'DOTFILES_GOOD_ENV_LOADED=%s\n' "${DOTFILES_GOOD_ENV_LOADED:-}"
