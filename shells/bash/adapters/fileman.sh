#!/bin/bash
# =============================================================================
# FILEMAN ADAPTER - Adapter Bash pour fileman
# =============================================================================
# Description: Charge le core POSIX de fileman et adapte pour Bash
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
FILEMAN_CORE="$DOTFILES_DIR/core/managers/fileman/core/fileman.sh"

if [ -f "$FILEMAN_CORE" ]; then
    source "$FILEMAN_CORE"
else
    echo "❌ Erreur: fileman core non trouvé: $FILEMAN_CORE"
    return 1
fi

