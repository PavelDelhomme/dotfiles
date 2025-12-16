# =============================================================================
# CYBERLEARN ADAPTER - Adapter Fish pour cyberlearn
# =============================================================================
# Description: Charge le core POSIX de cyberlearn et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g CYBERLEARN_CORE "$DOTFILES_DIR/core/managers/cyberlearn/core/cyberlearn.sh"

if test -f "$CYBERLEARN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$CYBERLEARN_CORE'"
else
    echo "❌ Erreur: cyberlearn core non trouvé: $CYBERLEARN_CORE"
    return 1
end

