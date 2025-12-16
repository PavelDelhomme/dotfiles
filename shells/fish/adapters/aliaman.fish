# =============================================================================
# ALIAMAN ADAPTER - Adapter Fish pour aliaman
# =============================================================================
# Description: Charge le core POSIX de aliaman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g ALIAMAN_CORE "$DOTFILES_DIR/core/managers/aliaman/core/aliaman.sh"

if test -f "$ALIAMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$ALIAMAN_CORE'"
else
    echo "❌ Erreur: aliaman core non trouvé: $ALIAMAN_CORE"
    return 1
end

# Alias
alias am='aliaman'
alias alias-manager='aliaman'

