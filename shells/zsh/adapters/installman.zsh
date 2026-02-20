# =============================================================================
# INSTALLMAN ADAPTER - Zsh : charge le core Zsh (implémentation canonique)
# =============================================================================
# Base unique = ce core (pagination, log, tous les outils). Pas de sous-processus.
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
INSTALLMAN_CORE="$DOTFILES_DIR/zsh/functions/installman/core/installman.zsh"

if [[ -f "$INSTALLMAN_CORE" ]]; then
    source "$INSTALLMAN_CORE"
else
    echo "❌ installman core non trouvé: $INSTALLMAN_CORE"
    return 1
fi
