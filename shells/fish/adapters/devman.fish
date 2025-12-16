# =============================================================================
# DEVMAN ADAPTER - Adapter Fish pour devman
# =============================================================================
# Description: Charge le core POSIX de devman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g DEVMAN_CORE "$DOTFILES_DIR/core/managers/devman/core/devman.sh"

if test -f "$DEVMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$DEVMAN_CORE'"
else
    echo "❌ Erreur: devman core non trouvé: $DEVMAN_CORE"
    return 1
end

