#!/bin/bash
# =============================================================================
# TEST ALL COMPLETE - Tests complets de tous les systèmes
# =============================================================================
# Description: Lance tous les tests (syntaxe, managers, multi-shells, sync)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

REPORT_FILE="$DOTFILES_DIR/TEST_COMPLETE_REPORT.md"

echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║         TESTS COMPLETS - Tous les Systèmes                   ║${NC}"
echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Initialiser le rapport
cat > "$REPORT_FILE" << EOF
# 📊 Rapport de Tests Complets

**Date:** $(date)
**Dotfiles:** $DOTFILES_DIR

## Résultats des Tests

EOF

# Compteurs
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Fonction pour exécuter un test
run_test() {
    local test_name="$1"
    local test_script="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Test: $test_name${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ -f "$test_script" ] && bash "$test_script" >> "$REPORT_FILE" 2>&1; then
        echo -e "${GREEN}✅ $test_name: RÉUSSI${NC}"
        echo "**✅ $test_name:** RÉUSSI" >> "$REPORT_FILE"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ $test_name: ÉCHOUÉ${NC}"
        echo "**❌ $test_name:** ÉCHOUÉ" >> "$REPORT_FILE"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo ""
}

# Test 1: Vérifications projet (syntaxe core/adapters/scripts install + URLs)
run_test "Vérifications projet (syntaxe + URLs)" "$DOTFILES_DIR/scripts/test/run_checks.sh"

# Test 2: Tests des managers migrés (Docker)
run_test "Tests des managers migrés (Docker)" "$DOTFILES_DIR/scripts/test/test_migrated_managers.sh"

# Test 3: Tests multi-shells
run_test "Tests multi-shells" "$DOTFILES_DIR/scripts/test/test_multi_shells.sh"

# Test 4: Tests de synchronisation
run_test "Tests de synchronisation" "$DOTFILES_DIR/scripts/test/test_sync.sh"

# Résumé final
echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}📊 RÉSUMÉ FINAL${NC}"
echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════${NC}"
echo -e "Total: ${BOLD}$TOTAL_TESTS${NC} tests"
echo -e "Réussis: ${GREEN}${BOLD}$PASSED_TESTS${NC}"
echo -e "Échoués: ${RED}${BOLD}$FAILED_TESTS${NC}"

if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "Taux de réussite: ${BOLD}${SUCCESS_RATE}%${NC}"
fi

# Ajouter le résumé au rapport
cat >> "$REPORT_FILE" << EOF

## Résumé

- **Total:** $TOTAL_TESTS tests
- **Réussis:** $PASSED_TESTS
- **Échoués:** $FAILED_TESTS
- **Taux de réussite:** $([ $TOTAL_TESTS -gt 0 ] && echo "$((PASSED_TESTS * 100 / TOTAL_TESTS))%" || echo "0%")

EOF

echo ""
echo -e "${GREEN}📊 Rapport généré: $REPORT_FILE${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ Tous les tests sont passés !${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  $FAILED_TESTS test(s) ont échoué${NC}"
    exit 1
fi

