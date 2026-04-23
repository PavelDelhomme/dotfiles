# =============================================================================
# GITMAN ADAPTER - Adapter Fish pour gitman
# =============================================================================
# Description: Charge le core POSIX de gitman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g GITMAN_CORE "$DOTFILES_DIR/core/managers/gitman/core/gitman.sh"

if test -f "$GITMAN_CORE"
    function gitman
        bash -c 'source "$1"; shift; gitman "$@"' _ "$GITMAN_CORE" $argv
    end
else
    echo "❌ Erreur: gitman core non trouvé: $GITMAN_CORE"
    return 1
end

