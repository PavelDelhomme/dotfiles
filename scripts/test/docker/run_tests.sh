#!/bin/sh
# =============================================================================
# RUN_TESTS - Script d'exécution des tests dans Docker
# =============================================================================
# Description: Exécute tous les tests des managers dans Docker
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================
# Pas de set -e : on teste TOUS les managers même si l'un échoue, puis on affiche le résumé.

DOTFILES_DIR="${DOTFILES_DIR:-/root/dotfiles}"
TEST_RESULTS_DIR="${TEST_RESULTS_DIR:-/root/test_results}"

# Créer le répertoire de résultats
mkdir -p "$TEST_RESULTS_DIR"

if [ -f "$DOTFILES_DIR/scripts/test/lib/dotfiles_docker_git_safe.sh" ]; then
    # shellcheck source=/dev/null
    . "$DOTFILES_DIR/scripts/test/lib/dotfiles_docker_git_safe.sh"
    dotfiles_docker_git_trust_repo 2>/dev/null || true
fi

# Charger progress_bar
if [ -f "$DOTFILES_DIR/core/utils/progress_bar.sh" ]; then
    . "$DOTFILES_DIR/core/utils/progress_bar.sh"
fi

# Charger manager_tester
if [ -f "$DOTFILES_DIR/scripts/test/utils/manager_tester.sh" ]; then
    . "$DOTFILES_DIR/scripts/test/utils/manager_tester.sh"
fi

# Listes canoniques (scripts/test/config/*.list)
if [ -f "$DOTFILES_DIR/scripts/test/lib/dotfiles_test_config.sh" ]; then
    # shellcheck source=/dev/null
    . "$DOTFILES_DIR/scripts/test/lib/dotfiles_test_config.sh"
    MIGRATED_MANAGERS=$(dotfiles_migrated_managers_space)
    UNMIGRATED_MANAGERS=$(dotfiles_unmigrated_managers_space)
else
    MIGRATED_MANAGERS="pathman manman searchman aliaman installman configman gitman fileman helpman cyberman devman virtman miscman doctorman"
    UNMIGRATED_MANAGERS="netman sshman testman testzshman moduleman multimediaman cyberlearn"
fi
ALL_MANAGERS="$MIGRATED_MANAGERS $UNMIGRATED_MANAGERS"

# Utiliser les managers migrés par défaut (test progressif)
MANAGERS="${TEST_MANAGERS:-$MIGRATED_MANAGERS}"

# Matrice shells : zsh bash fish (override avec TEST_SHELLS="zsh" pour aller plus vite)
TEST_SHELLS="${TEST_SHELLS:-zsh bash fish}"

echo "═══════════════════════════════════════════════════════════════"
echo "🧪 TESTS AUTOMATISÉS DES MANAGERS (DOCKER)"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📦 Environnement: Docker (isolé et sécurisé)"
echo "📁 Dotfiles: $DOTFILES_DIR"
echo "📊 Résultats: $TEST_RESULTS_DIR"
echo ""
echo "📋 Managers à tester: $(echo $MANAGERS | wc -w) managers"
echo "🐚 Shells (manager_tester): $TEST_SHELLS"
if [ "$MANAGERS" = "$MIGRATED_MANAGERS" ]; then
    echo "   → Mode: Managers migrés uniquement (test progressif)"
elif [ "$MANAGERS" = "$ALL_MANAGERS" ]; then
    echo "   → Mode: Tous les managers"
else
    echo "   → Mode: Personnalisé"
fi
echo ""

# Progression = une cellule (manager × shell)
NM=$(echo "$MANAGERS" | wc -w)
NS=$(echo "$TEST_SHELLS" | wc -w)
TOTAL_CELLS=$((NM * NS))
progress_init "$TOTAL_CELLS" "Test des managers (matrice shells)"

# Charger les dotfiles
echo "🔧 Chargement des dotfiles..."
export DOTFILES_DIR="$DOTFILES_DIR"
export DOTFILES_ZSH_PATH="$DOTFILES_DIR/zsh"
export TEST_RESULTS_DIR="$TEST_RESULTS_DIR"

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
# Créer un fichier temporaire avec les managers (une ligne par manager)
TEMP_MANAGERS_FILE="/tmp/dotfiles_test_managers_$$"
echo "$MANAGERS" | tr ' ' '\n' | grep -v '^$' > "$TEMP_MANAGERS_FILE"

TIMEOUT_PATH=""
if command -v timeout >/dev/null 2>&1; then
    TIMEOUT_PATH=$(command -v timeout)
elif command -v gtimeout >/dev/null 2>&1; then
    TIMEOUT_PATH=$(command -v gtimeout)
elif [ -f "/usr/bin/timeout" ] && [ -x "/usr/bin/timeout" ]; then
    TIMEOUT_PATH="/usr/bin/timeout"
elif [ -f "/usr/sbin/timeout" ] && [ -x "/usr/sbin/timeout" ]; then
    TIMEOUT_PATH="/usr/sbin/timeout"
fi

# Lire chaque manager depuis le fichier
while read -r manager || [ -n "$manager" ]; do
    [ -z "$manager" ] && continue

    for shell in $TEST_SHELLS; do
        COMPLETED=$((COMPLETED + 1))

        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$DETAILED_REPORT"
        echo "🧪 Test: $manager ($shell)" | tee -a "$DETAILED_REPORT"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$DETAILED_REPORT"

        if [ -n "$TIMEOUT_PATH" ] && [ -x "$TIMEOUT_PATH" ]; then
            TEST_OUTPUT=$("$TIMEOUT_PATH" 30 sh -c '. "$DOTFILES_DIR/scripts/test/utils/manager_tester.sh" && test_manager '"'$manager'"' '"'$shell'"' 2>&1')
            TEST_EXIT=$?
            if [ "$TEST_EXIT" -eq 124 ]; then
                echo "⚠️  Timeout (30s) $manager ($shell)" | tee -a "$DETAILED_REPORT"
                TEST_EXIT=1
            fi
        else
            TEST_OUTPUT=$(sh -c '. "$DOTFILES_DIR/scripts/test/utils/manager_tester.sh" && test_manager '"'$manager'"' '"'$shell'"' 2>&1')
            TEST_EXIT=$?
        fi

        echo "$TEST_OUTPUT" | tee -a "$DETAILED_REPORT"

        if [ "$TEST_EXIT" -eq 0 ]; then
            PASSED_TESTS=$((PASSED_TESTS + 1))
            echo "✅ $manager ($shell): OK" | tee -a "$REPORT_FILE"
        else
            FAILED_TESTS=$((FAILED_TESTS + 1))
            echo "❌ $manager ($shell): échec" | tee -a "$REPORT_FILE"
        fi

        if [ "$manager" = "pathman" ] || [ "$manager" = "doctorman" ]; then
            TOTAL_TESTS=$((TOTAL_TESTS + 6))
        elif [ "$manager" = "gitman" ] && [ "$shell" = "zsh" ]; then
            TOTAL_TESTS=$((TOTAL_TESTS + 6))
        else
            TOTAL_TESTS=$((TOTAL_TESTS + 5))
        fi

        echo "" | tee -a "$DETAILED_REPORT"
        progress_update "$COMPLETED" "$PASSED_TESTS" "$FAILED_TESTS"
    done
done < "$TEMP_MANAGERS_FILE"

# Nettoyer le fichier temporaire
rm -f "$TEMP_MANAGERS_FILE"

# Terminer la progression
progress_finish

# Résumé final
echo "" | tee -a "$REPORT_FILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$REPORT_FILE"
echo "RÉSUMÉ FINAL" | tee -a "$REPORT_FILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$REPORT_FILE"
echo "Total cellules (manager × shell): $TOTAL_CELLS" | tee -a "$REPORT_FILE"
echo "Cellules réussies: $PASSED_TESTS" | tee -a "$REPORT_FILE"
echo "Cellules en échec: $FAILED_TESTS" | tee -a "$REPORT_FILE"
echo "Total tests: $TOTAL_TESTS" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ TESTS TERMINÉS"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📊 Résultats:"
echo "  ✅ Réussis: $PASSED_TESTS/$TOTAL_CELLS"
echo "  ❌ Échoués: $FAILED_TESTS/$TOTAL_CELLS"
echo ""
echo "📁 Rapports disponibles dans:"
echo "  - Résumé: $REPORT_FILE"
echo "  - Détail: $DETAILED_REPORT"
echo ""

# Code de sortie basé sur les résultats
if [ "$FAILED_TESTS" -eq 0 ]; then
    echo "🎉 Tous les tests sont passés !"
    _matrix_rc=0
else
    echo "⚠️  $FAILED_TESTS cellule(s) en échec"
    _matrix_rc=1
fi

# Matrice sous-commandes (optionnel : RUN_SUBCOMMAND_MATRIX=1 ou make test-docker-full)
if [ "${RUN_SUBCOMMAND_MATRIX:-0}" = "1" ] && command -v bash >/dev/null 2>&1; then
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "🧪 Matrice sous-commandes (scripts/test/manager_subcommand_matrix.sh)"
    echo "═══════════════════════════════════════════════════════════════"
    export TEST_MANAGERS="$MANAGERS"
    export TEST_SHELLS
    if ! bash "$DOTFILES_DIR/scripts/test/manager_subcommand_matrix.sh"; then
        _matrix_rc=1
    fi
fi

exit "$_matrix_rc"

