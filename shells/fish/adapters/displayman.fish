# =============================================================================
# DISPLAYMAN ADAPTER - Adapter Fish pour displayman
# =============================================================================
# Description : charge le core POSIX de displayman pour Fish.
# Auteur      : Paul Delhomme
# Version     : 1.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g DISPLAYMAN_CORE "$DOTFILES_DIR/core/managers/displayman/core/displayman.sh"

if test -f "$DISPLAYMAN_CORE"
    function displayman
        bash -c 'source "$1"; shift; displayman "$@"' _ "$DISPLAYMAN_CORE" $argv
    end
else
    echo "❌ Erreur: displayman core non trouvé: $DISPLAYMAN_CORE"
    return 1
end
