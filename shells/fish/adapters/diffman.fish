# =============================================================================
# DIFFMAN ADAPTER — charge le core POSIX pour Fish (via bash bridge)
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g DIFFMAN_CORE "$DOTFILES_DIR/core/managers/diffman/core/diffman.sh"

if test -f "$DIFFMAN_CORE"
    function diffman
        bash -c 'source "$1"; shift; diffman "$@"' _ "$DIFFMAN_CORE" $argv
    end
else
    echo "❌ Erreur: diffman core non trouvé: $DIFFMAN_CORE"
    return 1
end
