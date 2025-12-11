#!/bin/sh
# =============================================================================
# RUN_TESTS - Script d'exécution des tests dans Docker
# =============================================================================
# Description: Exécute tous les tests des managers dans Docker
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

set -e

DOTFILES_DIR="${DOTFILES_DIR:-/root/dotfiles}"
TEST_RESULTS_DIR="${TEST_RESULTS_DIR:-/root/test_results}"

# Créer le répertoire de résultats
mkdir -p "$TEST_RESULTS_DIR"

# Charger progress_bar
if [ -f "$DOTFILES_DIR/core/utils/progress_bar.sh" ]; then
    . "$DOTFILES_DIR/core/utils/progress_bar.sh"
fi

# Charger manager_tester
if [ -f "$DOTFILES_DIR/scripts/test/utils/manager_tester.sh" ]; then
    . "$DOTFILES_DIR/scripts/test/utils/manager_tester.sh"
fi

# Liste des managers à tester
# Managers migrés (à tester en priorité)
MIGRATED_MANAGERS="pathman manman searchman aliaman installman configman gitman fileman helpman cyberman devman virtman miscman"
# Managers non migrés (tests basiques)
UNMIGRATED_MANAGERS="netman sshman testman testzshman moduleman multimediaman cyberlearn"
# Tous les managers
ALL_MANAGERS="$MIGRATED_MANAGERS $UNMIGRATED_MANAGERS"

# Utiliser les managers migrés par défaut (test progressif)
MANAGERS="${TEST_MANAGERS:-$MIGRATED_MANAGERS}"

echo "═══════════════════════════════════════════════════════════════"
echo "🧪 TESTS AUTOMATISÉS DES MANAGERS (DOCKER)"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📦 Environnement: Docker (isolé et sécurisé)"
echo "📁 Dotfiles: $DOTFILES_DIR"
echo "📊 Résultats: $TEST_RESULTS_DIR"
echo ""
echo "📋 Managers à tester: $(echo $MANAGERS | wc -w) managers"
if [ "$MANAGERS" = "$MIGRATED_MANAGERS" ]; then
    echo "   → Mode: Managers migrés uniquement (test progressif)"
elif [ "$MANAGERS" = "$ALL_MANAGERS" ]; then
    echo "   → Mode: Tous les managers"
else
    echo "   → Mode: Personnalisé"
fi
echo ""

# Initialiser la progression
TOTAL_MANAGERS=$(echo "$MANAGERS" | wc -w)
progress_init "$TOTAL_MANAGERS" "Test des managers"

# Charger les dotfiles
echo "🔧 Chargement des dotfiles..."
export DOTFILES_DIR="$DOTFILES_DIR"
export DOTFILES_ZSH_PATH="$DOTFILES_DIR/zsh"

if [ -f "$DOTFILES_DIR/zsh/zshrc_custom" ]; then
    # Charger en silence pour éviter les erreurs non critiques
    . "$DOTFILES_DIR/zsh/zshrc_custom" >/dev/null 2>&1 || true
    echo "✅ Dotfiles chargés"
else
    echo "⚠️  zshrc_custom non trouvé"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🧪 DÉBUT DES TESTS"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Compteurs
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
COMPLETED=0

# Fichier de rapport détaillé
REPORT_FILE="$TEST_RESULTS_DIR/all_managers_test_report.txt"
DETAILED_REPORT="$TEST_RESULTS_DIR/detailed_report.txt"

# Initialiser les rapports
echo "═══════════════════════════════════════════════════════════════" > "$REPORT_FILE"
echo "RAPPORT DE TEST - $(date)" >> "$REPORT_FILE"
echo "═══════════════════════════════════════════════════════════════" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "═══════════════════════════════════════════════════════════════" > "$DETAILED_REPORT"
echo "RAPPORT DÉTAILLÉ - $(date)" >> "$DETAILED_REPORT"
echo "═══════════════════════════════════════════════════════════════" >> "$DETAILED_REPORT"
echo "" >> "$DETAILED_REPORT"

# Tester chaque manager individuellement
# Utiliser while read pour parsing correct (méthode robuste en sh)
echo "$MANAGERS" | tr ' ' '\n' | while read -r manager || [ -n "$manager" ]; do
    # Ignorer les lignes vides
    [ -z "$manager" ] && continue
    COMPLETED=$((COMPLETED + 1))
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$DETAILED_REPORT"
    echo "🧪 Test: $manager" | tee -a "$DETAILED_REPORT"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$DETAILED_REPORT"
    
    # Exécuter les tests et capturer la sortie
    # Utiliser une sous-shell pour capturer le code de sortie
    TEST_OUTPUT=$(test_manager "$manager" "zsh" 2>&1)
    TEST_EXIT=$?
    
    # Afficher la sortie
    echo "$TEST_OUTPUT" | tee -a "$DETAILED_REPORT"
    
    # Évaluer le résultat
    if [ $TEST_EXIT -eq 0 ]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo "✅ $manager: Tous les tests passés" | tee -a "$REPORT_FILE"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo "❌ $manager: Certains tests ont échoué" | tee -a "$REPORT_FILE"
    fi
    
    TOTAL_TESTS=$((TOTAL_TESTS + 5))  # 5 tests par manager
    
    echo "" | tee -a "$DETAILED_REPORT"
    
    # Mettre à jour la progression
    progress_update "$COMPLETED" "$PASSED_TESTS" "$FAILED_TESTS"
done

# Terminer la progression
progress_finish

# Résumé final
echo "" | tee -a "$REPORT_FILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$REPORT_FILE"
echo "RÉSUMÉ FINAL" | tee -a "$REPORT_FILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$REPORT_FILE"
echo "Total managers testés: $TOTAL_MANAGERS" | tee -a "$REPORT_FILE"
echo "Managers réussis: $PASSED_TESTS" | tee -a "$REPORT_FILE"
echo "Managers échoués: $FAILED_TESTS" | tee -a "$REPORT_FILE"
echo "Total tests: $TOTAL_TESTS" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ TESTS TERMINÉS"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📊 Résultats:"
echo "  ✅ Réussis: $PASSED_TESTS/$TOTAL_MANAGERS"
echo "  ❌ Échoués: $FAILED_TESTS/$TOTAL_MANAGERS"
echo ""
echo "📁 Rapports disponibles dans:"
echo "  - Résumé: $REPORT_FILE"
echo "  - Détail: $DETAILED_REPORT"
echo ""

# Code de sortie basé sur les résultats
if [ "$FAILED_TESTS" -eq 0 ]; then
    echo "🎉 Tous les tests sont passés !"
    exit 0
else
    echo "⚠️  $FAILED_TESTS manager(s) ont des problèmes"
    exit 1
fi

