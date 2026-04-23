#!/bin/sh
# Amorce POSIX du bac à sable DOTFILES_GOOD (expérimentale).
# Usage : . "$DOTFILES_DIR/DOTFILES_GOOD/lib/bootstrap_posix.sh"
# Important : en « . script », $0 n’est pas fiable — on déduit depuis DOTFILES_DIR ou $HOME/dotfiles.

if [ -n "${DOTFILES_DIR:-}" ] && [ -d "$DOTFILES_DIR/DOTFILES_GOOD" ]; then
	DOTFILES_GOOD_ROOT="$DOTFILES_DIR/DOTFILES_GOOD"
elif [ -n "${HOME:-}" ] && [ -d "$HOME/dotfiles/DOTFILES_GOOD" ]; then
	DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
	DOTFILES_GOOD_ROOT="$DOTFILES_DIR/DOTFILES_GOOD"
else
	# Exécution directe : sh ./bootstrap_posix.sh (tests locaux)
	case "$0" in
	*/*)
		__dg_lib=$(CDPATH= cd "$(dirname "$0")" && pwd) || return 1
		DOTFILES_GOOD_ROOT=$(CDPATH= cd "$__dg_lib/.." && pwd) || return 1
		;;
	*)
		echo "bootstrap_posix.sh: impossible de trouver DOTFILES_GOOD (posez DOTFILES_DIR)." >&2
		return 1
		;;
	esac
fi
export DOTFILES_GOOD_ROOT

if [ -z "$DOTFILES_DIR" ]; then
	DOTFILES_DIR=$(CDPATH= cd "$DOTFILES_GOOD_ROOT/.." && pwd) || return 1
	export DOTFILES_DIR
fi

# Variables d'environnement (ordre : noms de fichiers triés, ex. 00_, 01_)
if [ -d "$DOTFILES_GOOD_ROOT/shared/env" ]; then
	for __f in "$DOTFILES_GOOD_ROOT/shared/env/"*.sh; do
		[ -f "$__f" ] && . "$__f"
	done
fi

# Fonctions POSIX locales au bac à sable
if [ -d "$DOTFILES_GOOD_ROOT/shared/functions" ]; then
	for __f in "$DOTFILES_GOOD_ROOT/shared/functions/"*.sh; do
		[ -f "$__f" ] && . "$__f"
	done
fi

# Alias POSIX (fichier optionnel)
if [ -f "$DOTFILES_GOOD_ROOT/shared/aliases.sh" ]; then
	. "$DOTFILES_GOOD_ROOT/shared/aliases.sh"
fi

return 0
