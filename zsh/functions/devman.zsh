#!/bin/zsh
# =============================================================================
# DEVMAN WRAPPER - Wrapper de compatibilité pour devman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

# Charger le script principal depuis la nouvelle structure
DEVMAN_CORE="$HOME/dotfiles/zsh/functions/devman/core/devman.zsh"

if [ -f "$DEVMAN_CORE" ]; then
    source "$DEVMAN_CORE"
else
    echo "❌ Erreur: devman core non trouvé: $DEVMAN_CORE"
    return 1
fi

