#!/bin/bash
# =============================================================================
# NETMAN ADAPTER - Adapter Bash pour netman
# =============================================================================
# Description: Charge le core POSIX de netman et adapte pour Bash
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
NETMAN_CORE="$DOTFILES_DIR/core/managers/netman/core/netman.sh"

if [ -f "$NETMAN_CORE" ]; then
    source "$NETMAN_CORE"
else
    echo "❌ Erreur: netman core non trouvé: $NETMAN_CORE"
    return 1
fi

