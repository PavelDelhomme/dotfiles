#!/bin/bash
# =============================================================================
# VIRTMAN ADAPTER - Adapter Bash pour virtman
# =============================================================================
# Description: Charge le core POSIX de virtman et adapte pour Bash
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
VIRTMAN_CORE="$DOTFILES_DIR/core/managers/virtman/core/virtman.sh"

if [ -f "$VIRTMAN_CORE" ]; then
    source "$VIRTMAN_CORE"
else
    echo "❌ Erreur: virtman core non trouvé: $VIRTMAN_CORE"
    return 1
fi

