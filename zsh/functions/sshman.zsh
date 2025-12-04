#!/bin/zsh
# =============================================================================
# SSMAN WRAPPER - Wrapper de compatibilité pour sshman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Détecter le chemin des dotfiles (support Docker et installation normale)
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# Charger le script principal depuis la nouvelle structure
SSHMAN_CORE="$DOTFILES_DIR/zsh/functions/sshman/core/sshman.zsh"

# Si le chemin standard ne fonctionne pas, essayer de détecter depuis le script actuel
if [ ! -f "$SSHMAN_CORE" ]; then
    # Essayer de trouver le répertoire dotfiles depuis ce script
    SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" 2>/dev/null && pwd)"
    if [ -n "$SCRIPT_DIR" ]; then
        # Remonter jusqu'à trouver dotfiles
        CURRENT_DIR="$SCRIPT_DIR"
        while [ "$CURRENT_DIR" != "/" ]; do
            if [ -d "$CURRENT_DIR" ] && [ -f "$CURRENT_DIR/zsh/zshrc_custom" ]; then
                DOTFILES_DIR="$CURRENT_DIR"
                SSHMAN_CORE="$DOTFILES_DIR/zsh/functions/sshman/core/sshman.zsh"
                break
            fi
            CURRENT_DIR="$(dirname "$CURRENT_DIR")"
        done
    fi
fi

if [ -f "$SSHMAN_CORE" ]; then
    source "$SSHMAN_CORE" 2>/dev/null || {
        # Ne pas afficher d'erreur en mode silencieux (chargement initial)
        return 1
    }
else
    # Ne pas afficher d'erreur en mode silencieux (chargement initial)
    return 1
fi

