#!/usr/bin/env bash
# =============================================================================
# DISKMAN ADAPTER — charge le core POSIX (Bash)
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DISKMAN_CORE="$DOTFILES_DIR/core/managers/diskman/core/diskman.sh"

if [ -f "$DISKMAN_CORE" ]; then
    # shellcheck source=/dev/null
    source "$DISKMAN_CORE"
else
    echo "❌ Erreur: diskman core non trouvé: $DISKMAN_CORE"
    return 1 2>/dev/null || exit 1
fi
