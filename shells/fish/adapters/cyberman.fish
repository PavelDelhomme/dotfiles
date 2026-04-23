# =============================================================================
# CYBERMAN ADAPTER - Adapter Fish pour cyberman
# =============================================================================
# Description: Charge le core POSIX de cyberman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g CYBERMAN_CORE "$DOTFILES_DIR/core/managers/cyberman/core/cyberman.sh"

if test -f "$CYBERMAN_CORE"
    function cyberman
        bash -c 'source "$1"; shift; cyberman "$@"' _ "$CYBERMAN_CORE" $argv
    end
else
    echo "❌ Erreur: cyberman core non trouvé: $CYBERMAN_CORE"
    return 1
end

