#!/bin/zsh
# =============================================================================
# DISKMAN ADAPTER — charge le core POSIX (ZSH)
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DISKMAN_CORE="$DOTFILES_DIR/core/managers/diskman/core/diskman.sh"

if [ -f "$DISKMAN_CORE" ]; then
    source "$DISKMAN_CORE"
else
    echo "❌ Erreur: diskman core non trouvé: $DISKMAN_CORE"
    return 1
fi
