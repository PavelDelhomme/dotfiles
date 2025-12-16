#!/bin/bash
# =============================================================================
# TESTZSHMAN ADAPTER - Adapter Bash pour testzshman
# =============================================================================
# Description: Charge le core POSIX de testzshman et adapte pour Bash
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
TESTZSHMAN_CORE="$DOTFILES_DIR/core/managers/testzshman/core/testzshman.sh"

if [ -f "$TESTZSHMAN_CORE" ]; then
    source "$TESTZSHMAN_CORE"
else
    echo "❌ Erreur: testzshman core non trouvé: $TESTZSHMAN_CORE"
    return 1
fi

