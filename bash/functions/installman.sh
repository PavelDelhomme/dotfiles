#!/bin/bash
# =============================================================================
# INSTALLMAN - Installation Manager pour Bash (Wrapper)
# =============================================================================
# Wrapper pour charger installman depuis le répertoire dotfiles
# Compatible avec la structure ZSH mais adapté pour Bash
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

INSTALLMAN_CORE="$DOTFILES_DIR/bash/functions/installman/core/installman.sh"

# Charger le core si disponible
if [ -f "$INSTALLMAN_CORE" ]; then
    source "$INSTALLMAN_CORE"
else
    echo "❌ installman (Bash) non trouvé. Exécutez la conversion d'abord."
    return 1 2>/dev/null || exit 1
fi

