#!/usr/bin/env bash
# Compat — délègue à dotfiles_update.sh (pull par défaut)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_SYNC_MODE="${DOTFILES_SYNC_MODE:-pull}"
exec bash "$DIR/dotfiles_update.sh" "${1:-$DOTFILES_SYNC_MODE}"
