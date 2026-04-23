# =============================================================================
# CYBERLEARN ADAPTER - Adapter Fish pour cyberlearn
# =============================================================================
# Description: Charge le core POSIX de cyberlearn et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g CYBERLEARN_CORE "$DOTFILES_DIR/core/managers/cyberlearn/core/cyberlearn.sh"

if test -f "$CYBERLEARN_CORE"
    function cyberlearn
        bash -c 'source "$1"; shift; cyberlearn "$@"' _ "$CYBERLEARN_CORE" $argv
    end
else
    echo "❌ Erreur: cyberlearn core non trouvé: $CYBERLEARN_CORE"
    return 1
end

