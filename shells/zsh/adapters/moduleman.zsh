#!/bin/zsh
# =============================================================================
# MODULEMAN ADAPTER - Adapter ZSH pour moduleman
# =============================================================================
# Description: Charge le core POSIX de moduleman et adapte pour ZSH
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
MODULEMAN_CORE="$DOTFILES_DIR/core/managers/moduleman/core/moduleman.sh"

if [ -f "$MODULEMAN_CORE" ]; then
    source "$MODULEMAN_CORE"
else
    echo "❌ Erreur: moduleman core non trouvé: $MODULEMAN_CORE"
    return 1
fi

