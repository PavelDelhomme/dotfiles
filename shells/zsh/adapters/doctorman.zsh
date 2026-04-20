#!/usr/bin/env zsh
# =============================================================================
# DOCTORMAN ADAPTER — ZSH
# =============================================================================
DOTFILES_DIR="${DOTFILES_DIR:-${HOME:-/}/dotfiles}"
DOCTORMAN_CORE="$DOTFILES_DIR/core/managers/doctorman/core/doctorman.sh"
if [[ -f "$DOCTORMAN_CORE" ]]; then
    source "$DOCTORMAN_CORE"
else
    echo "❌ doctorman core introuvable: $DOCTORMAN_CORE"
    return 1
fi
