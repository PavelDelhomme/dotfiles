#!/bin/zsh
# =============================================================================
# CONFIGMAN WRAPPER - Wrapper de compatibilité pour configman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

# Charger le script principal depuis la nouvelle structure
CONFIGMAN_CORE="$HOME/dotfiles/zsh/functions/configman/core/configman.zsh"

if [ -f "$CONFIGMAN_CORE" ]; then
    source "$CONFIGMAN_CORE"
else
    echo "❌ Erreur: configman core non trouvé: $CONFIGMAN_CORE"
    return 1
fi

