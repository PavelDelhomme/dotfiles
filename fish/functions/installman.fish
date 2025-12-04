# =============================================================================
# INSTALLMAN - Installation Manager pour Fish (Wrapper)
# =============================================================================
# Wrapper pour charger installman depuis le répertoire dotfiles
# Compatible avec la structure ZSH mais adapté pour Fish
# =============================================================================

# Détecter le répertoire dotfiles
if not set -q DOTFILES_DIR
    if test -d "$HOME/dotfiles"
        set -g DOTFILES_DIR "$HOME/dotfiles"
    else
        echo "❌ Répertoire dotfiles introuvable"
        return 1
    end
end

set -g INSTALLMAN_CORE "$DOTFILES_DIR/fish/functions/installman/core/installman.fish"

# Charger le core si disponible
if test -f "$INSTALLMAN_CORE"
    source "$INSTALLMAN_CORE"
else
    echo "❌ installman (Fish) non trouvé. Exécutez la conversion d'abord."
    return 1
end

