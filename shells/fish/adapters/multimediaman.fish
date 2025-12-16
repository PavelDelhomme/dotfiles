# =============================================================================
# MULTIMEDIAMAN ADAPTER - Adapter Fish pour multimediaman
# =============================================================================
# Description: Charge le core POSIX de multimediaman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g MULTIMEDIAMAN_CORE "$DOTFILES_DIR/core/managers/multimediaman/core/multimediaman.sh"

if test -f "$MULTIMEDIAMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$MULTIMEDIAMAN_CORE'"
else
    echo "❌ Erreur: multimediaman core non trouvé: $MULTIMEDIAMAN_CORE"
    return 1
end

