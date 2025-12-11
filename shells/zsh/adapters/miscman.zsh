#!/bin/zsh
# =============================================================================
# MISCMAN ADAPTER - Adapter ZSH pour miscman
# =============================================================================
# Description: Charge le core POSIX de miscman et adapte pour ZSH
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
MISCMAN_CORE="$DOTFILES_DIR/core/managers/miscman/core/miscman.sh"

if [ -f "$MISCMAN_CORE" ]; then
    source "$MISCMAN_CORE"
else
    echo "❌ Erreur: miscman core non trouvé: $MISCMAN_CORE"
    return 1
fi

