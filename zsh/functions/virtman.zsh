#!/bin/zsh
# =============================================================================
# VIRTMAN WRAPPER - Wrapper de compatibilité pour virtman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger le script principal depuis la nouvelle structure
VIRTMAN_CORE="$HOME/dotfiles/zsh/functions/virtman/core/virtman.zsh"

if [ -f "$VIRTMAN_CORE" ]; then
    source "$VIRTMAN_CORE"
else
    echo "❌ Erreur: virtman core non trouvé: $VIRTMAN_CORE"
    return 1
fi

