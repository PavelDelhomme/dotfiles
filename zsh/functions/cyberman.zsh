#!/bin/zsh
# =============================================================================
# CYBERMAN WRAPPER - Wrapper de compatibilité pour cyberman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

# Charger le script principal depuis la nouvelle structure
CYBERMAN_CORE="$HOME/dotfiles/zsh/functions/cyberman/core/cyberman.zsh"

if [ -f "$CYBERMAN_CORE" ]; then
    source "$CYBERMAN_CORE"
else
    echo "❌ Erreur: cyberman core non trouvé: $CYBERMAN_CORE"
    return 1
fi
