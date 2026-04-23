# =============================================================================
# VIRTMAN ADAPTER - Adapter Fish pour virtman
# =============================================================================
# Description: Charge le core POSIX de virtman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g VIRTMAN_CORE "$DOTFILES_DIR/core/managers/virtman/core/virtman.sh"

if test -f "$VIRTMAN_CORE"
    function virtman
        bash -c 'source "$1"; shift; virtman "$@"' _ "$VIRTMAN_CORE" $argv
    end
else
    echo "❌ Erreur: virtman core non trouvé: $VIRTMAN_CORE"
    return 1
end

