#!/bin/bash
# =============================================================================
# INSTALLMAN ADAPTER - Bash : core POSIX (aligné zsh adapter & matrice Fish)
# =============================================================================
# Pour l’entrée zsh historique : installman_entry.sh ou zsh/functions/installman/.
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
INSTALLMAN_CORE="$DOTFILES_DIR/core/managers/installman/core/installman.sh"

if [[ -f "$INSTALLMAN_CORE" ]]; then
    # shellcheck source=core/managers/installman/core/installman.sh
    source "$INSTALLMAN_CORE"
else
    echo "❌ installman core POSIX non trouvé: $INSTALLMAN_CORE"
    return 1
fi

export -f installman 2>/dev/null || true
