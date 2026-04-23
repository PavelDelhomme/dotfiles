# =============================================================================
# HELPMAN ADAPTER - Adapter Fish pour helpman
# =============================================================================
# Description: Charge le core POSIX de helpman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g HELPMAN_CORE "$DOTFILES_DIR/core/managers/helpman/core/helpman.sh"

if test -f "$HELPMAN_CORE"
    function helpman
        bash -c 'source "$1"; shift; helpman "$@"' _ "$HELPMAN_CORE" $argv
    end
else
    echo "❌ Erreur: helpman core non trouvé: $HELPMAN_CORE"
    return 1
end

