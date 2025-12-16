# =============================================================================
# MODULEMAN ADAPTER - Adapter Fish pour moduleman
# =============================================================================
# Description: Charge le core POSIX de moduleman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

set -g DOTFILES_DIR "$HOME/dotfiles"
set -g MODULEMAN_CORE "$DOTFILES_DIR/core/managers/moduleman/core/moduleman.sh"

if test -f "$MODULEMAN_CORE"
    # Fish ne peut pas sourcer directement .sh, on utilise bash
    bash -c "source '$MODULEMAN_CORE'"
else
    echo "❌ Erreur: moduleman core non trouvé: $MODULEMAN_CORE"
    return 1
end

