# =============================================================================
# UPDATEMAN ADAPTER - Zsh
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
UPDATEMAN_CORE="$DOTFILES_DIR/core/managers/updateman/core/updateman.sh"

if [[ -f "$UPDATEMAN_CORE" ]]; then
    _dotfiles_updateman_load_core() {
        emulate -L sh
        source "$UPDATEMAN_CORE"
    }
    _dotfiles_updateman_load_core
    unfunction _dotfiles_updateman_load_core 2>/dev/null || true
else
    echo "❌ updateman core POSIX non trouvé: $UPDATEMAN_CORE"
    return 1
fi
