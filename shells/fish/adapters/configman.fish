# =============================================================================
# CONFIGMAN ADAPTER - Adapter Fish pour configman
# =============================================================================
# Description: Charge le core POSIX de configman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g CONFIGMAN_CORE "$DOTFILES_DIR/core/managers/configman/core/configman.sh"

if test -f "$CONFIGMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$CONFIGMAN_CORE'"
else
    echo "❌ Erreur: configman core non trouvé: $CONFIGMAN_CORE"
    return 1
end

