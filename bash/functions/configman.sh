#!/bin/bash
# =============================================================================
# CONFIGMAN - Configuration Manager pour Bash (Wrapper)
# =============================================================================
# Wrapper pour charger configman depuis le répertoire dotfiles
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

CONFIGMAN_CORE="$DOTFILES_DIR/bash/functions/configman/core/configman.sh"

# Charger le core si disponible
if [ -f "$CONFIGMAN_CORE" ]; then
    source "$CONFIGMAN_CORE"
else
    echo "❌ configman (Bash) non trouvé. Exécutez la conversion d'abord."
    return 1 2>/dev/null || exit 1
fi

