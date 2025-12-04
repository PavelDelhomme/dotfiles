#!/bin/zsh
# =============================================================================
# TESTZSHMAN WRAPPER - Wrapper de compatibilité pour testzshman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger le script principal depuis la nouvelle structure
TESTZSHMAN_CORE="$HOME/dotfiles/zsh/functions/testzshman/core/testzshman.zsh"

if [ -f "$TESTZSHMAN_CORE" ]; then
    source "$TESTZSHMAN_CORE" 2>/dev/null || {
        echo "❌ Erreur: Impossible de charger testzshman core"
        return 1
    }
else
    echo "❌ Erreur: testzshman core non trouvé: $TESTZSHMAN_CORE"
    return 1
fi

