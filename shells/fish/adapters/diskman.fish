# =============================================================================
# DISKMAN ADAPTER — charge le core POSIX pour Fish (via bash bridge)
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g DISKMAN_CORE "$DOTFILES_DIR/core/managers/diskman/core/diskman.sh"

if test -f "$DISKMAN_CORE"
    function diskman
        bash -c 'source "$1"; shift; diskman "$@"' _ "$DISKMAN_CORE" $argv
    end
else
    echo "❌ Erreur: diskman core non trouvé: $DISKMAN_CORE"
    return 1
end
