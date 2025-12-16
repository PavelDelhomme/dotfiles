# =============================================================================
# VIRTMAN ADAPTER - Adapter Fish pour virtman
# =============================================================================
# Description: Charge le core POSIX de virtman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g VIRTMAN_CORE "$DOTFILES_DIR/core/managers/virtman/core/virtman.sh"

if test -f "$VIRTMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$VIRTMAN_CORE'"
else
    echo "❌ Erreur: virtman core non trouvé: $VIRTMAN_CORE"
    return 1
end

