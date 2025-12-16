# =============================================================================
# MISCMAN ADAPTER - Adapter Fish pour miscman
# =============================================================================
# Description: Charge le core POSIX de miscman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g MISCMAN_CORE "$DOTFILES_DIR/core/managers/miscman/core/miscman.sh"

if test -f "$MISCMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$MISCMAN_CORE'"
else
    echo "❌ Erreur: miscman core non trouvé: $MISCMAN_CORE"
    return 1
end

