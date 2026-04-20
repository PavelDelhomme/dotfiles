#!/bin/zsh
# =============================================================================
# TESTZSHMAN ADAPTER - Adapter ZSH pour testzshman
# =============================================================================
# Description: Charge le core POSIX de testzshman et adapte pour ZSH
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
TESTZSHMAN_CORE="$DOTFILES_DIR/core/managers/testzshman/core/testzshman.sh"

if [ -f "$TESTZSHMAN_CORE" ]; then
    # Core POSIX : emulate -L sh (sans -R) suffit pour le parser comme sh, sans réinitialiser toutes les options zsh.
    () {
        emulate -L sh
        builtin source "$TESTZSHMAN_CORE"
    }
else
    echo "❌ Erreur: testzshman core non trouvé: $TESTZSHMAN_CORE"
    return 1
fi

