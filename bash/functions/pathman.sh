#!/bin/bash
# =============================================================================
# PATHMAN - Path Manager pour Bash (Wrapper)
# =============================================================================
# Wrapper pour charger pathman depuis le répertoire dotfiles
# =============================================================================

# Détecter le répertoire dotfiles
if [ -z "$DOTFILES_DIR" ]; then
    if [ -d "$HOME/dotfiles" ]; then
        DOTFILES_DIR="$HOME/dotfiles"
    else
        echo "❌ Répertoire dotfiles introuvable"
        return 1 2>/dev/null || exit 1
    fi
fi

PATHMAN_CORE="$DOTFILES_DIR/bash/functions/pathman/core/pathman.sh"

# Charger le core si disponible
if [ -f "$PATHMAN_CORE" ]; then
    source "$PATHMAN_CORE"
else
    echo "❌ pathman (Bash) non trouvé. Exécutez la conversion d'abord."
    return 1 2>/dev/null || exit 1
fi

