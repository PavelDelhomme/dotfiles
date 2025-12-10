#!/bin/bash
# =============================================================================
# TEST PATHMAN MIGRATION - Test de la migration pathman vers structure hybride
# =============================================================================
# Description: Teste que pathman fonctionne correctement après migration
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
TEST_DIR="/tmp/pathman_test_$$"
mkdir -p "$TEST_DIR"

echo "🧪 Test de migration pathman vers structure hybride..."
echo ""

# Test 1: Vérifier que les fichiers existent
echo "📁 Test 1: Vérification des fichiers..."
if [ ! -f "$DOTFILES_DIR/core/managers/pathman/core/pathman.sh" ]; then
    echo "❌ ERREUR: core/managers/pathman/core/pathman.sh non trouvé"
    exit 1
fi
if [ ! -f "$DOTFILES_DIR/shells/zsh/adapters/pathman.zsh" ]; then
    echo "❌ ERREUR: shells/zsh/adapters/pathman.zsh non trouvé"
    exit 1
fi
if [ ! -f "$DOTFILES_DIR/shells/bash/adapters/pathman.sh" ]; then
    echo "❌ ERREUR: shells/bash/adapters/pathman.sh non trouvé"
    exit 1
fi
echo "✅ Tous les fichiers existent"
echo ""

# Test 2: Vérifier que le code commun est valide
echo "📋 Test 2: Validation syntaxe code commun..."
if ! bash -n "$DOTFILES_DIR/core/managers/pathman/core/pathman.sh" 2>/dev/null; then
    echo "❌ ERREUR: Syntaxe invalide dans pathman.sh"
    exit 1
fi
echo "✅ Syntaxe valide"
echo ""

# Test 3: Test dans ZSH
echo "🐚 Test 3: Test dans ZSH..."
if command -v zsh >/dev/null 2>&1; then
    zsh -c "
        source $DOTFILES_DIR/shells/zsh/adapters/pathman.zsh
        if command -v pathman >/dev/null 2>&1; then
            echo '✅ pathman chargé dans ZSH'
        else
            echo '❌ ERREUR: pathman non chargé dans ZSH'
            exit 1
        fi
        if command -v add_to_path >/dev/null 2>&1; then
            echo '✅ add_to_path disponible dans ZSH'
        else
            echo '❌ ERREUR: add_to_path non disponible dans ZSH'
            exit 1
        fi
    " || exit 1
else
    echo "⚠️  ZSH non disponible, test ignoré"
fi
echo ""

# Test 4: Test dans Bash
echo "🐚 Test 4: Test dans Bash..."
if command -v bash >/dev/null 2>&1; then
    bash -c "
        source $DOTFILES_DIR/shells/bash/adapters/pathman.sh
        if command -v pathman >/dev/null 2>&1; then
            echo '✅ pathman chargé dans Bash'
        else
            echo '❌ ERREUR: pathman non chargé dans Bash'
            exit 1
        fi
        if command -v add_to_path >/dev/null 2>&1; then
            echo '✅ add_to_path disponible dans Bash'
        else
            echo '❌ ERREUR: add_to_path non disponible dans Bash'
            exit 1
        fi
    " || exit 1
else
    echo "⚠️  Bash non disponible, test ignoré"
fi
echo ""

# Test 5: Test fonction add_to_path
echo "🔧 Test 5: Test fonction add_to_path..."
TEST_PATH="$TEST_DIR/test_bin"
mkdir -p "$TEST_PATH"
bash -c "
    source $DOTFILES_DIR/shells/bash/adapters/pathman.sh
    OLD_PATH=\"\$PATH\"
    add_to_path \"$TEST_PATH\"
    if echo \"\$PATH\" | grep -q \"$TEST_PATH\"; then
        echo '✅ add_to_path fonctionne'
    else
        echo '❌ ERREUR: add_to_path ne fonctionne pas'
        exit 1
    fi
    export PATH=\"\$OLD_PATH\"
" || exit 1
echo ""

# Test 6: Test fonction clean_path
echo "🔧 Test 6: Test fonction clean_path..."
bash -c "
    source $DOTFILES_DIR/shells/bash/adapters/pathman.sh
    OLD_PATH=\"\$PATH\"
    export PATH=\"/invalid/path:\$PATH:/invalid/path2\"
    clean_path
    if ! echo \"\$PATH\" | grep -q \"/invalid/path\"; then
        echo '✅ clean_path fonctionne (invalides supprimés)'
    else
        echo '❌ ERREUR: clean_path ne supprime pas les invalides'
        exit 1
    fi
    export PATH=\"\$OLD_PATH\"
" || exit 1
echo ""

# Nettoyage
rm -rf "$TEST_DIR"

echo "✅ Tous les tests passés avec succès!"
echo ""
echo "📝 Prochaines étapes:"
echo "   1. Tester manuellement: pathman, pathman show, pathman add /tmp/test"
echo "   2. Vérifier que env.sh peut utiliser add_to_path()"
echo "   3. Si tout fonctionne, continuer avec autres managers simples"

