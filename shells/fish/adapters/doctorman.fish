# =============================================================================
# DOCTORMAN ADAPTER - Fish (core POSIX via bash)
# =============================================================================
if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g DOCTORMAN_CORE "$DOTFILES_DIR/core/managers/doctorman/core/doctorman.sh"

if test -f "$DOCTORMAN_CORE"
    function doctorman
        bash -c 'source "$1"; shift; doctorman "$@"' _ "$DOCTORMAN_CORE" $argv
    end
else
    echo "❌ doctorman core introuvable: $DOCTORMAN_CORE"
end
