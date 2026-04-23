# =============================================================================
# TESTZSHMAN ADAPTER - Adapter Fish pour testzshman
# =============================================================================
# Description: Charge le core POSIX de testzshman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g TESTZSHMAN_CORE "$DOTFILES_DIR/core/managers/testzshman/core/testzshman.sh"

if test -f "$TESTZSHMAN_CORE"
    function testzshman
        bash -c 'source "$1"; shift; testzshman "$@"' _ "$TESTZSHMAN_CORE" $argv
    end
else
    echo "❌ Erreur: testzshman core non trouvé: $TESTZSHMAN_CORE"
    return 1
end

