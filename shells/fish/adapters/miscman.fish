# =============================================================================
# MISCMAN ADAPTER - Adapter Fish pour miscman
# =============================================================================
# Description: Charge le core POSIX de miscman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g MISCMAN_CORE "$DOTFILES_DIR/core/managers/miscman/core/miscman.sh"

if test -f "$MISCMAN_CORE"
    function miscman
        bash -c 'source "$1"; shift; miscman "$@"' _ "$MISCMAN_CORE" $argv
    end
else
    echo "❌ Erreur: miscman core non trouvé: $MISCMAN_CORE"
    return 1
end

