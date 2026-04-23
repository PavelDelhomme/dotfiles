# =============================================================================
# FILEMAN ADAPTER - Adapter Fish pour fileman
# =============================================================================
# Description: Charge le core POSIX de fileman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g FILEMAN_CORE "$DOTFILES_DIR/core/managers/fileman/core/fileman.sh"

if test -f "$FILEMAN_CORE"
    function fileman
        bash -c 'source "$1"; shift; fileman "$@"' _ "$FILEMAN_CORE" $argv
    end
else
    echo "❌ Erreur: fileman core non trouvé: $FILEMAN_CORE"
    return 1
end

