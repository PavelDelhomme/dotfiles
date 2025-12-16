# =============================================================================
# SEARCHMAN ADAPTER - Adapter Fish pour searchman
# =============================================================================
# Description: Charge le core POSIX de searchman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g SEARCHMAN_CORE "$DOTFILES_DIR/core/managers/searchman/core/searchman.sh"

if test -f "$SEARCHMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$SEARCHMAN_CORE'"
else
    echo "❌ Erreur: searchman core non trouvé: $SEARCHMAN_CORE"
    return 1
end

# Alias
alias sm='searchman'
alias search-manager='searchman'

