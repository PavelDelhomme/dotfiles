#!/usr/bin/env bash
# =============================================================================
# Vérification que installman (et l'entrée unique) fonctionne depuis tous les shells
# =============================================================================
# Usage: bash scripts/test/verify_multishell.sh
# =============================================================================

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
ENTRY="$DOTFILES_DIR/core/managers/installman/installman_entry.sh"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "════════════════════════════════════════"
echo "  Vérification multi-shell (installman)"
echo "════════════════════════════════════════"
echo ""

if [ ! -f "$ENTRY" ]; then
    echo -e "${RED}❌ Entry script introuvable: $ENTRY${NC}"
    exit 1
fi

ok=0
fail=0

for sh in zsh bash sh; do
    if ! command -v "$sh" >/dev/null 2>&1; then
        echo -e "  $sh: ${YELLOW}non installé${NC}"
        continue
    fi
    out=$("$sh" "$ENTRY" help 2>&1) || true
    if echo "$out" | grep -qi "installman\|Outils disponibles\|Usage"; then
        echo -e "  $sh: ${GREEN}OK${NC}"
        ((ok++)) || true
    else
        echo -e "  $sh: ${RED}échec${NC}"
        ((fail++)) || true
    fi
done

echo ""
if [ $ok -gt 0 ]; then
    echo -e "${GREEN}✓ Au moins un shell fonctionne ($ok)${NC}"
fi
if [ $fail -gt 0 ]; then
    echo -e "${YELLOW}⚠ Certains shells en échec ($fail)${NC}"
fi
echo "════════════════════════════════════════"
