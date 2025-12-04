#!/bin/zsh
# =============================================================================
# TESTMAN WRAPPER - Wrapper de compatibilité pour testman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Détecter le chemin des dotfiles (support Docker et installation normale)
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# Charger le script principal depuis la nouvelle structure
TESTMAN_CORE="$DOTFILES_DIR/zsh/functions/testman/core/testman.zsh"

# Si le chemin standard ne fonctionne pas, essayer de détecter depuis le script actuel
if [ ! -f "$TESTMAN_CORE" ]; then
    # Essayer de trouver le répertoire dotfiles depuis ce script
    SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" 2>/dev/null && pwd)"
    if [ -n "$SCRIPT_DIR" ]; then
        # Remonter jusqu'à trouver dotfiles
        CURRENT_DIR="$SCRIPT_DIR"
        while [ "$CURRENT_DIR" != "/" ]; do
            if [ -d "$CURRENT_DIR" ] && [ -f "$CURRENT_DIR/zsh/zshrc_custom" ]; then
                DOTFILES_DIR="$CURRENT_DIR"
                TESTMAN_CORE="$DOTFILES_DIR/zsh/functions/testman/core/testman.zsh"
                break
            fi
            CURRENT_DIR="$(dirname "$CURRENT_DIR")"
        done
    fi
fi

if [ -f "$TESTMAN_CORE" ]; then
    # Charger le core - ne pas retourner en cas d'erreur pour permettre le chargement
    source "$TESTMAN_CORE" 2>/dev/null || true
    # Vérifier si la fonction a été définie
    if ! type testman >/dev/null 2>&1; then
        # Si la fonction n'existe pas, essayer de charger directement sans wrapper
        # (peut être nécessaire dans certains environnements)
        return 1
    fi
else
    # Ne pas afficher d'erreur en mode silencieux (chargement initial)
    return 1
fi

