# =============================================================================
# SSHMAN ADAPTER - Adapter Fish pour sshman
# =============================================================================
# Description: Charge le core POSIX de sshman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g SSHMAN_CORE "$DOTFILES_DIR/core/managers/sshman/core/sshman.sh"

if test -f "$SSHMAN_CORE"
    function sshman
        bash -c 'source "$1"; shift; sshman "$@"' _ "$SSHMAN_CORE" $argv
    end
else
    echo "❌ Erreur: sshman core non trouvé: $SSHMAN_CORE"
    return 1
end

