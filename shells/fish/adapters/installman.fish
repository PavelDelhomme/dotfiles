# =============================================================================
# INSTALLMAN ADAPTER - Fish : appelle le core unique (Zsh) via entry script
# =============================================================================
# Base unique = zsh/functions/installman. Ce wrapper lance l'entrée commune.
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g INSTALLMAN_ENTRY "$DOTFILES_DIR/core/managers/installman/installman_entry.sh"

function installman
    if test -f "$INSTALLMAN_ENTRY"
        set -l _df "$DOTFILES_DIR"
        test -n "$_df"; or set _df "$HOME/dotfiles"
        env DOTFILES_DIR="$_df" sh "$INSTALLMAN_ENTRY" $argv
    else
        echo "❌ installman entry non trouvé: $INSTALLMAN_ENTRY"
        return 1
    end
end
