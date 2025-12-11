#!/bin/sh
# =============================================================================
# TEST_ALL_MANAGERS - Test automatisé de tous les managers
# =============================================================================
# Description: Teste tous les managers dans un environnement Docker sécurisé
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger progress_bar
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
PROGRESS_BAR="$DOTFILES_DIR/core/utils/progress_bar.sh"

if [ -f "$PROGRESS_BAR" ]; then
    . "$PROGRESS_BAR"
fi

# =============================================================================
# Configuration
# =============================================================================
DOCKER_IMAGE="dotfiles-test:latest"
DOCKER_CONTAINER="dotfiles-test-container"
TEST_RESULTS_DIR="${TEST_RESULTS_DIR:-$DOTFILES_DIR/test_results}"
REPORT_FILE="$TEST_RESULTS_DIR/all_managers_test_report.txt"

# Liste des managers à tester
MANAGERS="pathman manman searchman aliaman installman configman gitman fileman helpman cyberman devman virtman miscman netman sshman testman testzshman moduleman multimediaman cyberlearn"

# =============================================================================
# Fonctions
# =============================================================================

# Construire l'image Docker
build_docker_image() {
    echo "🔨 Construction de l'image Docker..."
    if docker build -f "$DOTFILES_DIR/scripts/test/docker/Dockerfile.test" -t "$DOCKER_IMAGE" "$DOTFILES_DIR" 2>&1; then
        echo "✅ Image Docker construite avec succès"
        return 0
    else
        echo "❌ Erreur lors de la construction de l'image Docker"
        return 1
    fi
}

# Lancer les tests dans Docker
run_tests_in_docker() {
    echo "🧪 Lancement des tests dans Docker..."
    
    # Créer le répertoire de résultats
    mkdir -p "$TEST_RESULTS_DIR"
    
    # Lancer le conteneur et exécuter les tests
    docker run --rm \
        --name "$DOCKER_CONTAINER" \
        -v "$DOTFILES_DIR:/root/dotfiles:ro" \
        -v "$TEST_RESULTS_DIR:/root/test_results:rw" \
        -e DOTFILES_DIR=/root/dotfiles \
        -e TEST_RESULTS_DIR=/root/test_results \
        "$DOCKER_IMAGE" \
        /bin/sh -c "
            # Charger les dotfiles
            export DOTFILES_DIR=/root/dotfiles
            export DOTFILES_ZSH_PATH=\"\$DOTFILES_DIR/zsh\"
            if [ -f \"\$DOTFILES_DIR/zsh/zshrc_custom\" ]; then
                . \"\$DOTFILES_DIR/zsh/zshrc_custom\" 2>/dev/null || true
            fi
            
            # Charger manager_tester
            if [ -f \"\$DOTFILES_DIR/scripts/test/utils/manager_tester.sh\" ]; then
                . \"\$DOTFILES_DIR/scripts/test/utils/manager_tester.sh\"
            fi
            
            # Tester chaque manager
            echo '═══════════════════════════════════════════════════════════════'
            echo 'TESTS AUTOMATISÉS DE TOUS LES MANAGERS'
            echo '═══════════════════════════════════════════════════════════════'
            echo ''
            
            total_managers=0
            passed_managers=0
            failed_managers=0
            
            for manager in $MANAGERS; do
                total_managers=\$((total_managers + 1))
                if test_manager \"\$manager\" zsh; then
                    passed_managers=\$((passed_managers + 1))
                else
                    failed_managers=\$((failed_managers + 1))
                fi
            done
            
            echo ''
            echo '═══════════════════════════════════════════════════════════════'
            echo 'RÉSUMÉ FINAL'
            echo '═══════════════════════════════════════════════════════════════'
            echo "Total managers testés: \$total_managers"
            echo "Réussis: \$passed_managers"
            echo "Échoués: \$failed_managers"
            echo ''
        " 2>&1 | tee "$REPORT_FILE"
}

# Afficher le rapport
show_report() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "📊 RAPPORT DE TEST"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    
    if [ -f "$REPORT_FILE" ]; then
        cat "$REPORT_FILE"
    else
        echo "⚠️  Aucun rapport trouvé"
    fi
    
    echo ""
    echo "📁 Rapport complet disponible dans: $REPORT_FILE"
}

# =============================================================================
# Script principal
# =============================================================================
main() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "🧪 TEST AUTOMATISÉ DE TOUS LES MANAGERS"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    
    # Vérifier que Docker est disponible
    if ! command -v docker >/dev/null 2>&1; then
        echo "❌ Docker n'est pas installé"
        echo "💡 Installez Docker avec: installman docker"
        exit 1
    fi
    
    # Initialiser la progression
    total_steps=3
    progress_init "$total_steps" "Test des managers"
    
    # Étape 1: Construire l'image
    if build_docker_image; then
        progress_update 1 1 0
    else
        progress_update 1 0 1
        progress_finish
        exit 1
    fi
    
    # Étape 2: Lancer les tests
    if run_tests_in_docker; then
        progress_update 2 2 0
    else
        progress_update 2 1 1
    fi
    
    # Étape 3: Afficher le rapport
    show_report
    progress_update 3 2 1
    
    # Terminer
    progress_finish
    
    echo ""
    echo "✅ Tests terminés!"
    echo "📁 Résultats dans: $TEST_RESULTS_DIR"
}

# Exécuter le script principal
main "$@"

