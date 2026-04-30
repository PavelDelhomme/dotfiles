#!/bin/zsh
# =============================================================================
# PROCESSMAN WRAPPER - Wrapper de compatibilité pour processman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
PROCESSMAN_CORE="$DOTFILES_DIR/core/managers/processman/core/processman.sh"

if [ -f "$PROCESSMAN_CORE" ]; then
    source "$PROCESSMAN_CORE"
else
    echo "❌ Erreur: processman core non trouvé: $PROCESSMAN_CORE"
    return 1
fi

