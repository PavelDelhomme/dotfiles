# =============================================================================
# MODULEMAN ADAPTER - Adapter Fish pour moduleman
# =============================================================================
# Description: Charge le core POSIX de moduleman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g MODULEMAN_CORE "$DOTFILES_DIR/core/managers/moduleman/core/moduleman.sh"

if test -f "$MODULEMAN_CORE"
    # Fish ne peut pas sourcer le core POSIX ; déléguer à bash (même motif que doctorman).
    function moduleman
        bash -c 'source "$1"; shift; moduleman "$@"' _ "$MODULEMAN_CORE" $argv
    end
else
    echo "❌ Erreur: moduleman core non trouvé: $MODULEMAN_CORE"
    return 1
end
