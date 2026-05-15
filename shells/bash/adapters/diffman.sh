#!/usr/bin/env bash
# =============================================================================
# DIFFMAN ADAPTER — charge le core POSIX (Bash)
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DIFFMAN_CORE="$DOTFILES_DIR/core/managers/diffman/core/diffman.sh"

if [ -f "$DIFFMAN_CORE" ]; then
    # shellcheck source=/dev/null
    source "$DIFFMAN_CORE"
else
    echo "❌ Erreur: diffman core non trouvé: $DIFFMAN_CORE"
    return 1 2>/dev/null || exit 1
fi
