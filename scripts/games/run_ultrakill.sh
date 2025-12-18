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
# Forcer l'utilisation de la carte NVIDIA RTX 3060
# Variables d'environnement pour NVIDIA offload
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __VK_LAYER_NV_optimus=NVIDIA_only

# Variables d'environnement pour Wine/PortProton
export DXVK_HUD=1  # Afficher les stats DXVK (optionnel, pour debug)
export WINEDEBUG=-all  # Désactiver les logs Wine (optionnel, pour performance)
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json  # Forcer Vulkan NVIDIA

# Vérifier que NVIDIA est utilisé
echo -e "${BLUE}🎮 Configuration GPU:${NC}"
if [ -f /usr/share/vulkan/icd.d/nvidia_icd.json ]; then
    echo -e "${GREEN}✓ Vulkan NVIDIA configuré${NC}"
else
    echo -e "${YELLOW}⚠️  Fichier Vulkan NVIDIA non trouvé${NC}"
fi

# Configuration multi-écrans - Forcer l'écran principal (DP-1)
echo -e "${BLUE}🖥️  Configuration écran:${NC}"
PRIMARY_DISPLAY=$(xrandr --listactivemonitors 2>/dev/null | grep -E "^\s*0:" | awk '{print $4}' | sed 's/\+//' || echo "DP-1")
echo -e "${GREEN}✓ Écran principal détecté: $PRIMARY_DISPLAY${NC}"

# Variables d'environnement pour forcer l'écran principal
# SDL_VIDEO_FULLSCREEN_DISPLAY force SDL à utiliser un écran spécifique
export SDL_VIDEO_FULLSCREEN_DISPLAY=0  # 0 = premier écran (DP-1)
export SDL_VIDEODRIVER=x11  # Forcer X11
export DISPLAY=:0  # Forcer display 0

# Pour Wine/X11, forcer la position de la fenêtre sur l'écran principal
# L'écran principal (DP-1) est à la position +1920+0
export WINE_DISPLAY=:0

# Utiliser gamescope pour forcer l'affichage sur l'écran principal
# gamescope peut forcer une sortie spécifique
if command -v gamescope >/dev/null 2>&1; then
    echo -e "${GREEN}✓ gamescope disponible (peut forcer l'écran)${NC}"
    # Option: utiliser gamescope avec --output pour forcer DP-1
    # Mais PortProton gère déjà gamescope, donc on configure via variables
fi

echo ""
echo -e "${BLUE}🚀 Lancement avec PortProton (NVIDIA + Écran principal)...${NC}"
echo ""

# Lancer le jeu avec l'option --launch pour un lancement direct
# Cela évite l'interface graphique et lance directement le jeu
exec bash "$PORTPROTON_SCRIPT" --launch "$ULTRAKILL_EXE"

