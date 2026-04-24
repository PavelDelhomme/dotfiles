#!/usr/bin/env bash
# Smoke du bac à sable DOTFILES_GOOD (additif, sans modifier l'install courante).
set -euo pipefail
ROOT="${DOTFILES_DIR:-$HOME/dotfiles}"
cd "$ROOT"
export DOTFILES_DIR="$ROOT"

echo "→ sh -n sur les *.sh sous DOTFILES_GOOD/"
while IFS= read -r __sh; do
	echo "   sh -n $__sh"
	sh -n "$__sh" || exit 1
done < <(find DOTFILES_GOOD -type f -name '*.sh' ! -path '*/snippets/*' | sort)

echo "→ répertoires attendus"
for __d in DOTFILES_GOOD/lib DOTFILES_GOOD/shared/env DOTFILES_GOOD/shared/functions \
	DOTFILES_GOOD/shared/menus DOTFILES_GOOD/snippets DOTFILES_GOOD/core DOTFILES_GOOD/config \
	DOTFILES_GOOD/images DOTFILES_GOOD/run DOTFILES_GOOD/scripts DOTFILES_GOOD/bin; do
	[ -d "$__d" ] || { echo "manquant: $__d"; exit 1; }
done

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
echo "→ DOTFILES_GOOD/scripts/print_roots.sh"
DOTFILES_DIR="$ROOT" sh ./DOTFILES_GOOD/scripts/print_roots.sh | head -5
echo "✅ DOTFILES_GOOD : OK"
