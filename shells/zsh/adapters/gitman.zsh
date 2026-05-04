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
    # Le core est du sh/POSIX ; zsh le parse mal seul (guillemets / awk). Emulation sh locale.
    _dotfiles_gitman_load_core() {
        emulate -L sh
        source "$GITMAN_CORE"
    }
    _dotfiles_gitman_load_core
    unfunction _dotfiles_gitman_load_core 2>/dev/null || true
else
    echo "❌ Erreur: gitman core non trouvé: $GITMAN_CORE"
    return 1
fi

