#!/bin/sh
# =============================================================================
# TEST_ALL_MANAGERS - Test automatisé de tous les managers dans Docker
# =============================================================================
# Description: Teste tous les managers dans un environnement Docker sécurisé
# Author: Paul Delhomme
# Version: 2.0 - Entièrement dans Docker
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
DOCKER_COMPOSE_FILE="$DOTFILES_DIR/scripts/test/docker/docker-compose.yml"

# =============================================================================
# Fonctions
# =============================================================================

# Vérifier que Docker est disponible
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "❌ Docker n'est pas installé"
        echo "💡 Installez Docker avec: installman docker"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        echo "❌ Docker n'est pas démarré ou vous n'avez pas les permissions"
        echo "💡 Vérifiez que Docker est démarré: sudo systemctl start docker"
        echo "💡 Ou ajoutez-vous au groupe docker: sudo usermod -aG docker \$USER"
        exit 1
    fi
}

# Construire l'image Docker
build_docker_image() {
    echo "🔨 Construction de l'image Docker..."
    echo "   (Cela peut prendre quelques minutes la première fois)"
    echo ""
    
    if docker build -f "$DOTFILES_DIR/scripts/test/docker/Dockerfile.test" \
        -t "$DOCKER_IMAGE" \
        "$DOTFILES_DIR" 2>&1 | grep -E "(Step|Successfully|Error|ERROR)" | head -20; then
        echo ""
        echo "✅ Image Docker construite avec succès"
        return 0
    else
        echo ""
        echo "❌ Erreur lors de la construction de l'image Docker"
        return 1
    fi
}

# Lancer les tests avec docker-compose (méthode recommandée)
run_tests_with_compose() {
    echo "🧪 Lancement des tests avec docker-compose..."
    echo ""
    
    # Créer le répertoire de résultats
    mkdir -p "$TEST_RESULTS_DIR"
    
    # Utiliser le chemin absolu du docker-compose.yml
    COMPOSE_FILE="$DOTFILES_DIR/scripts/test/docker/docker-compose.yml"
    
    # Vérifier que le fichier existe
    if [ ! -f "$COMPOSE_FILE" ]; then
        echo "❌ Fichier docker-compose.yml non trouvé: $COMPOSE_FILE"
        return 1
    fi
    
    # Aller dans le répertoire du docker-compose.yml pour que les chemins relatifs fonctionnent
    COMPOSE_DIR="$DOTFILES_DIR/scripts/test/docker"
    cd "$COMPOSE_DIR" || exit 1
    
    # Lancer docker-compose avec le fichier spécifié
    # Utiliser --project-directory pour forcer le contexte
    COMPOSE_OUTPUT=$(docker compose \
        -f docker-compose.yml \
        --project-directory "$DOTFILES_DIR" \
        up --build --remove-orphans 2>&1)
    COMPOSE_EXIT=$?
    
    # Filtrer la sortie verbeuse (garder seulement les messages importants)
    echo "$COMPOSE_OUTPUT" | grep -vE "(WARN|vertexes|statuses|digest|name|started|completed|current|timestamp|id|reading from stdin|\{|\}|^$|^\s*$)" | \
        grep -E "(Building|Creating|Starting|Running|Error|ERROR|Success|success|test|Test|TEST)" || true
    
    # Retourner au répertoire original
    cd "$DOTFILES_DIR" || exit 1
    
    # Vérifier le code de sortie
    if [ $COMPOSE_EXIT -eq 0 ]; then
        return 0
    else
        # Vérifier si le conteneur a bien tourné malgré le code de sortie
        if docker ps -a --filter "name=dotfiles-test-container" --format "{{.Status}}" 2>/dev/null | grep -q "Exited"; then
            return 0
        else
            return 1
        fi
    fi
}

# Lancer les tests avec docker run (méthode principale - plus fiable)
run_tests_with_docker() {
    echo "🧪 Lancement des tests avec docker run..."
    echo ""
    
    # Créer le répertoire de résultats
    mkdir -p "$TEST_RESULTS_DIR"
    
    # Vérifier que l'image existe
    if ! docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${DOCKER_IMAGE}$"; then
        echo "❌ Image Docker non trouvée: $DOCKER_IMAGE"
        echo "💡 Construction de l'image..."
        if ! build_docker_image; then
            return 1
        fi
    fi
    
    # Lancer le conteneur et exécuter les tests
    echo "🚀 Démarrage du conteneur de test..."
    if docker run --rm \
        --name "$DOCKER_CONTAINER" \
        -v "$DOTFILES_DIR:/root/dotfiles:ro" \
        -v "$TEST_RESULTS_DIR:/root/test_results:rw" \
        -v "dotfiles-test-config:/root/.config:rw" \
        -e DOTFILES_DIR=/root/dotfiles \
        -e TEST_RESULTS_DIR=/root/test_results \
        "$DOCKER_IMAGE" \
        bash /root/dotfiles/scripts/test/docker/run_tests.sh 2>&1 | tee "$TEST_RESULTS_DIR/test_output.log"; then
        return 0
    else
        return 1
    fi
}

# Afficher le rapport
show_report() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "📊 RAPPORT DE TEST"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    
    REPORT_FILE="$TEST_RESULTS_DIR/all_managers_test_report.txt"
    DETAILED_REPORT="$TEST_RESULTS_DIR/detailed_report.txt"
    
    if [ -f "$REPORT_FILE" ]; then
        cat "$REPORT_FILE"
    else
        echo "⚠️  Aucun rapport trouvé"
        if [ -f "$TEST_RESULTS_DIR/test_output.log" ]; then
            echo ""
            echo "📋 Sortie du conteneur:"
            tail -50 "$TEST_RESULTS_DIR/test_output.log"
        fi
    fi
    
    echo ""
    echo "📁 Rapports disponibles dans:"
    echo "  - Résumé: $REPORT_FILE"
    echo "  - Détail: $DETAILED_REPORT"
    echo "  - Log complet: $TEST_RESULTS_DIR/test_output.log"
}

# Nettoyer les conteneurs
cleanup() {
    echo ""
    echo "🧹 Nettoyage..."
    # Nettoyer docker-compose si utilisé
    COMPOSE_FILE="$DOTFILES_DIR/scripts/test/docker/docker-compose.yml"
    if [ -f "$COMPOSE_FILE" ]; then
        COMPOSE_DIR="$DOTFILES_DIR/scripts/test/docker"
        cd "$COMPOSE_DIR" 2>/dev/null && docker compose down 2>/dev/null || true
        cd "$DOTFILES_DIR" 2>/dev/null || true
    fi
    # Nettoyer le conteneur docker run
    docker stop "$DOCKER_CONTAINER" 2>/dev/null || true
    docker rm "$DOCKER_CONTAINER" 2>/dev/null || true
    echo "✅ Nettoyage terminé"
}

# =============================================================================
# Script principal
# =============================================================================
main() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "🧪 TEST AUTOMATISÉ DE TOUS LES MANAGERS (DOCKER)"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "📦 Tous les tests s'exécutent dans Docker (environnement isolé)"
    echo "🔒 Aucune modification de votre système hôte"
    echo ""
    
    # Vérifier Docker
    check_docker
    
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
    # Utiliser docker run directement (plus simple et fiable)
    echo "💡 Utilisation de docker run (méthode la plus fiable)"
    if run_tests_with_docker; then
        progress_update 2 2 0
    else
        progress_update 2 1 1
    fi
    
    # Étape 3: Afficher le rapport
    show_report
    progress_update 3 2 1
    
    # Nettoyer
    cleanup
    
    # Terminer
    progress_finish
    
    echo ""
    echo "✅ Tests terminés!"
    echo "📁 Résultats dans: $TEST_RESULTS_DIR"
    echo ""
    echo "💡 Pour voir les résultats détaillés:"
    echo "   cat $TEST_RESULTS_DIR/detailed_report.txt"
}

# Gérer l'interruption (Ctrl+C)
trap cleanup EXIT INT TERM

# Exécuter le script principal
main "$@"

