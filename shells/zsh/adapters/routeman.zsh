#!/bin/zsh
# =============================================================================
# ROUTEMAN ADAPTER - Adapter ZSH pour routeman
# =============================================================================
# Description: Charge le core POSIX de routeman et adapte pour ZSH
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

