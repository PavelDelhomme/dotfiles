#!/bin/zsh
# =============================================================================
# GITMAN WRAPPER - Wrapper de compatibilité pour gitman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

# Charger le script principal depuis la nouvelle structure
GITMAN_CORE="$HOME/dotfiles/zsh/functions/gitman/core/gitman.zsh"

if [ -f "$GITMAN_CORE" ]; then
    source "$GITMAN_CORE"
else
    echo "❌ Erreur: gitman core non trouvé: $GITMAN_CORE"
    return 1
fi

