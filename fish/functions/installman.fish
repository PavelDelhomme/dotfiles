# =============================================================================
# INSTALLMAN - Délégation vers l’entrée unique (même logique que shells/fish/adapters)
# =============================================================================
# Ancien chemin : source ce fichier → fonction installman → installman_entry.sh
# =============================================================================

if not set -q DOTFILES_DIR
    if test -d "$HOME/dotfiles"
        set -g DOTFILES_DIR "$HOME/dotfiles"
    else
        echo "❌ Répertoire dotfiles introuvable (définir DOTFILES_DIR)" >&2
        return 1
    end
end

set -g INSTALLMAN_ENTRY "$DOTFILES_DIR/core/managers/installman/installman_entry.sh"

function installman
    if test -f "$INSTALLMAN_ENTRY"
        set -l _df "$DOTFILES_DIR"
        test -n "$_df"; or set _df "$HOME/dotfiles"
        env DOTFILES_DIR="$_df" sh "$INSTALLMAN_ENTRY" $argv
    else
        echo "❌ installman entry non trouvé: $INSTALLMAN_ENTRY" >&2
        return 1
    end
end
