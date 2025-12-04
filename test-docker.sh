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

CONTAINER_NAME="dotfiles-test-auto"
IMAGE_NAME="dotfiles-test:auto"

log_step "Nettoyage des conteneurs et images existants..."
docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true
docker rmi "$IMAGE_NAME" 2>/dev/null || true

log_step "Construction de l'image Docker avec installation automatique..."
docker build -f Dockerfile.test -t "$IMAGE_NAME" . || {
    log_error "Échec de la construction de l'image"
    exit 1
}

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

