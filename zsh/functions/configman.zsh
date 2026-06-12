#!/bin/zsh
# =============================================================================
# CONFIGMAN WRAPPER - point d'entrée Zsh (délègue au core POSIX)
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
CONFIGMAN_ADAPTER="$DOTFILES_DIR/shells/zsh/adapters/configman.zsh"
CONFIGMAN_CORE="$DOTFILES_DIR/core/managers/configman/core/configman.sh"

if [ -f "$CONFIGMAN_ADAPTER" ]; then
    source "$CONFIGMAN_ADAPTER"
elif [ -f "$CONFIGMAN_CORE" ]; then
    source "$CONFIGMAN_CORE"
else
    echo "❌ Erreur: configman core non trouvé"
    return 1
fi
