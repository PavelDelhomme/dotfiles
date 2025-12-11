#!/bin/zsh
# =============================================================================
# DEVMAN ADAPTER - Adapter ZSH pour devman
# =============================================================================
# Description: Charge le core POSIX de devman et adapte pour ZSH
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DEVMAN_CORE="$DOTFILES_DIR/core/managers/devman/core/devman.sh"

if [ -f "$DEVMAN_CORE" ]; then
    source "$DEVMAN_CORE"
else
    echo "❌ Erreur: devman core non trouvé: $DEVMAN_CORE"
    return 1
fi

