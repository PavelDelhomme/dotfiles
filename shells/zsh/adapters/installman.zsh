#!/bin/zsh
# =============================================================================
# INSTALLMAN ADAPTER - Adapter ZSH pour installman
# =============================================================================
# Description: Charge le core POSIX de installman et adapte pour ZSH
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
INSTALLMAN_CORE="$DOTFILES_DIR/core/managers/installman/core/installman.sh"

if [ -f "$INSTALLMAN_CORE" ]; then
    source "$INSTALLMAN_CORE"
else
    echo "❌ Erreur: installman core non trouvé: $INSTALLMAN_CORE"
    return 1
fi

