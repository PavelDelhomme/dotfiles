# =============================================================================
# INSTALLMAN ADAPTER - Adapter Fish pour installman
# =============================================================================
# Description: Charge le core POSIX de installman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g INSTALLMAN_CORE "$DOTFILES_DIR/core/managers/installman/core/installman.sh"

if test -f "$INSTALLMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$INSTALLMAN_CORE'"
else
    echo "❌ Erreur: installman core non trouvé: $INSTALLMAN_CORE"
    return 1
end

