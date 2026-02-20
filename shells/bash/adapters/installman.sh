#!/bin/bash
# =============================================================================
# INSTALLMAN ADAPTER - Bash : appelle le core unique (Zsh) via entry script
# =============================================================================
# Base unique = zsh/functions/installman (pagination, log, tous les outils).
# Ce script définit la fonction installman pour lancer l'entrée commune.
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
INSTALLMAN_ENTRY="$DOTFILES_DIR/core/managers/installman/installman_entry.sh"

installman() {
    if [[ -x "$INSTALLMAN_ENTRY" || -f "$INSTALLMAN_ENTRY" ]]; then
        "$INSTALLMAN_ENTRY" "$@"
    else
        echo "❌ installman entry non trouvé: $INSTALLMAN_ENTRY"
        return 1
    fi
}

export -f installman 2>/dev/null || true
