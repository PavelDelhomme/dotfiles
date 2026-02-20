# =============================================================================
# INSTALLMAN ADAPTER - Fish : appelle le core unique (Zsh) via entry script
# =============================================================================
# Base unique = zsh/functions/installman. Ce wrapper lance l'entrée commune.
# =============================================================================

set -g DOTFILES_DIR (string default "$HOME/dotfiles" $DOTFILES_DIR)
set -g INSTALLMAN_ENTRY "$DOTFILES_DIR/core/managers/installman/installman_entry.sh"

function installman
    if test -f "$INSTALLMAN_ENTRY"
        sh "$INSTALLMAN_ENTRY" $argv
    else
        echo "❌ installman entry non trouvé: $INSTALLMAN_ENTRY"
        return 1
    end
end
