# =============================================================================
# NETMAN ADAPTER - Adapter Fish pour netman
# =============================================================================
# Description: Charge le core POSIX de netman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g NETMAN_CORE "$DOTFILES_DIR/core/managers/netman/core/netman.sh"

if test -f "$NETMAN_CORE"
    function netman
        bash -c 'source "$1"; shift; netman "$@"' _ "$NETMAN_CORE" $argv
    end
else
    echo "❌ Erreur: netman core non trouvé: $NETMAN_CORE"
    return 1
end

