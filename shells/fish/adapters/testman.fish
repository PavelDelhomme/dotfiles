# =============================================================================
# TESTMAN ADAPTER - Adapter Fish pour testman
# =============================================================================
# Description: Charge le core POSIX de testman et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g TESTMAN_CORE "$DOTFILES_DIR/core/managers/testman/core/testman.sh"

if test -f "$TESTMAN_CORE"
    function testman
        bash -c 'source "$1"; shift; testman "$@"' _ "$TESTMAN_CORE" $argv
    end
else
    echo "❌ Erreur: testman core non trouvé: $TESTMAN_CORE"
    return 1
end

