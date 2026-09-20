#!/bin/zsh
# =============================================================================
# DISPLAYMAN ADAPTER - Adapter ZSH pour displayman
# =============================================================================
# Description : charge le core POSIX de displayman pour ZSH.
# Le core est POSIX sh : emulate -L sh pour éviter les écarts zsh
# (heredocs non quotés avec apostrophes françaises, etc.).
# Auteur      : Paul Delhomme
# Version     : 1.1
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DISPLAYMAN_CORE="$DOTFILES_DIR/core/managers/displayman/core/displayman.sh"

if [ -f "$DISPLAYMAN_CORE" ]; then
    emulate -L sh
    # shellcheck source=/dev/null
    source "$DISPLAYMAN_CORE"
else
    echo "❌ Erreur: displayman core non trouvé: $DISPLAYMAN_CORE"
    return 1
fi
