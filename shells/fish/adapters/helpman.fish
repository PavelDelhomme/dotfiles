# =============================================================================
# HELPMAN ADAPTER - Adapter Fish pour helpman
# =============================================================================
# Description: Charge le core POSIX de helpman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g HELPMAN_CORE "$DOTFILES_DIR/core/managers/helpman/core/helpman.sh"

if test -f "$HELPMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$HELPMAN_CORE'"
else
    echo "❌ Erreur: helpman core non trouvé: $HELPMAN_CORE"
    return 1
end

