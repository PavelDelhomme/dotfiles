# =============================================================================
# TESTZSHMAN ADAPTER - Adapter Fish pour testzshman
# =============================================================================
# Description: Charge le core POSIX de testzshman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g TESTZSHMAN_CORE "$DOTFILES_DIR/core/managers/testzshman/core/testzshman.sh"

if test -f "$TESTZSHMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$TESTZSHMAN_CORE'"
else
    echo "❌ Erreur: testzshman core non trouvé: $TESTZSHMAN_CORE"
    return 1
end

