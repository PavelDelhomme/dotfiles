# =============================================================================
# CONFIGMAN - Configuration Manager pour Fish (Wrapper)
# =============================================================================
# Wrapper pour charger configman depuis le répertoire dotfiles
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

set -g CONFIGMAN_CORE "$DOTFILES_DIR/fish/functions/configman/core/configman.fish"

# Charger le core si disponible
if test -f "$CONFIGMAN_CORE"
    source "$CONFIGMAN_CORE"
else
    echo "❌ configman (Fish) non trouvé. Exécutez la conversion d'abord."
    return 1
end

