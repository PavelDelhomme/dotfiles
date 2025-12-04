#!/bin/zsh
# =============================================================================
# TESTMAN WRAPPER - Wrapper de compatibilité pour testman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger le script principal depuis la nouvelle structure
TESTMAN_CORE="$HOME/dotfiles/zsh/functions/testman/core/testman.zsh"

if [ -f "$TESTMAN_CORE" ]; then
    source "$TESTMAN_CORE" 2>/dev/null || {
        echo "❌ Erreur: Impossible de charger testman core"
        return 1
    }
else
    echo "❌ Erreur: testman core non trouvé: $TESTMAN_CORE"
    return 1
fi

