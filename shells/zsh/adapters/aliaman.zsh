#!/bin/zsh
# =============================================================================
# ALIAMAN ADAPTER - Adapter ZSH pour aliaman
# =============================================================================
# Description: Charge le core POSIX de aliaman et adapte pour ZSH
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
ALIAMAN_CORE="$DOTFILES_DIR/core/managers/aliaman/core/aliaman.sh"

if [ -f "$ALIAMAN_CORE" ]; then
    source "$ALIAMAN_CORE"
else
    echo "❌ Erreur: aliaman core non trouvé: $ALIAMAN_CORE"
    return 1
fi

# Alias
alias am='aliaman'
alias alias-manager='aliaman'

