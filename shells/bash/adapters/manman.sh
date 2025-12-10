#!/bin/bash
# =============================================================================
# MANMAN ADAPTER - Adapter Bash pour manman
# =============================================================================
# Description: Charge le core POSIX de manman et adapte pour Bash
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
MANMAN_CORE="$DOTFILES_DIR/core/managers/manman/core/manman.sh"

if [ -f "$MANMAN_CORE" ]; then
    source "$MANMAN_CORE"
else
    echo "❌ Erreur: manman core non trouvé: $MANMAN_CORE"
    return 1
fi

# Alias
alias mmg='manman'
alias managers='manman'

