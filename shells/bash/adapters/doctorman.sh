#!/usr/bin/env bash
# =============================================================================
# DOCTORMAN ADAPTER — Bash
# =============================================================================
DOTFILES_DIR="${DOTFILES_DIR:-${HOME:-/}/dotfiles}"
DOCTORMAN_CORE="$DOTFILES_DIR/core/managers/doctorman/core/doctorman.sh"
if [[ -f "$DOCTORMAN_CORE" ]]; then
    # shellcheck source=doctorman.sh
    source "$DOCTORMAN_CORE"
else
    echo "❌ doctorman core introuvable: $DOCTORMAN_CORE"
    return 1 2>/dev/null || exit 1
fi
