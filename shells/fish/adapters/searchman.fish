# =============================================================================
# SEARCHMAN ADAPTER - Adapter Fish pour searchman
# =============================================================================
# Description: Charge le core POSIX de searchman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g SEARCHMAN_CORE "$DOTFILES_DIR/core/managers/searchman/core/searchman.sh"

if test -f "$SEARCHMAN_CORE"
    function searchman
        bash -c 'source "$1"; shift; searchman "$@"' _ "$SEARCHMAN_CORE" $argv
    end
else
    echo "❌ Erreur: searchman core non trouvé: $SEARCHMAN_CORE"
    return 1
end

# Alias
alias sm='searchman'
alias search-manager='searchman'

