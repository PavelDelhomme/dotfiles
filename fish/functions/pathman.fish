# =============================================================================
# PATHMAN - Path Manager pour Fish (Wrapper)
# =============================================================================
# Wrapper pour charger pathman depuis le répertoire dotfiles
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

set -g PATHMAN_CORE "$DOTFILES_DIR/fish/functions/pathman/core/pathman.fish"

# Charger le core si disponible
if test -f "$PATHMAN_CORE"
    source "$PATHMAN_CORE"
else
    echo "❌ pathman (Fish) non trouvé. Exécutez la conversion d'abord."
    return 1
end

