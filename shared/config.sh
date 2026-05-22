#!/bin/sh
################################################################################
# Configuration unifiée pour tous les shells (sh/bash/zsh compatible)
# Ce fichier contient la configuration commune à tous les shells
################################################################################

# Détection du répertoire dotfiles
if [ -z "$DOTFILES_DIR" ]; then
    if [ -n "$HOME" ]; then
        DOTFILES_DIR="$HOME/dotfiles"
    else
        DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
    fi
fi

# Exporter pour les sous-shells
export DOTFILES_DIR

# Chemins dérivés (core, shells, share) pour scripts et adapters
[ -f "$DOTFILES_DIR/shared/functions/dotfiles_roots.sh" ] && . "$DOTFILES_DIR/shared/functions/dotfiles_roots.sh"

# ~/.local/bin et /usr/local/bin en tête de PATH (cursor shim, outils locaux)
[ -n "$HOME" ] && mkdir -p "$HOME/.local/bin"
_prepend_path() {
    _p="$1"
    case ":$PATH:" in *":$_p:"*) ;; *) export PATH="$_p:$PATH" ;; esac
}
[ -n "$HOME" ] && _prepend_path "$HOME/.local/bin"
_prepend_path "/usr/local/bin"

# Mises a jour Cursor : utiliser updateman cursor (pas de shim update-cursor dans PATH)

# Charger les variables d'environnement communes
if [ -f "$DOTFILES_DIR/shared/env.sh" ]; then
    . "$DOTFILES_DIR/shared/env.sh"
fi

# Charger les alias communs (compatibles sh/bash/zsh)
if [ -f "$DOTFILES_DIR/shared/aliases.sh" ]; then
    . "$DOTFILES_DIR/shared/aliases.sh"
fi

# Charger les fonctions communes (compatibles sh/bash/zsh)
if [ -d "$DOTFILES_DIR/shared/functions" ]; then
    for func_file in "$DOTFILES_DIR/shared/functions"/*.sh; do
        [ -f "$func_file" ] && . "$func_file"
    done
fi

