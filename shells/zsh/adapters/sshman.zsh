#!/bin/zsh
# =============================================================================
# SSHMAN ADAPTER - Adapter ZSH pour sshman
# =============================================================================
# Description: Charge le core POSIX de sshman et adapte pour ZSH
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SSHMAN_CORE="$DOTFILES_DIR/core/managers/sshman/core/sshman.sh"

if [ -f "$SSHMAN_CORE" ]; then
    source "$SSHMAN_CORE"
else
    echo "❌ Erreur: sshman core non trouvé: $SSHMAN_CORE"
    return 1
fi

