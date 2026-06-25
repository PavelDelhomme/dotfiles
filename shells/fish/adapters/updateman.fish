# =============================================================================
# UPDATEMAN ADAPTER - Fish
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end

set -g UPDATEMAN_CORE "$DOTFILES_DIR/core/managers/updateman/core/updateman.sh"

function updateman
    if test -f "$UPDATEMAN_CORE"
        set -l _df "$DOTFILES_DIR"
        test -n "$_df"; or set _df "$HOME/dotfiles"
        env DOTFILES_DIR="$_df" bash -c '. "$DOTFILES_DIR/core/managers/updateman/core/updateman.sh"; updateman "$@"' bash $argv
    else
        echo "❌ updateman core non trouvé: $UPDATEMAN_CORE"
        return 1
    end
end
