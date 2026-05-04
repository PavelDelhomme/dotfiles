# =============================================================================
# INSTALLMAN ADAPTER - Zsh : core POSIX (même aide / CLI que bash & matrice Fish)
# =============================================================================
# Le gros core interactif historique reste dans zsh/functions/installman/ si tu le charges ailleurs.
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
INSTALLMAN_CORE="$DOTFILES_DIR/core/managers/installman/core/installman.sh"

if [[ -f "$INSTALLMAN_CORE" ]]; then
    _dotfiles_installman_load_core() {
        emulate -L sh
        source "$INSTALLMAN_CORE"
    }
    _dotfiles_installman_load_core
    unfunction _dotfiles_installman_load_core 2>/dev/null || true
else
    echo "❌ installman core POSIX non trouvé: $INSTALLMAN_CORE"
    return 1
fi
