#!/bin/bash
# =============================================================================
# Vérification d'intégrité d'un conteneur Docker
# =============================================================================
# Description: Vérifie si un conteneur Docker est valide et utilisable
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

CONTAINER_NAME="${1:-dotfiles-vm}"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Vérification d'intégrité du conteneur: $CONTAINER_NAME${NC}"
echo ""

# Vérifier si le conteneur existe
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}⚠️  Conteneur $CONTAINER_NAME non trouvé${NC}"
    exit 1
fi

# Vérifier l'état du conteneur
CONTAINER_STATUS=$(docker inspect --format='{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null)
if [ -z "$CONTAINER_STATUS" ]; then
    echo -e "${RED}❌ Impossible de vérifier l'état du conteneur${NC}"
    exit 1
fi

echo -e "${BLUE}📊 État: $CONTAINER_STATUS${NC}"

# Vérifier si l'image existe encore
IMAGE_NAME=$(docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME" 2>/dev/null)
if [ -z "$IMAGE_NAME" ]; then
    echo -e "${RED}❌ Impossible de récupérer le nom de l'image${NC}"
    exit 1
fi

echo -e "${BLUE}🖼️  Image: $IMAGE_NAME${NC}"

# Vérifier si l'image existe toujours
if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}$"; then
    echo -e "${YELLOW}⚠️  L'image $IMAGE_NAME n'existe plus${NC}"
    echo -e "${YELLOW}   Le conteneur peut ne pas fonctionner correctement${NC}"
    INTEGRITY_ISSUES=1
fi

# Vérifier l'architecture (normaliser x86_64=amd64, arm64=aarch64)
CONTAINER_ARCH=$(docker inspect --format='{{.Architecture}}' "$CONTAINER_NAME" 2>/dev/null || echo "")
HOST_ARCH=$(uname -m)

# Normaliser les architectures
case "$HOST_ARCH" in
    x86_64) NORMALIZED_HOST_ARCH="amd64" ;;
    arm64) NORMALIZED_HOST_ARCH="aarch64" ;;
    *) NORMALIZED_HOST_ARCH="$HOST_ARCH" ;;
esac

if [ -n "$CONTAINER_ARCH" ]; then
    case "$CONTAINER_ARCH" in
        x86_64) NORMALIZED_CONTAINER_ARCH="amd64" ;;
        arm64) NORMALIZED_CONTAINER_ARCH="aarch64" ;;
        *) NORMALIZED_CONTAINER_ARCH="$CONTAINER_ARCH" ;;
    esac
    
    # Vérifier seulement si les architectures normalisées sont différentes
    if [ "$NORMALIZED_CONTAINER_ARCH" != "$NORMALIZED_HOST_ARCH" ]; then
        echo -e "${YELLOW}⚠️  Architecture différente: conteneur=$CONTAINER_ARCH, hôte=$HOST_ARCH${NC}"
        INTEGRITY_ISSUES=1
    else
        echo -e "${GREEN}✅ Architecture compatible: $CONTAINER_ARCH${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Architecture du conteneur non détectable${NC}"
    INTEGRITY_ISSUES=1
fi

# Vérifier si le conteneur peut être démarré
if [ "$CONTAINER_STATUS" = "exited" ] || [ "$CONTAINER_STATUS" = "stopped" ]; then
    echo -e "${BLUE}🔄 Test de démarrage...${NC}"
    if docker start "$CONTAINER_NAME" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Conteneur peut être démarré${NC}"
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1
    else
        echo -e "${RED}❌ Impossible de démarrer le conteneur${NC}"
        INTEGRITY_ISSUES=1
    fi
fi

# Vérifier si on peut exécuter des commandes
if [ "$CONTAINER_STATUS" = "running" ] || docker start "$CONTAINER_NAME" >/dev/null 2>&1; then
    echo -e "${BLUE}🧪 Test d'exécution de commande...${NC}"
    if docker exec "$CONTAINER_NAME" /bin/sh -c "echo test" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Conteneur répond aux commandes${NC}"
    else
        echo -e "${RED}❌ Conteneur ne répond pas aux commandes${NC}"
        INTEGRITY_ISSUES=1
    fi
    
    # Vérifier si l'entrypoint existe
    if docker exec "$CONTAINER_NAME" test -f /root/entrypoint.sh >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Entrypoint.sh présent${NC}"
    else
        echo -e "${RED}❌ Entrypoint.sh manquant${NC}"
        INTEGRITY_ISSUES=1
    fi
    
    # Vérifier si les dotfiles sont montés
    if docker exec "$CONTAINER_NAME" test -d /root/dotfiles >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Répertoire dotfiles présent${NC}"
    else
        echo -e "${YELLOW}⚠️  Répertoire dotfiles non monté (sera monté au démarrage)${NC}"
    fi
    
    if [ "$CONTAINER_STATUS" != "running" ]; then
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1
    fi
fi

echo ""
if [ -z "$INTEGRITY_ISSUES" ]; then
    echo -e "${GREEN}✅ Conteneur intègre et utilisable${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Problèmes d'intégrité détectés${NC}"
    echo -e "${YELLOW}   Recommandation: Recréer le conteneur${NC}"
    exit 1
fi

