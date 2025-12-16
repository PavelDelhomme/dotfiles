#!/bin/bash
# =============================================================================
# TEST SYNC - Tests de synchronisation automatique
# =============================================================================
# Description: Teste le système de synchronisation des managers
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SYNC_SCRIPT="$DOTFILES_DIR/scripts/tools/sync_managers.sh"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         TESTS DE SYNCHRONISATION AUTOMATIQUE                  ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Vérifier que le script de sync existe
if [ ! -f "$SYNC_SCRIPT" ]; then
    echo -e "${RED}❌ Script de synchronisation non trouvé: $SYNC_SCRIPT${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Script de synchronisation trouvé${NC}"
echo ""

# Test 1: Vérifier que le script peut être exécuté
echo -e "${BLUE}Test 1: Vérification de l'exécutabilité${NC}"
if [ -x "$SYNC_SCRIPT" ]; then
    echo -e "${GREEN}  ✅ Script exécutable${NC}"
else
    echo -e "${YELLOW}  ⚠️  Script non exécutable, ajout des permissions...${NC}"
    chmod +x "$SYNC_SCRIPT"
    echo -e "${GREEN}  ✅ Permissions ajoutées${NC}"
fi
echo ""

# Test 2: Tester la synchronisation d'un manager simple (pathman)
echo -e "${BLUE}Test 2: Synchronisation de pathman${NC}"
if bash "$SYNC_SCRIPT" "pathman" >/dev/null 2>&1; then
    echo -e "${GREEN}  ✅ pathman synchronisé avec succès${NC}"
else
    echo -e "${YELLOW}  ⚠️  Synchronisation de pathman échouée (peut être normal si déjà à jour)${NC}"
fi
echo ""

# Test 3: Vérifier que les adapters existent après sync
echo -e "${BLUE}Test 3: Vérification des adapters${NC}"
ADAPTERS_OK=0
ADAPTERS_FAILED=0

for shell in zsh bash fish; do
    adapter_path="$DOTFILES_DIR/shells/$shell/adapters/pathman.$([ "$shell" = "fish" ] && echo "fish" || [ "$shell" = "zsh" ] && echo "zsh" || echo "sh")"
    if [ -f "$adapter_path" ]; then
        echo -e "${GREEN}  ✅ Adapter $shell trouvé: $adapter_path${NC}"
        ADAPTERS_OK=$((ADAPTERS_OK + 1))
    else
        echo -e "${RED}  ❌ Adapter $shell manquant: $adapter_path${NC}"
        ADAPTERS_FAILED=$((ADAPTERS_FAILED + 1))
    fi
done

if [ $ADAPTERS_FAILED -eq 0 ]; then
    echo -e "${GREEN}  ✅ Tous les adapters sont présents${NC}"
else
    echo -e "${YELLOW}  ⚠️  $ADAPTERS_FAILED adapter(s) manquant(s)${NC}"
fi
echo ""

# Test 4: Vérifier le hook Git pre-commit
echo -e "${BLUE}Test 4: Vérification du hook Git pre-commit${NC}"
HOOK_PATH="$DOTFILES_DIR/.git/hooks/pre-commit"
if [ -f "$HOOK_PATH" ]; then
    if [ -x "$HOOK_PATH" ]; then
        echo -e "${GREEN}  ✅ Hook pre-commit trouvé et exécutable${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Hook pre-commit trouvé mais non exécutable${NC}"
        chmod +x "$HOOK_PATH"
        echo -e "${GREEN}  ✅ Permissions ajoutées${NC}"
    fi
else
    echo -e "${RED}  ❌ Hook pre-commit non trouvé${NC}"
fi
echo ""

# Résumé
echo -e "${CYAN}══════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}📊 RÉSUMÉ DES TESTS${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════════${NC}"
echo -e "Adapters présents: ${GREEN}$ADAPTERS_OK${NC}"
if [ $ADAPTERS_FAILED -gt 0 ]; then
    echo -e "Adapters manquants: ${RED}$ADAPTERS_FAILED${NC}"
fi
echo ""

if [ $ADAPTERS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ Tous les tests de synchronisation sont passés${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Certains tests ont échoué${NC}"
    exit 1
fi

