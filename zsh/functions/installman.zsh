#!/bin/zsh
# =============================================================================
# INSTALLMAN WRAPPER - Wrapper de compatibilité pour installman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

# Charger le script principal depuis la nouvelle structure
INSTALLMAN_CORE="$HOME/dotfiles/zsh/functions/installman/core/installman.zsh"

if [ -f "$INSTALLMAN_CORE" ]; then
    source "$INSTALLMAN_CORE"
else
    echo "❌ Erreur: installman core non trouvé: $INSTALLMAN_CORE"
    return 1
fi

