#!/bin/sh
# Extrait progressif depuis shared/env.sh (exports « seuls », sans mkdir / add_to_path / echo).
# Source de vérité prod : ../../shared/env.sh — ne pas supprimer l’original.
# Chargé uniquement par DOTFILES_GOOD/lib/bootstrap_posix.sh (bac à sable).

export CHROME_EXECUTABLE="/usr/bin/chromium"
export EMACSDIR="${HOME:-}/.emacs.d/bin"
export DOTNET_PATH="${HOME:-}/.dotnet/tools"
