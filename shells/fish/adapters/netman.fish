# =============================================================================
# NETMAN ADAPTER - Adapter Fish pour netman
# =============================================================================
# Description: Charge le core POSIX de netman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g NETMAN_CORE "$DOTFILES_DIR/core/managers/netman/core/netman.sh"

if test -f "$NETMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$NETMAN_CORE'"
else
    echo "❌ Erreur: netman core non trouvé: $NETMAN_CORE"
    return 1
end

