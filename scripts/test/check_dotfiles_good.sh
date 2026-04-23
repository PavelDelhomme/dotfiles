#!/usr/bin/env bash
# Smoke du bac à sable DOTFILES_GOOD (additif, sans modifier l'install courante).
set -euo pipefail
ROOT="${DOTFILES_DIR:-$HOME/dotfiles}"
cd "$ROOT"
export DOTFILES_DIR="$ROOT"

echo "→ sh -n DOTFILES_GOOD/lib/bootstrap_posix.sh"
sh -n DOTFILES_GOOD/lib/bootstrap_posix.sh
echo "→ sh -n DOTFILES_GOOD/shared/env/00_paths.sh"
sh -n DOTFILES_GOOD/shared/env/00_paths.sh

echo "→ sourcing bootstrap dans un sous-shell (DOTFILES_DIR=$ROOT)"
(
	set -e
	export DOTFILES_DIR="$ROOT"
	# shellcheck disable=SC1091
	. ./DOTFILES_GOOD/lib/bootstrap_posix.sh
	[ -n "${DOTFILES_GOOD_ROOT:-}" ] || exit 1
	[ -n "${DOTFILES_DIR:-}" ] || exit 1
	[ "${DOTFILES_GOOD_ENV_LOADED:-}" = 1 ] || exit 1
)
echo "✅ DOTFILES_GOOD : OK"
