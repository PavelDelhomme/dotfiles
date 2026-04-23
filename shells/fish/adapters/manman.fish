# =============================================================================
# MANMAN ADAPTER - Adapter Fish pour manman
# =============================================================================
# Description: Charge le core POSIX de manman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g MANMAN_CORE "$DOTFILES_DIR/core/managers/manman/core/manman.sh"

if test -f "$MANMAN_CORE"
    function manman
        bash -c 'source "$1"; shift; manman "$@"' _ "$MANMAN_CORE" $argv
    end
else
    echo "❌ Erreur: manman core non trouvé: $MANMAN_CORE"
    return 1
end

# Alias
alias mmg='manman'
alias managers='manman'

