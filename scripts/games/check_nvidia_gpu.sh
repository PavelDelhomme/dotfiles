#!/bin/bash

################################################################################
# Script de vérification de la configuration NVIDIA GPU
# Vérifie que la RTX 3060 est bien détectée et utilisée
################################################################################

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Vérification Configuration NVIDIA RTX 3060          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Vérifier la carte graphique
echo -e "${CYAN}[1] Détection carte graphique:${NC}"
if lspci | grep -qi nvidia; then
    GPU_INFO=$(lspci | grep -i nvidia)
    echo -e "${GREEN}✓ Carte NVIDIA détectée:${NC}"
    echo "  $GPU_INFO"
else
    echo -e "${RED}✗ Aucune carte NVIDIA détectée${NC}"
    exit 1
fi
echo ""

# 2. Vérifier les drivers NVIDIA
echo -e "${CYAN}[2] Drivers NVIDIA:${NC}"
if command -v nvidia-smi >/dev/null 2>&1; then
    echo -e "${GREEN}✓ nvidia-smi disponible${NC}"
    echo ""
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader | while IFS=',' read -r name driver memory; do
        echo "  Carte: $(echo $name | xargs)"
        echo "  Driver: $(echo $driver | xargs)"
        echo "  Mémoire: $(echo $memory | xargs)"
    done
else
    echo -e "${RED}✗ nvidia-smi non disponible${NC}"
    echo -e "${YELLOW}  Installez les drivers: sudo pacman -S nvidia nvidia-utils${NC}"
fi
echo ""

# 3. Vérifier les paquets installés
echo -e "${CYAN}[3] Paquets NVIDIA installés:${NC}"
if pacman -Qi nvidia >/dev/null 2>&1; then
    NVIDIA_VERSION=$(pacman -Qi nvidia | grep "^Version" | awk '{print $3}')
    echo -e "${GREEN}✓ nvidia: $NVIDIA_VERSION${NC}"
else
    echo -e "${RED}✗ nvidia non installé${NC}"
fi

if pacman -Qi nvidia-utils >/dev/null 2>&1; then
    NVIDIA_UTILS_VERSION=$(pacman -Qi nvidia-utils | grep "^Version" | awk '{print $3}')
    echo -e "${GREEN}✓ nvidia-utils: $NVIDIA_UTILS_VERSION${NC}"
else
    echo -e "${RED}✗ nvidia-utils non installé${NC}"
fi

if pacman -Qi lib32-nvidia-utils >/dev/null 2>&1; then
    echo -e "${GREEN}✓ lib32-nvidia-utils installé${NC}"
else
    echo -e "${YELLOW}⚠️  lib32-nvidia-utils non installé (recommandé pour Wine)${NC}"
fi
echo ""

# 4. Vérifier OpenGL
echo -e "${CYAN}[4] OpenGL (rendu actuel):${NC}"
if command -v glxinfo >/dev/null 2>&1; then
    GL_RENDERER=$(glxinfo | grep "OpenGL renderer" | cut -d: -f2 | xargs)
    if echo "$GL_RENDERER" | grep -qi nvidia; then
        echo -e "${GREEN}✓ OpenGL utilise NVIDIA:${NC}"
        echo "  $GL_RENDERER"
    else
        echo -e "${YELLOW}⚠️  OpenGL n'utilise PAS NVIDIA:${NC}"
        echo "  $GL_RENDERER"
        echo -e "${YELLOW}  Utilisez: __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  glxinfo non disponible (installez: sudo pacman -S mesa-utils)${NC}"
fi
echo ""

# 5. Vérifier Vulkan
echo -e "${CYAN}[5] Vulkan NVIDIA:${NC}"
if [ -f /usr/share/vulkan/icd.d/nvidia_icd.json ]; then
    echo -e "${GREEN}✓ Fichier Vulkan NVIDIA trouvé${NC}"
    if vulkaninfo 2>/dev/null | grep -qi "nvidia\|rtx\|geforce"; then
        echo -e "${GREEN}✓ Vulkan détecte NVIDIA${NC}"
    else
        echo -e "${YELLOW}⚠️  Vulkan ne détecte pas NVIDIA (vérifiez vulkaninfo)${NC}"
    fi
else
    echo -e "${RED}✗ Fichier Vulkan NVIDIA non trouvé${NC}"
    echo -e "${YELLOW}  Installez: sudo pacman -S nvidia-utils${NC}"
fi
echo ""

# 6. Vérifier les variables d'environnement recommandées
echo -e "${CYAN}[6] Variables d'environnement recommandées:${NC}"
echo "  Pour forcer NVIDIA avec PortProton/Wine:"
echo ""
echo "  export __NV_PRIME_RENDER_OFFLOAD=1"
echo "  export __GLX_VENDOR_LIBRARY_NAME=nvidia"
echo "  export __VK_LAYER_NV_optimus=NVIDIA_only"
echo "  export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json"
echo ""

# 7. Test rapide
echo -e "${CYAN}[7] Test rapide GPU:${NC}"
if nvidia-smi >/dev/null 2>&1; then
    GPU_UTIL=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -1)
    GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -1)
    GPU_MEM=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader | head -1)
    echo -e "${GREEN}✓ GPU actif${NC}"
    echo "  Utilisation: ${GPU_UTIL}%"
    echo "  Température: ${GPU_TEMP}°C"
    echo "  Mémoire: $GPU_MEM"
else
    echo -e "${RED}✗ Impossible d'interroger le GPU${NC}"
fi
echo ""

# Résumé
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}📝 Résumé:${NC}"
echo ""

if command -v nvidia-smi >/dev/null 2>&1 && \
   pacman -Qi nvidia >/dev/null 2>&1 && \
   pacman -Qi nvidia-utils >/dev/null 2>&1 && \
   [ -f /usr/share/vulkan/icd.d/nvidia_icd.json ]; then
    echo -e "${GREEN}✅ Configuration NVIDIA complète!${NC}"
    echo ""
    echo -e "${GREEN}✓ Carte détectée${NC}"
    echo -e "${GREEN}✓ Drivers installés${NC}"
    echo -e "${GREEN}✓ Vulkan configuré${NC}"
    echo ""
    echo -e "${CYAN}💡 Pour lancer ULTRAKILL avec NVIDIA:${NC}"
    echo "   ultrakill"
    echo "   # ou"
    echo "   bash ~/dotfiles/scripts/games/run_ultrakill.sh"
else
    echo -e "${YELLOW}⚠️  Configuration incomplète${NC}"
    echo ""
    echo -e "${YELLOW}Installez les dépendances manquantes:${NC}"
    echo "   bash ~/dotfiles/scripts/games/install_gaming_deps.sh"
fi
echo ""

