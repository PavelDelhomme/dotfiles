#!/bin/bash
# =============================================================================
# CYBERLEARN ADAPTER - Adapter Bash pour cyberlearn
# =============================================================================
# Description: Charge le core POSIX de cyberlearn et adapte pour Bash
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
CYBERLEARN_CORE="$DOTFILES_DIR/core/managers/cyberlearn/core/cyberlearn.sh"

if [ -f "$CYBERLEARN_CORE" ]; then
    source "$CYBERLEARN_CORE"
else
    echo "❌ Erreur: cyberlearn core non trouvé: $CYBERLEARN_CORE"
    return 1
fi

