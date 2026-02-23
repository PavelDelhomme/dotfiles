#!/bin/sh
# =============================================================================
# RUN_CHECKS - Vérifications du projet (scripts, managers, core, URLs)
# =============================================================================
# À lancer en local ou dans Docker. En Docker : rien n'impacte ta machine.
# Usage: bash scripts/test/run_checks.sh
#        make test-checks
# =============================================================================

set +e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SCRIPT_DIR="${DOTFILES_DIR}/scripts"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo "${CYAN}  Vérifications du projet (core, managers, scripts, URLs)${NC}"
echo "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

FAILED=0

# 1. Syntaxe des cores POSIX (core/managers/*/core/*.sh)
echo "${BLUE}[1/4] Syntaxe des cores POSIX (core/managers)${NC}"
for f in "$DOTFILES_DIR"/core/managers/*/core/*.sh; do
    [ -f "$f" ] || continue
    if sh -n "$f" 2>/dev/null; then
        printf "  ${GREEN}✓${NC} %s\n" "$(echo "$f" | sed "s|$DOTFILES_DIR/||")"
    else
        printf "  ${RED}✗${NC} %s\n" "$(echo "$f" | sed "s|$DOTFILES_DIR/||")"
        sh -n "$f" 2>&1 | head -3
        FAILED=$((FAILED + 1))
    fi
done
echo ""

# 2. Syntaxe des adapters ZSH (shells/zsh/adapters/*.zsh)
echo "${BLUE}[2/4] Syntaxe des adapters ZSH${NC}"
for f in "$DOTFILES_DIR"/shells/zsh/adapters/*.zsh; do
    [ -f "$f" ] || continue
    if zsh -n "$f" 2>/dev/null; then
        printf "  ${GREEN}✓${NC} %s\n" "$(echo "$f" | sed "s|$DOTFILES_DIR/||")"
    else
        printf "  ${RED}✗${NC} %s\n" "$(echo "$f" | sed "s|$DOTFILES_DIR/||")"
        zsh -n "$f" 2>&1 | head -3
        FAILED=$((FAILED + 1))
    fi
done
echo ""

# 3. Scripts install (syntaxe bash)
echo "${BLUE}[3/4] Syntaxe scripts install (apps)${NC}"
for f in "$SCRIPT_DIR"/install/apps/*.sh; do
    [ -f "$f" ] || continue
    if bash -n "$f" 2>/dev/null; then
        printf "  ${GREEN}✓${NC} %s\n" "$(basename "$f")"
    else
        printf "  ${RED}✗${NC} %s\n" "$(basename "$f")"
        bash -n "$f" 2>&1 | head -3
        FAILED=$((FAILED + 1))
    fi
done
echo ""

# 4. URLs de téléchargement (Cursor, Chrome, Flutter, etc.)
echo "${BLUE}[4/4] URLs de téléchargement (Cursor, Chrome, Flutter...)${NC}"
if [ -f "$SCRIPT_DIR/install/check_download_urls.sh" ]; then
    if bash "$SCRIPT_DIR/install/check_download_urls.sh"; then
        echo "  ${GREEN}✓ Toutes les URLs critiques OK${NC}"
    else
        echo "  ${YELLOW}⚠ Une ou plusieurs URLs ont échoué (réseau ou URL obsolète)${NC}"
        FAILED=$((FAILED + 1))
    fi
else
    echo "  ${YELLOW}⚠ check_download_urls.sh non trouvé${NC}"
fi
echo ""

echo "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
if [ $FAILED -eq 0 ]; then
    echo "${GREEN}✅ Toutes les vérifications sont passées.${NC}"
    echo ""
    echo "Pour tester les managers dans Docker (sans impacter ta machine):"
    echo "  make test          # Lance tous les tests managers dans Docker"
    echo "  make docker-in     # Ouvre un shell dans le conteneur pour tester à la main"
    exit 0
else
    echo "${RED}❌ $FAILED vérification(s) en échec.${NC}"
    exit 1
fi
