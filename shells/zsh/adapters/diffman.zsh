#!/bin/zsh
# =============================================================================
# DIFFMAN ADAPTER — charge le core POSIX (ZSH)
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DIFFMAN_CORE="$DOTFILES_DIR/core/managers/diffman/core/diffman.sh"

if [ -f "$DIFFMAN_CORE" ]; then
    source "$DIFFMAN_CORE"
else
    echo "❌ Erreur: diffman core non trouvé: $DIFFMAN_CORE"
    return 1
fi
