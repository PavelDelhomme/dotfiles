# =============================================================================
# CONFIGMAN ADAPTER - Adapter Fish pour configman
# =============================================================================
# Description: Charge le core POSIX de configman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g CONFIGMAN_CORE "$DOTFILES_DIR/core/managers/configman/core/configman.sh"

if test -f "$CONFIGMAN_CORE"
    function configman
        bash -c 'source "$1"; shift; configman "$@"' _ "$CONFIGMAN_CORE" $argv
    end
else
    echo "❌ Erreur: configman core non trouvé: $CONFIGMAN_CORE"
    return 1
end

