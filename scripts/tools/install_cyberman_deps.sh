#!/bin/bash
# =============================================================================
# Installation des dépendances pour cyberman (workflows et rapports)
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📦 Installation des dépendances pour cyberman${NC}"
echo ""

# Détecter la distribution
if [ -f /etc/arch-release ]; then
    DISTRO="arch"
elif [ -f /etc/debian_version ]; then
    DISTRO="debian"
elif [ -f /etc/fedora-release ]; then
    DISTRO="fedora"
else
    DISTRO="unknown"
fi

install_jq() {
    if command -v jq >/dev/null 2>&1; then
        echo -e "${GREEN}✅ jq déjà installé${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}📦 Installation de jq...${NC}"
    
    case "$DISTRO" in
        arch)
            if command -v yay >/dev/null 2>&1; then
                yay -S --noconfirm jq 2>/dev/null || sudo pacman -S --noconfirm jq
            else
                sudo pacman -S --noconfirm jq
            fi
            ;;
        debian)
            sudo apt-get update -qq && sudo apt-get install -y jq
            ;;
        fedora)
            sudo dnf install -y jq
            ;;
        *)
            echo -e "${YELLOW}⚠️  Distribution non supportée. Installez jq manuellement.${NC}"
            echo "   https://stedolan.github.io/jq/download/"
            return 1
            ;;
    esac
    
    if command -v jq >/dev/null 2>&1; then
        echo -e "${GREEN}✅ jq installé avec succès${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Échec de l'installation de jq${NC}"
        return 1
    fi
}

install_jq

echo ""
echo -e "${GREEN}✅ Installation terminée${NC}"
echo ""
echo "💡 jq est requis pour:"
echo "   - Gestion des environnements (sauvegarde/chargement)"
echo "   - Gestion des workflows (création/exécution)"
echo "   - Gestion des rapports (génération/visualisation)"

