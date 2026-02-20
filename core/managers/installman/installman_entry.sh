#!/bin/sh
# =============================================================================
# INSTALLMAN ENTRY - Point d'entrée unique multi-shell
# =============================================================================
# Tous les shells (bash, fish, etc.) peuvent exécuter ce script.
# L'implémentation canonique est en Zsh (pagination, log, tous les outils).
# Usage: installman_entry.sh [args...]
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
export DOTFILES_DIR

# Exécuter le core Zsh (implémentation complète) avec les arguments passés
exec zsh -c '
source "${1}/zsh/functions/installman/core/installman.zsh"
installman "${@:2}"
' "$DOTFILES_DIR" "$@"
