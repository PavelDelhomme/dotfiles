# =============================================================================
# DEVMAN ADAPTER - Adapter Fish pour devman
# =============================================================================
# Description: Charge le core POSIX de devman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g DEVMAN_CORE "$DOTFILES_DIR/core/managers/devman/core/devman.sh"

if test -f "$DEVMAN_CORE"
    function devman
        bash -c 'source "$1"; shift; devman "$@"' _ "$DEVMAN_CORE" $argv
    end
else
    echo "❌ Erreur: devman core non trouvé: $DEVMAN_CORE"
    return 1
end

