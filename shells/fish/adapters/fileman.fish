# =============================================================================
# FILEMAN ADAPTER - Adapter Fish pour fileman
# =============================================================================
# Description: Charge le core POSIX de fileman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g FILEMAN_CORE "$DOTFILES_DIR/core/managers/fileman/core/fileman.sh"

if test -f "$FILEMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$FILEMAN_CORE'"
else
    echo "❌ Erreur: fileman core non trouvé: $FILEMAN_CORE"
    return 1
end

