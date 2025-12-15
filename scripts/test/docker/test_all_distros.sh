#!/bin/bash
# =============================================================================
# Script de test rapide pour toutes les distributions Docker
# =============================================================================
# Description: Teste la construction de toutes les images Docker
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Distributions à tester (sauf Gentoo qui est trop lent)
declare -a DISTROS=(
    "arch:scripts/test/docker/Dockerfile.test"
    "ubuntu:scripts/test/docker/Dockerfile.ubuntu"
    "debian:scripts/test/docker/Dockerfile.debian"
    "alpine:scripts/test/docker/Dockerfile.alpine"
    "fedora:scripts/test/docker/Dockerfile.fedora"
    "centos:scripts/test/docker/Dockerfile.centos"
    "opensuse:scripts/test/docker/Dockerfile.opensuse"
)

SUCCESS=0
FAILED=0
FAILED_DISTROS=()

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🧪 TEST DE CONSTRUCTION DES IMAGES DOCKER${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

for distro_info in "${DISTROS[@]}"; do
    IFS=':' read -r distro dockerfile <<< "$distro_info"
    IMAGE_NAME="dotfiles-test-${distro}"
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🧪 Test: ${distro}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ ! -f "$dockerfile" ]; then
        echo -e "${RED}❌ Dockerfile non trouvé: $dockerfile${NC}"
        ((FAILED++))
        FAILED_DISTROS+=("$distro (fichier manquant)")
        continue
    fi
    
    echo -e "${YELLOW}🔨 Construction de l'image...${NC}"
    
    if DOCKER_BUILDKIT=0 docker build -f "$dockerfile" -t "$IMAGE_NAME:test" . > "/tmp/docker-build-${distro}.log" 2>&1; then
        echo -e "${GREEN}✅ ${distro}: Construction réussie${NC}"
        ((SUCCESS++))
        
        # Nettoyer l'image de test
        docker rmi "$IMAGE_NAME:test" >/dev/null 2>&1 || true
    else
        echo -e "${RED}❌ ${distro}: Échec de construction${NC}"
        echo -e "${YELLOW}📄 Logs: /tmp/docker-build-${distro}.log${NC}"
        ((FAILED++))
        FAILED_DISTROS+=("$distro")
    fi
    
    echo ""
done

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}📊 RÉSUMÉ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Réussis: ${SUCCESS}${NC}"
echo -e "${RED}❌ Échoués: ${FAILED}${NC}"
echo ""

if [ ${#FAILED_DISTROS[@]} -gt 0 ]; then
    echo -e "${RED}Distributions en échec:${NC}"
    for failed in "${FAILED_DISTROS[@]}"; do
        echo -e "  - ${failed}"
    done
    echo ""
    echo -e "${YELLOW}💡 Consultez les logs dans /tmp/docker-build-*.log${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Toutes les distributions fonctionnent!${NC}"
    exit 0
fi

