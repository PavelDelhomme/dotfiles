#!/bin/zsh
# =============================================================================
# HELPMAN WRAPPER - Wrapper de compatibilité pour helpman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

# Charger le script principal depuis la nouvelle structure
HELPMAN_CORE="$HOME/dotfiles/zsh/functions/helpman/core/helpman.zsh"

if [ -f "$HELPMAN_CORE" ]; then
    source "$HELPMAN_CORE"
else
    echo "❌ Erreur: helpman core non trouvé: $HELPMAN_CORE"
    return 1
fi

