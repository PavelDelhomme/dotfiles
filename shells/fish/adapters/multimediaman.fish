# =============================================================================
# MULTIMEDIAMAN ADAPTER - Adapter Fish pour multimediaman
# =============================================================================
# Description: Charge le core POSIX de multimediaman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g MULTIMEDIAMAN_CORE "$DOTFILES_DIR/core/managers/multimediaman/core/multimediaman.sh"

if test -f "$MULTIMEDIAMAN_CORE"
    function multimediaman
        bash -c 'source "$1"; shift; multimediaman "$@"' _ "$MULTIMEDIAMAN_CORE" $argv
    end
else
    echo "❌ Erreur: multimediaman core non trouvé: $MULTIMEDIAMAN_CORE"
    return 1
end

