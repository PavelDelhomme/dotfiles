# =============================================================================
# DOCTORMAN ADAPTER - Fish (core POSIX via bash)
# =============================================================================
set -g DOTFILES_DIR "$HOME/dotfiles"
set -g DOCTORMAN_CORE "$DOTFILES_DIR/core/managers/doctorman/core/doctorman.sh"

if test -f "$DOCTORMAN_CORE"
    function doctorman
        bash -c 'source "$1"; shift; doctorman "$@"' _ "$DOCTORMAN_CORE" $argv
    end
else
    echo "❌ doctorman core introuvable: $DOCTORMAN_CORE"
end
