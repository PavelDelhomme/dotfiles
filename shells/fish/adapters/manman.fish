# =============================================================================
# MANMAN ADAPTER - Adapter Fish pour manman
# =============================================================================
# Description: Charge le core POSIX de manman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g MANMAN_CORE "$DOTFILES_DIR/core/managers/manman/core/manman.sh"

if test -f "$MANMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$MANMAN_CORE'"
else
    echo "❌ Erreur: manman core non trouvé: $MANMAN_CORE"
    return 1
end

# Alias
alias mmg='manman'
alias managers='manman'

