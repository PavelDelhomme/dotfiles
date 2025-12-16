# =============================================================================
# CYBERMAN ADAPTER - Adapter Fish pour cyberman
# =============================================================================
# Description: Charge le core POSIX de cyberman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g CYBERMAN_CORE "$DOTFILES_DIR/core/managers/cyberman/core/cyberman.sh"

if test -f "$CYBERMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$CYBERMAN_CORE'"
else
    echo "❌ Erreur: cyberman core non trouvé: $CYBERMAN_CORE"
    return 1
end

