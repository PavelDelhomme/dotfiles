#!/bin/zsh
# =============================================================================
# CONFIGMAN ADAPTER - Adapter ZSH pour configman
# =============================================================================
# Description: Charge le core POSIX de configman et adapte pour ZSH
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
CONFIGMAN_CORE="$DOTFILES_DIR/core/managers/configman/core/configman.sh"

if [ -f "$CONFIGMAN_CORE" ]; then
    source "$CONFIGMAN_CORE"
else
    echo "❌ Erreur: configman core non trouvé: $CONFIGMAN_CORE"
    return 1
fi

