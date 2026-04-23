#!/bin/sh
# Chemins du bac à sable : s'exécute après bootstrap_posix.sh (DOTFILES_GOOD_ROOT et DOTFILES_DIR déjà posés).
# Étendre ici progressivement (PATH, XDG, chemins managers) sans toucher aux fichiers historiques du dépôt.

: "${DOTFILES_GOOD_ROOT:?}"
: "${DOTFILES_DIR:?}"

export DOTFILES_GOOD_ENV_LOADED=1
