#!/bin/bash
# Script pour tester l'installation complète des dotfiles dans Docker
# Environnement complètement isolé

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_step()  { echo -e "${CYAN}[→]${NC} $1"; }

# Préfixe unique pour isoler des autres conteneurs Docker
DOTFILES_PREFIX="dotfiles-test"
CONTAINER_NAME="${DOTFILES_PREFIX}-auto"
IMAGE_NAME="${DOTFILES_PREFIX}:auto"

log_step "Nettoyage UNIQUEMENT des conteneurs et images dotfiles-test..."
# Nettoyer uniquement les conteneurs avec notre préfixe
CONTAINERS=$(docker ps -a --filter "name=${DOTFILES_PREFIX}" --format "{{.Names}}" 2>/dev/null || true)
if [ -n "$CONTAINERS" ]; then
    echo "$CONTAINERS" | xargs -r docker stop 2>/dev/null || true
    echo "$CONTAINERS" | xargs -r docker rm 2>/dev/null || true
fi
# Nettoyer uniquement les images avec notre préfixe
IMAGES=$(docker images --filter "reference=${DOTFILES_PREFIX}*" --format "{{.Repository}}:{{.Tag}}" 2>/dev/null || true)
if [ -n "$IMAGES" ]; then
    echo "$IMAGES" | xargs -r docker rmi 2>/dev/null || true
fi
# Nettoyer aussi les images avec le tag exact
docker rmi "${IMAGE_NAME}" 2>/dev/null || true

log_step "Construction de l'image Docker avec installation automatique (isolée)..."
# Utiliser --load pour charger l'image dans Docker (nécessaire avec BuildKit)
docker build --load -f Dockerfile.test -t "$IMAGE_NAME" . || {
    log_error "Échec de la construction de l'image"
    exit 1
}
log_info "✅ Image isolée créée: $IMAGE_NAME (ne touche pas vos autres conteneurs)"

log_info "✅ Image construite avec succès"

log_step "Lancement du conteneur avec installation automatique..."
docker run -it --rm \
    --name "$CONTAINER_NAME" \
    -v "$(pwd):/root/dotfiles:ro" \
    "$IMAGE_NAME" || {
    log_error "Échec du lancement du conteneur"
    exit 1
}

log_info "✅ Tests terminés !"

