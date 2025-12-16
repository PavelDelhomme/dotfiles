# =============================================================================
# PATHMAN ADAPTER - Adapter Fish pour pathman
# =============================================================================
# Description: Charge le core POSIX de pathman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g PATHMAN_CORE "$DOTFILES_DIR/core/managers/pathman/core/pathman.sh"

if test -f "$PATHMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$PATHMAN_CORE'"
else
    echo "❌ Erreur: pathman core non trouvé: $PATHMAN_CORE"
    return 1
end

# Alias
alias pm='pathman'
alias path-manager='pathman'

