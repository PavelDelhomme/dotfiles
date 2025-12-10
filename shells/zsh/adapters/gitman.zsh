#!/bin/zsh
# =============================================================================
# GITMAN ADAPTER - Adapter ZSH pour gitman
# =============================================================================
# Description: Charge le core POSIX de gitman et adapte pour ZSH
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
GITMAN_CORE="$DOTFILES_DIR/core/managers/gitman/core/gitman.sh"

if [ -f "$GITMAN_CORE" ]; then
    source "$GITMAN_CORE"
else
    echo "❌ Erreur: gitman core non trouvé: $GITMAN_CORE"
    return 1
fi

