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
if [ -f "$DOTFILES_DIR/scripts/test/lib/dotfiles_test_host_env.sh" ]; then
    # shellcheck source=/dev/null
    . "$DOTFILES_DIR/scripts/test/lib/dotfiles_test_host_env.sh"
    dotfiles_test_load_user_env
fi
PROGRESS_BAR="$DOTFILES_DIR/core/utils/progress_bar.sh"

if [ -f "$PROGRESS_BAR" ]; then
    . "$PROGRESS_BAR"
fi

# =============================================================================
# Configuration
# =============================================================================
DOCKER_IMAGE="dotfiles-test:latest"
DOCKER_IMAGE_ALT="dotfiles-test:auto"  # Tag alternatif possible
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
    
    # Construire l'image avec les deux tags (latest et auto) pour compatibilité
    BUILD_OUTPUT=$(docker build -f "$DOTFILES_DIR/scripts/test/docker/Dockerfile.test" \
        -t "$DOCKER_IMAGE" \
        -t "$DOCKER_IMAGE_ALT" \
        "$DOTFILES_DIR" 2>&1)
    BUILD_EXIT=$?
    
    # Afficher les lignes importantes
    echo "$BUILD_OUTPUT" | grep -E "(Step|Successfully|Error|ERROR|built|tagged)" | tail -10
    
    # Vérifier que l'image existe maintenant (avec tag latest ou auto)
    if [ $BUILD_EXIT -eq 0 ]; then
        if docker images --format "{{.Repository}}:{{.Tag}}" | grep -qE "^(${DOCKER_IMAGE}|${DOCKER_IMAGE_ALT})$"; then
            BUILT_IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "^(${DOCKER_IMAGE}|${DOCKER_IMAGE_ALT})$" | head -1)
            echo ""
            echo "✅ Image Docker construite avec succès: $BUILT_IMAGE"
            return 0
        else
            echo ""
            echo "⚠️  Image construite mais tag non trouvé"
            echo "   Images dotfiles disponibles:"
            docker images | grep dotfiles || echo "   Aucune image dotfiles trouvée"
            # Ne pas échouer si l'image existe avec un autre tag
            if docker images | grep -q "dotfiles-test"; then
                echo "   → Image existe avec un autre tag, utilisation possible"
                return 0
            else
                return 1
            fi
        fi
    else
        echo ""
        echo "❌ Erreur lors de la construction de l'image Docker"
        echo "   Vérification de l'image..."
        docker images | grep dotfiles || echo "   Aucune image dotfiles trouvée"
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
    
    # Détecter quelle image utiliser (vérification robuste)
    ACTUAL_IMAGE=""
    
    # Vérifier d'abord latest
    if docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -q "^${DOCKER_IMAGE}$"; then
        ACTUAL_IMAGE="$DOCKER_IMAGE"
        echo "✅ Image Docker trouvée: $ACTUAL_IMAGE"
    # Sinon vérifier auto
    elif docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -q "^${DOCKER_IMAGE_ALT}$"; then
        ACTUAL_IMAGE="$DOCKER_IMAGE_ALT"
        echo "✅ Image Docker trouvée (tag auto): $ACTUAL_IMAGE"
        echo "💡 Utilisation de l'image avec tag 'auto'"
    # Sinon construire
    else
        echo "⚠️  Image Docker non trouvée: $DOCKER_IMAGE"
        echo "💡 Construction de l'image..."
        if ! build_docker_image; then
            echo "❌ Impossible de construire l'image Docker"
            return 1
        fi
        # Après construction, vérifier quelle image est disponible
        if docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -q "^${DOCKER_IMAGE}$"; then
            ACTUAL_IMAGE="$DOCKER_IMAGE"
        elif docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -q "^${DOCKER_IMAGE_ALT}$"; then
            ACTUAL_IMAGE="$DOCKER_IMAGE_ALT"
        else
            echo "❌ Image Docker toujours introuvable après construction"
            echo "   Images disponibles:"
            docker images | grep -E "(REPOSITORY|dotfiles)" || docker images | head -5
            return 1
        fi
    fi
    
    # Vérification finale que l'image existe vraiment
    if [ -z "$ACTUAL_IMAGE" ]; then
        echo "❌ Aucune image Docker disponible"
        echo "   Images disponibles:"
        docker images | grep -E "(REPOSITORY|dotfiles)" || docker images | head -5
        return 1
    fi
    
    # Vérifier que l'image existe vraiment avant de lancer
    if ! docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -q "^${ACTUAL_IMAGE}$"; then
        echo "❌ Image Docker introuvable: $ACTUAL_IMAGE"
        echo "   Tentative de recherche alternative..."
        # Chercher n'importe quelle image dotfiles-test
        ALTERNATIVE_IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep "^dotfiles-test:" | head -1)
        if [ -n "$ALTERNATIVE_IMAGE" ]; then
            echo "   → Utilisation de: $ALTERNATIVE_IMAGE"
            ACTUAL_IMAGE="$ALTERNATIVE_IMAGE"
        else
            echo "   Images disponibles:"
            docker images | grep -E "(REPOSITORY|dotfiles)" || docker images | head -5
            return 1
        fi
    fi
    
    # Lancer le conteneur et exécuter les tests
    echo "🚀 Démarrage du conteneur de test avec: $ACTUAL_IMAGE"
    echo ""
    if ! dotfiles_test_prepare_docker_mount; then
        echo "❌ Préparation du montage Docker (bac à sable) échouée"
        return 1
    fi
    _vol="${DOTFILES_DOCKER_MOUNT:-$DOTFILES_DIR}"
    echo "   Bind mount hôte → conteneur: $_vol (lecture seule)"
    echo "   TEST_SHELLS=${TEST_SHELLS:-zsh bash fish}"
    echo "   DOTFILES_TEST_MANAGERS=${DOTFILES_TEST_MANAGERS:-'(non défini — voir make test-help)'}"
    echo "   TEST_MANAGERS=${TEST_MANAGERS:-'(défaut : managers migrés — migrated_managers.list)'}"
    echo ""
    # --env-file : valeurs avec espaces (TEST_SHELLS) sans casser les arguments docker
    _docker_envf=$(mktemp "${TMPDIR:-/tmp}/dotfiles-docker-env.XXXXXX") || return 1
    printf 'TEST_SHELLS=%s\n' "${TEST_SHELLS:-zsh bash fish}" > "$_docker_envf"
    [ -n "${TEST_MANAGERS:-}" ] && printf 'TEST_MANAGERS=%s\n' "$TEST_MANAGERS" >> "$_docker_envf"
    _log="$TEST_RESULTS_DIR/test_output.log"
    : > "$_log" 2>/dev/null || true
    echo ""
    echo "📺 Sortie du conteneur en direct ci-dessous (copie identique dans : $_log)"
    echo "───────────────────────────────────────────────────────────────"

    # tee + pipefail (bash) : affichage live ET code de sortie = celui de docker, pas de tee
    if command -v bash >/dev/null 2>&1 && command -v tee >/dev/null 2>&1; then
        export _D_LOG="$_log"
        export _D_ENV="$_docker_envf"
        export _D_VOL="$_vol"
        export _D_IMG="$ACTUAL_IMAGE"
        export _D_CN="$DOCKER_CONTAINER"
        export _D_TR="$TEST_RESULTS_DIR"
        export _D_RSMB="${RUN_SUBCOMMAND_MATRIX:-0}"
        export _D_ST="${SUBCOMMAND_TIER:-full}"
        bash -c 'set -o pipefail
docker run --rm \
  --name "$_D_CN" \
  --env-file "$_D_ENV" \
  -w /root/dotfiles \
  -v "$_D_VOL:/root/dotfiles:ro" \
  -v "$_D_TR:/root/test_results:rw" \
  -v "dotfiles-test-config:/root/.config:rw" \
  -e DOTFILES_DIR=/root/dotfiles \
  -e HOME=/root \
  -e TEST_RESULTS_DIR=/root/test_results \
  -e MANAGERS_LOG_FILE=/root/test_results/managers_docker_tests.log \
  -e DOTFILES_DOCKER_TEST=1 \
  -e "RUN_SUBCOMMAND_MATRIX=$_D_RSMB" \
  -e "SUBCOMMAND_TIER=$_D_ST" \
  "$_D_IMG" \
  bash /root/dotfiles/scripts/test/docker/run_tests.sh 2>&1 | tee "$_D_LOG"
exit "${PIPESTATUS[0]}"'
        _dr=$?
        unset _D_LOG _D_ENV _D_VOL _D_IMG _D_CN _D_TR _D_RSMB _D_ST
    else
        echo "⚠️  bash ou tee absent : sortie seulement vers le fichier (pas de flux terminal)."
        docker run --rm \
            --name "$DOCKER_CONTAINER" \
            --env-file "$_docker_envf" \
            -w /root/dotfiles \
            -v "$_vol:/root/dotfiles:ro" \
            -v "$TEST_RESULTS_DIR:/root/test_results:rw" \
            -v "dotfiles-test-config:/root/.config:rw" \
            -e DOTFILES_DIR=/root/dotfiles \
            -e HOME=/root \
            -e TEST_RESULTS_DIR=/root/test_results \
            -e MANAGERS_LOG_FILE=/root/test_results/managers_docker_tests.log \
            -e DOTFILES_DOCKER_TEST=1 \
            -e "RUN_SUBCOMMAND_MATRIX=${RUN_SUBCOMMAND_MATRIX:-0}" \
            -e "SUBCOMMAND_TIER=${SUBCOMMAND_TIER:-full}" \
            "$ACTUAL_IMAGE" \
            bash /root/dotfiles/scripts/test/docker/run_tests.sh > "$_log" 2>&1
        _dr=$?
    fi
    rm -f "$_docker_envf" 2>/dev/null || true
    echo ""
    echo "───────────────────────────────────────────────────────────────"
    echo "── Fin du flux conteneur — journal : $_log"
    if [ "$_dr" -eq 0 ]; then
        return 0
    else
        RUN_EXIT=$_dr
        echo ""
        echo "❌ Erreur lors de l'exécution du conteneur (code: $RUN_EXIT)"
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
    dotfiles_test_isolate_cleanup 2>/dev/null || true
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        COMPOSE_FILE="$DOTFILES_DIR/scripts/test/docker/docker-compose.yml"
        if [ -f "$COMPOSE_FILE" ]; then
            COMPOSE_DIR="$DOTFILES_DIR/scripts/test/docker"
            cd "$COMPOSE_DIR" 2>/dev/null && docker compose down 2>/dev/null || true
            cd "$DOTFILES_DIR" 2>/dev/null || true
        fi
        docker stop "$DOCKER_CONTAINER" 2>/dev/null || true
        docker rm "$DOCKER_CONTAINER" 2>/dev/null || true
    fi
    echo "✅ Nettoyage terminé"
}

# Déjà dans un conteneur (docker-in, etc.) : pas de Docker dans Docker
_dotfiles_inside_test_container() {
    if [ -f /.dockerenv ]; then
        return 0
    fi
    if [ "${DOTFILES_TEST_NO_NESTED_DOCKER:-}" = 1 ]; then
        return 0
    fi
    return 1
}

# Exécuter la même suite que dans l'image de test, sans lancer un conteneur fils
run_tests_in_current_env() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "🧪 TEST AUTOMATISÉ DES MANAGERS (environnement courant)"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "ℹ️  Docker n'est pas utilisable ici (conteneur sans moteur Docker / daemon absent)."
    echo "   Lancement direct : scripts/test/docker/run_tests.sh"
    echo "   (équivalent à ce qui tourne dans l'image dotfiles-test)"
    echo ""
    # Ne pas forcer test_results sous le dépôt : docker-in monte souvent les dotfiles en RO.
    if [ -z "${TEST_RESULTS_DIR:-}" ]; then
        unset TEST_RESULTS_DIR
    else
        export TEST_RESULTS_DIR
    fi
    export DOTFILES_DIR DOTFILES_DOCKER_TEST=1
    exec bash "$DOTFILES_DIR/scripts/test/docker/run_tests.sh" "$@"
}

# =============================================================================
# Script principal
# =============================================================================
main() {
    if _dotfiles_inside_test_container && { ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; }; then
        run_tests_in_current_env "$@"
    fi

    echo "═══════════════════════════════════════════════════════════════"
    echo "🧪 TEST AUTOMATISÉ DE TOUS LES MANAGERS (DOCKER)"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "📦 Tous les tests s'exécutent dans Docker (environnement isolé)"
    echo "🔒 Aucune modification de votre système hôte"
    echo ""
    
    # Vérifier Docker
    check_docker
    
    # Initialiser la progression (3 = build image, exécution conteneur, rapport — pas « 3 managers »)
    total_steps=3
    progress_init "$total_steps" "Pipeline Docker (1/3 image · 2/3 tests conteneur · 3/3 rapport)"
    echo "💡 Les barres [n/3] comptent les étapes ci-dessus, pas le nombre de managers testés."
    echo "   Bac à sable : dotfiles en lecture seule dans le conteneur, résultats dans $TEST_RESULTS_DIR"
    echo ""
    
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
    _docker_tests_rc=0
    if run_tests_with_docker; then
        progress_update 2 2 0
        _docker_tests_rc=0
    else
        progress_update 2 1 1
        _docker_tests_rc=1
    fi
    
    # Étape 3: Afficher le rapport
    show_report
    if [ "$_docker_tests_rc" -eq 0 ]; then
        progress_update 3 3 0
    else
        progress_update 3 2 1
    fi
    
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

