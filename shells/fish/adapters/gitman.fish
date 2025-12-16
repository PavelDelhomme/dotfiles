# =============================================================================
# GITMAN ADAPTER - Adapter Fish pour gitman
# =============================================================================
# Description: Charge le core POSIX de gitman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g GITMAN_CORE "$DOTFILES_DIR/core/managers/gitman/core/gitman.sh"

if test -f "$GITMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$GITMAN_CORE'"
else
    echo "❌ Erreur: gitman core non trouvé: $GITMAN_CORE"
    return 1
end

