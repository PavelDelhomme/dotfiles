#!/bin/bash
# =============================================================================
# UPDATEMAN ADAPTER - Bash
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
UPDATEMAN_CORE="$DOTFILES_DIR/core/managers/updateman/core/updateman.sh"

if [[ -f "$UPDATEMAN_CORE" ]]; then
    # shellcheck source=core/managers/updateman/core/updateman.sh
    source "$UPDATEMAN_CORE"
else
    echo "❌ updateman core POSIX non trouvé: $UPDATEMAN_CORE"
    return 1
fi

export -f updateman 2>/dev/null || true
