#!/bin/zsh
# =============================================================================
# NETMAN ADAPTER - Adapter ZSH pour netman
# =============================================================================
# Le core est POSIX sh : on le source en émulation sh pour éviter les écarts
# zsh (ex. chaînes multi-lignes entre "…" autrefois).
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
NETMAN_CORE="$DOTFILES_DIR/core/managers/netman/core/netman.sh"

if [ -f "$NETMAN_CORE" ]; then
    emulate -L sh
    # shellcheck source=/dev/null
    source "$NETMAN_CORE"
else
    echo "❌ Erreur: netman core non trouvé: $NETMAN_CORE"
    return 1
fi
