# =============================================================================
# SSMAN ADAPTER - Adapter Fish pour sshman
# =============================================================================
# Description: Charge le core POSIX de sshman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g SSMAN_CORE "$DOTFILES_DIR/core/managers/sshman/core/sshman.sh"

if test -f "$SSMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$SSMAN_CORE'"
else
    echo "❌ Erreur: sshman core non trouvé: $SSMAN_CORE"
    return 1
end

