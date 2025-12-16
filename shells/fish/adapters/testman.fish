# =============================================================================
# TESTMAN ADAPTER - Adapter Fish pour testman
# =============================================================================
# Description: Charge le core POSIX de testman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g TESTMAN_CORE "$DOTFILES_DIR/core/managers/testman/core/testman.sh"

if test -f "$TESTMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$TESTMAN_CORE'"
else
    echo "❌ Erreur: testman core non trouvé: $TESTMAN_CORE"
    return 1
end

