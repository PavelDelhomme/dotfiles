#!/usr/bin/env bash
# =============================================================================
# Matrice sous-commandes — uniquement dans Docker (même image que test_all_managers)
# =============================================================================
# Variables (optionnelles) : DOTFILES_DIR, TEST_MANAGERS, TEST_SHELLS,
#   SUBCOMMAND_TIER (full|quick), TEST_SUBCOMMAND_TIMEOUT, TEST_RESULTS_DIR

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
if [ -f "$DOTFILES_DIR/scripts/test/lib/dotfiles_test_host_env.sh" ]; then
    # shellcheck source=/dev/null
    . "$DOTFILES_DIR/scripts/test/lib/dotfiles_test_host_env.sh"
    dotfiles_test_load_user_env
fi
DOCKER_IMAGE="dotfiles-test:latest"
DOCKER_IMAGE_ALT="dotfiles-test:auto"
DOCKER_CONTAINER="dotfiles-test-subcmd-matrix"
TEST_RESULTS_DIR="${TEST_RESULTS_DIR:-$DOTFILES_DIR/test_results}"

if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker n'est pas installé"
    exit 1
fi
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker n'est pas démarré ou permissions insuffisantes"
    exit 1
fi

build_docker_image() {
    echo "🔨 Construction de l'image $DOCKER_IMAGE..."
    docker build -f "$DOTFILES_DIR/scripts/test/docker/Dockerfile.test" \
        -t "$DOCKER_IMAGE" \
        -t "$DOCKER_IMAGE_ALT" \
        "$DOTFILES_DIR" || return 1
    return 0
}

ACTUAL_IMAGE=""
if docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -q "^${DOCKER_IMAGE}$"; then
    ACTUAL_IMAGE="$DOCKER_IMAGE"
elif docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -q "^${DOCKER_IMAGE_ALT}$"; then
    ACTUAL_IMAGE="$DOCKER_IMAGE_ALT"
else
    echo "⚠️  Image absente, construction..."
    build_docker_image || exit 1
    if docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -q "^${DOCKER_IMAGE}$"; then
        ACTUAL_IMAGE="$DOCKER_IMAGE"
    elif docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -q "^${DOCKER_IMAGE_ALT}$"; then
        ACTUAL_IMAGE="$DOCKER_IMAGE_ALT"
    else
        ACTUAL_IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep "^dotfiles-test:" | head -1)
    fi
fi

if [ -z "$ACTUAL_IMAGE" ]; then
    echo "❌ Aucune image dotfiles-test disponible"
    exit 1
fi

mkdir -p "$TEST_RESULTS_DIR"

echo "═══════════════════════════════════════════════════════════════"
echo "🧪 Matrice sous-commandes dans Docker"
echo "   Image: $ACTUAL_IMAGE"
echo "   DOTFILES_DIR (hôte): $DOTFILES_DIR"
echo "   SUBCOMMAND_TIER: ${SUBCOMMAND_TIER:-full}"
echo "   TEST_SHELLS (si défini): ${TEST_SHELLS:-défaut matrice = zsh bash fish sh}"
echo "   TEST_MANAGERS (si défini): ${TEST_MANAGERS:-défaut = managers migrés}"
echo "═══════════════════════════════════════════════════════════════"

# Arrêter un ancien conteneur du même nom (run précédent interrompu)
docker rm -f "$DOCKER_CONTAINER" 2>/dev/null || true

if ! dotfiles_test_prepare_docker_mount; then
    echo "❌ Préparation du montage Docker (bac à sable) échouée"
    exit 1
fi
_vol="${DOTFILES_DOCKER_MOUNT:-$DOTFILES_DIR}"
trap 'dotfiles_test_isolate_cleanup' EXIT INT TERM

_subm_env=$(mktemp "${TMPDIR:-/tmp}/dotfiles-submatrix-env.XXXXXX") || exit 1
printf 'TEST_SHELLS=%s\n' "${TEST_SHELLS:-zsh bash fish sh}" > "$_subm_env"
[ -n "${TEST_MANAGERS:-}" ] && printf 'TEST_MANAGERS=%s\n' "$TEST_MANAGERS" >> "$_subm_env"

docker run --rm \
    --name "$DOCKER_CONTAINER" \
    --env-file "$_subm_env" \
    -w /root/dotfiles \
    -v "$_vol:/root/dotfiles:ro" \
    -v "$TEST_RESULTS_DIR:/root/test_results:rw" \
    -v "dotfiles-test-config:/root/.config:rw" \
    -e DOTFILES_DIR=/root/dotfiles \
    -e HOME=/root \
    -e TEST_RESULTS_DIR=/root/test_results \
    -e MANAGERS_LOG_FILE=/root/test_results/managers_subcommand_matrix.log \
    -e DOTFILES_DOCKER_TEST=1 \
    -e "SUBCOMMAND_TIER=${SUBCOMMAND_TIER:-full}" \
    -e "TEST_SUBCOMMAND_TIMEOUT=${TEST_SUBCOMMAND_TIMEOUT:-45}" \
    "$ACTUAL_IMAGE" \
    bash -lc 'mkdir -p /root/test_results && bash /root/dotfiles/scripts/test/manager_subcommand_matrix.sh' \
    2>&1 | tee "$TEST_RESULTS_DIR/subcommand_matrix_docker.log"
_rc="${PIPESTATUS[0]}"
rm -f "$_subm_env" 2>/dev/null || true
exit "$_rc"
