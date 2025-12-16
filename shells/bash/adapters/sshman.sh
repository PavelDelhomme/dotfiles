#!/bin/bash
# =============================================================================
# SSMAN ADAPTER - Adapter Bash pour sshman
# =============================================================================
# Description: Charge le core POSIX de sshman et adapte pour Bash
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SSMAN_CORE="$DOTFILES_DIR/core/managers/sshman/core/sshman.sh"

if [ -f "$SSMAN_CORE" ]; then
    source "$SSMAN_CORE"
else
    echo "❌ Erreur: sshman core non trouvé: $SSMAN_CORE"
    return 1
fi

