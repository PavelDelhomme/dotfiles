#!/bin/bash
# =============================================================================
# DISPLAYMAN ADAPTER - Adapter Bash pour displayman
# =============================================================================
# Description : charge le core POSIX de displayman pour Bash.
# Auteur      : Paul Delhomme
# Version     : 1.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DISPLAYMAN_CORE="$DOTFILES_DIR/core/managers/displayman/core/displayman.sh"

if [ -f "$DISPLAYMAN_CORE" ]; then
    source "$DISPLAYMAN_CORE"
else
    echo "❌ Erreur: displayman core non trouvé: $DISPLAYMAN_CORE"
    return 1
fi
