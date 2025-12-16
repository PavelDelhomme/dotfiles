#!/bin/bash
# =============================================================================
# TESTMAN ADAPTER - Adapter Bash pour testman
# =============================================================================
# Description: Charge le core POSIX de testman et adapte pour Bash
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
TESTMAN_CORE="$DOTFILES_DIR/core/managers/testman/core/testman.sh"

if [ -f "$TESTMAN_CORE" ]; then
    source "$TESTMAN_CORE"
else
    echo "❌ Erreur: testman core non trouvé: $TESTMAN_CORE"
    return 1
fi

