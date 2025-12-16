#!/bin/bash
# =============================================================================
# HELPMAN ADAPTER - Adapter Bash pour helpman
# =============================================================================
# Description: Charge le core POSIX de helpman et adapte pour Bash
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
HELPMAN_CORE="$DOTFILES_DIR/core/managers/helpman/core/helpman.sh"

if [ -f "$HELPMAN_CORE" ]; then
    source "$HELPMAN_CORE"
else
    echo "❌ Erreur: helpman core non trouvé: $HELPMAN_CORE"
    return 1
fi

