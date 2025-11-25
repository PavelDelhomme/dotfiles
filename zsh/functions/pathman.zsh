#!/bin/zsh
# =============================================================================
# PATHMAN WRAPPER - Wrapper de compatibilité pour pathman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

# Charger le script principal depuis la nouvelle structure
PATHMAN_CORE="$HOME/dotfiles/zsh/functions/pathman/core/pathman.zsh"

if [ -f "$PATHMAN_CORE" ]; then
    source "$PATHMAN_CORE"
else
    echo "❌ Erreur: pathman core non trouvé: $PATHMAN_CORE"
    return 1
fi
