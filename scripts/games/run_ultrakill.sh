#!/bin/bash

################################################################################
# Script pour lancer ULTRAKILL avec PortProton
# Résout les problèmes de vidéo/audio
################################################################################

set -e

ULTRAKILL_DIR="/home/pactivisme/Documents/Games/ULTRAKILL"
ULTRAKILL_EXE="$ULTRAKILL_DIR/ULTRAKILL.exe"
PORTPROTON_SCRIPT="$HOME/.local/share/PortProton/data_from_portwine/scripts/start.sh"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Lancement d'ULTRAKILL avec PortProton                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Vérifier que PortProton est installé
if [ ! -f "$PORTPROTON_SCRIPT" ]; then
    echo -e "${RED}❌ PortProton non trouvé!${NC}"
    echo -e "${YELLOW}💡 Installez PortProton avec:${NC}"
    echo "   bash ~/dotfiles/scripts/install/apps/install_portproton_native.sh"
    exit 1
fi

# Vérifier que le jeu existe
if [ ! -f "$ULTRAKILL_EXE" ]; then
    echo -e "${RED}❌ ULTRAKILL.exe non trouvé!${NC}"
    echo -e "${YELLOW}📍 Chemin attendu: $ULTRAKILL_EXE${NC}"
    exit 1
fi

echo -e "${GREEN}✓ PortProton trouvé${NC}"
echo -e "${GREEN}✓ ULTRAKILL.exe trouvé${NC}"
echo ""

# Vérifier les dépendances vidéo/audio
echo -e "${BLUE}🔍 Vérification des dépendances...${NC}"

# Vérifier Vulkan
if ! pacman -Qi vulkan-icd-loader >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  vulkan-icd-loader non installé${NC}"
    echo -e "${YELLOW}💡 Installation recommandée: sudo pacman -S vulkan-icd-loader${NC}"
fi

# Vérifier les drivers vidéo
if lspci | grep -qi nvidia; then
    if ! pacman -Qi vulkan-nvidia >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  vulkan-nvidia non installé (recommandé pour NVIDIA)${NC}"
    else
        echo -e "${GREEN}✓ Driver Vulkan NVIDIA détecté${NC}"
    fi
elif lspci | grep -qi intel; then
    if ! pacman -Qi vulkan-intel >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  vulkan-intel non installé (recommandé pour Intel)${NC}"
    else
        echo -e "${GREEN}✓ Driver Vulkan Intel détecté${NC}"
    fi
fi

# Vérifier gamescope
if ! pacman -Qi gamescope >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  gamescope non installé${NC}"
    echo -e "${YELLOW}💡 Installation: sudo pacman -S gamescope${NC}"
else
    echo -e "${GREEN}✓ gamescope installé${NC}"
fi

# Vérifier PulseAudio/PipeWire
if pgrep -x pulseaudio >/dev/null 2>&1 || pgrep -x pipewire >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Serveur audio détecté${NC}"
else
    echo -e "${YELLOW}⚠️  Aucun serveur audio détecté${NC}"
    echo -e "${YELLOW}💡 Démarrez PulseAudio ou PipeWire${NC}"
fi

echo ""
echo -e "${BLUE}🚀 Lancement d'ULTRAKILL...${NC}"
echo -e "${BLUE}📍 Chemin: $ULTRAKILL_EXE${NC}"
echo ""

# Changer dans le répertoire du jeu
cd "$ULTRAKILL_DIR"

# Lancer avec PortProton
# Options possibles:
# - --run : Lancer un exécutable
# - Variables d'environnement pour forcer la détection vidéo/audio
export DXVK_HUD=1  # Afficher les stats DXVK (optionnel)
export WINEDEBUG=-all  # Désactiver les logs Wine (optionnel, pour performance)

# Lancer le jeu
exec bash "$PORTPROTON_SCRIPT" "$ULTRAKILL_EXE"

