#!/bin/zsh
# =============================================================================
# FILEMAN WRAPPER - Wrapper de compatibilité pour fileman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger le script principal depuis la nouvelle structure
FILEMAN_CORE="$HOME/dotfiles/zsh/functions/fileman/core/fileman.zsh"

if [ -f "$FILEMAN_CORE" ]; then
    source "$FILEMAN_CORE"
else
    echo "❌ Erreur: fileman core non trouvé: $FILEMAN_CORE"
    return 1
fi

