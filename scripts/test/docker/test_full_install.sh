#!/bin/bash
# =============================================================================
# Script de test d'installation complète des dotfiles
# =============================================================================
# Description: Teste l'installation complète des dotfiles dans un conteneur Docker
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🧪 TEST D'INSTALLATION COMPLÈTE DES DOTFILES${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Vérifier Docker
if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker n'est pas installé${NC}"
    exit 1
fi

# Choix de la distribution
echo -e "${CYAN}📦 Distribution:${NC}"
echo "  1) Arch Linux"
echo "  2) Ubuntu"
echo "  3) Debian"
echo "  4) Alpine"
echo "  5) Fedora"
echo "  6) CentOS"
echo "  7) openSUSE"
echo ""
read -p "Choix [défaut: 1]: " distro_choice
distro_choice=${distro_choice:-1}

case "$distro_choice" in
    1) DISTRO="arch" DOCKERFILE="$DOTFILES_DIR/scripts/test/docker/Dockerfile.test" ;;
    2) DISTRO="ubuntu" DOCKERFILE="$DOTFILES_DIR/scripts/test/docker/Dockerfile.ubuntu" ;;
    3) DISTRO="debian" DOCKERFILE="$DOTFILES_DIR/scripts/test/docker/Dockerfile.debian" ;;
    4) DISTRO="alpine" DOCKERFILE="$DOTFILES_DIR/scripts/test/docker/Dockerfile.alpine" ;;
    5) DISTRO="fedora" DOCKERFILE="$DOTFILES_DIR/scripts/test/docker/Dockerfile.fedora" ;;
    6) DISTRO="centos" DOCKERFILE="$DOTFILES_DIR/scripts/test/docker/Dockerfile.centos" ;;
    7) DISTRO="opensuse" DOCKERFILE="$DOTFILES_DIR/scripts/test/docker/Dockerfile.opensuse" ;;
    *) DISTRO="arch" DOCKERFILE="$DOTFILES_DIR/scripts/test/docker/Dockerfile.test" ;;
esac

echo -e "${GREEN}✓ Distribution: $DISTRO${NC}"
echo ""

# Choix du shell
echo -e "${CYAN}🐚 Shell:${NC}"
echo "  1) zsh (défaut)"
echo "  2) bash"
echo "  3) fish"
echo ""
read -p "Choix [défaut: 1]: " shell_choice
shell_choice=${shell_choice:-1}

case "$shell_choice" in
    1) SHELL="zsh" SHELL_BIN="/bin/zsh" ;;
    2) SHELL="bash" SHELL_BIN="/bin/bash" ;;
    3) SHELL="fish" SHELL_BIN="/bin/fish" ;;
    *) SHELL="zsh" SHELL_BIN="/bin/zsh" ;;
esac

echo -e "${GREEN}✓ Shell: $SHELL${NC}"
echo ""

# Choix du mode
echo -e "${CYAN}🔧 Mode de test:${NC}"
echo "  1) Installation complète depuis zéro (recommandé)"
echo "     → Teste le processus bootstrap complet"
echo "     → Télécharge et installe les dotfiles"
echo ""
echo "  2) Dotfiles pré-installés (test rapide)"
echo "     → Dotfiles déjà montés dans le conteneur"
echo "     → Teste uniquement le chargement"
echo ""
read -p "Choix [défaut: 1]: " mode_choice
mode_choice=${mode_choice:-1}

case "$mode_choice" in
    1) MODE="full" ;;
    2) MODE="preinstalled" ;;
    *) MODE="full" ;;
esac

echo -e "${GREEN}✓ Mode: $MODE${NC}"
echo ""

# Nom du conteneur
CONTAINER_NAME="dotfiles-test-${DISTRO}-${SHELL}-$$"
IMAGE_NAME="dotfiles-test-${DISTRO}"

echo -e "${BLUE}🔨 Construction de l'image...${NC}"
DOCKER_BUILDKIT=0 docker build -f "$DOCKERFILE" -t "$IMAGE_NAME:latest" "$DOTFILES_DIR" || exit 1

echo ""
echo -e "${BLUE}🚀 Démarrage du conteneur de test...${NC}"

# Supprimer le conteneur s'il existe
docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

if [ "$MODE" = "full" ]; then
    # Mode installation complète
    echo -e "${YELLOW}📥 Mode: Installation complète depuis zéro${NC}"
    echo -e "${CYAN}💡 Le conteneur va télécharger et installer les dotfiles${NC}"
    echo ""
    
    docker run -it --rm \
        --name "$CONTAINER_NAME" \
        -e HOME=/root \
        -e TERM=xterm-256color \
        -e SHELL="$SHELL" \
        "$IMAGE_NAME:latest" \
        "$SHELL_BIN" -c "
            echo '🧪 Test d'\''installation complète des dotfiles'
            echo '📦 Distribution: $DISTRO'
            echo '🐚 Shell: $SHELL'
            echo ''
            echo '📥 Téléchargement du script bootstrap...'
            curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh -o /tmp/bootstrap.sh || {
                echo '❌ Erreur: Impossible de télécharger bootstrap.sh'
                echo '💡 Vérifiez votre connexion internet'
                exit 1
            }
            chmod +x /tmp/bootstrap.sh
            echo '✅ Script bootstrap téléchargé'
            echo ''
            echo '🚀 Lancement de l'\''installation...'
            echo ''
            /tmp/bootstrap.sh
            echo ''
            echo '✅ Installation terminée!'
            echo '💡 Vous pouvez maintenant tester les dotfiles'
            echo ''
            exec $SHELL_BIN
        "
else
    # Mode dotfiles pré-installés
    echo -e "${YELLOW}📦 Mode: Dotfiles pré-installés${NC}"
    echo -e "${CYAN}💡 Les dotfiles sont montés dans le conteneur${NC}"
    echo ""
    
    docker run -it --rm \
        --name "$CONTAINER_NAME" \
        -v "$DOTFILES_DIR:/root/dotfiles:ro" \
        -e HOME=/root \
        -e TERM=xterm-256color \
        -e DOTFILES_DIR=/root/dotfiles \
        -e SHELL="$SHELL" \
        "$IMAGE_NAME:latest" \
        "$SHELL_BIN" -c "
            echo '🧪 Test avec dotfiles pré-installés'
            echo '📦 Distribution: $DISTRO'
            echo '🐚 Shell: $SHELL'
            echo ''
            if [ -f /root/dotfiles/zsh/zshrc_custom ]; then
                echo '✅ Dotfiles trouvés dans /root/dotfiles'
                export DOTFILES_DIR=/root/dotfiles
                export DOTFILES_ZSH_PATH=/root/dotfiles/zsh
                if [ '$SHELL' = 'zsh' ] && [ -f /root/dotfiles/zsh/zshrc_custom ]; then
                    . /root/dotfiles/zsh/zshrc_custom
                fi
            else
                echo '❌ Dotfiles non trouvés'
            fi
            echo ''
            echo '💡 Vous pouvez maintenant tester les dotfiles'
            echo ''
            exec $SHELL_BIN
        "
fi

