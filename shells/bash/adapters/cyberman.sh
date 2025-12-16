#!/bin/bash
# =============================================================================
# CYBERMAN ADAPTER - Adapter Bash pour cyberman
# =============================================================================
# Description: Charge le core POSIX de cyberman et adapte pour Bash
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
CYBERMAN_CORE="$DOTFILES_DIR/core/managers/cyberman/core/cyberman.sh"

if [ -f "$CYBERMAN_CORE" ]; then
    source "$CYBERMAN_CORE"
else
    echo "❌ Erreur: cyberman core non trouvé: $CYBERMAN_CORE"
    return 1
fi

