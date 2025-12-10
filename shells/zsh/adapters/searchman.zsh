#!/bin/zsh
# =============================================================================
# SEARCHMAN ADAPTER - Adapter ZSH pour searchman
# =============================================================================
# Description: Charge le core POSIX de searchman et adapte pour ZSH
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SEARCHMAN_CORE="$DOTFILES_DIR/core/managers/searchman/core/searchman.sh"

if [ -f "$SEARCHMAN_CORE" ]; then
    source "$SEARCHMAN_CORE"
else
    echo "❌ Erreur: searchman core non trouvé: $SEARCHMAN_CORE"
    return 1
fi

# Alias
alias sm='searchman'
alias search-manager='searchman'

