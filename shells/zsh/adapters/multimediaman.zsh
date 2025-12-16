#!/bin/zsh
# =============================================================================
# MULTIMEDIAMAN ADAPTER - Adapter ZSH pour multimediaman
# =============================================================================
# Description: Charge le core POSIX de multimediaman et adapte pour ZSH
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
MULTIMEDIAMAN_CORE="$DOTFILES_DIR/core/managers/multimediaman/core/multimediaman.sh"

if [ -f "$MULTIMEDIAMAN_CORE" ]; then
    source "$MULTIMEDIAMAN_CORE"
else
    echo "❌ Erreur: multimediaman core non trouvé: $MULTIMEDIAMAN_CORE"
    return 1
fi

