# =============================================================================
# ALIAMAN ADAPTER - Adapter Fish pour aliaman
# =============================================================================
# Description: Charge le core POSIX de aliaman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g ALIAMAN_CORE "$DOTFILES_DIR/core/managers/aliaman/core/aliaman.sh"

if test -f "$ALIAMAN_CORE"
    function aliaman
        bash -c 'source "$1"; shift; aliaman "$@"' _ "$ALIAMAN_CORE" $argv
    end
else
    echo "❌ Erreur: aliaman core non trouvé: $ALIAMAN_CORE"
    return 1
end

# Alias
alias am='aliaman'
alias alias-manager='aliaman'

