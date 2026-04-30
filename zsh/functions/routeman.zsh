#!/bin/zsh
# =============================================================================
# ROUTEMAN WRAPPER - Wrapper de compatibilité pour routeman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
ROUTEMAN_CORE="$DOTFILES_DIR/core/managers/routeman/core/routeman.sh"

if [ -f "$ROUTEMAN_CORE" ]; then
    source "$ROUTEMAN_CORE"
else
    echo "❌ Erreur: routeman core non trouvé: $ROUTEMAN_CORE"
    return 1
fi

