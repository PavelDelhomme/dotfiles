#!/bin/bash
# =============================================================================
# Script d'installation des visualiseurs Markdown pour les pages man
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SCRIPT_DIR="$DOTFILES_DIR/scripts"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📦 Installation des visualiseurs Markdown pour les pages man${NC}"
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

install_tool() {
    local tool="$1"
    local arch_pkg="$2"
    local debian_pkg="${3:-$arch_pkg}"
    local fedora_pkg="${4:-$arch_pkg}"
    
    if command -v "$tool" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $tool déjà installé${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}📦 Installation de $tool...${NC}"
    
    case "$DISTRO" in
        arch)
            if command -v yay >/dev/null 2>&1; then
                yay -S --noconfirm "$arch_pkg" 2>/dev/null || {
                    echo -e "${YELLOW}⚠️  Installation via pacman...${NC}"
                    sudo pacman -S --noconfirm "$arch_pkg" 2>/dev/null
                }
            else
                sudo pacman -S --noconfirm "$arch_pkg" 2>/dev/null
            fi
            ;;
        debian)
            sudo apt-get update -qq && sudo apt-get install -y "$debian_pkg" 2>/dev/null
            ;;
        fedora)
            sudo dnf install -y "$fedora_pkg" 2>/dev/null
            ;;
        *)
            echo -e "${YELLOW}⚠️  Distribution non supportée. Installez $tool manuellement.${NC}"
            return 1
            ;;
    esac
    
    if command -v "$tool" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $tool installé avec succès${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Échec de l'installation de $tool${NC}"
        return 1
    fi
}

# Options disponibles
echo "Options de visualisation Markdown:"
echo "  1. bat (recommandé) - Coloration syntaxique, support Markdown natif"
echo "  2. glow - Visualiseur Markdown interactif"
echo "  3. mdcat - Visualiseur Markdown en terminal"
echo "  4. pandoc + groff - Conversion en format man système"
echo "  5. pygmentize - Coloration pour less"
echo ""

read -p "Quel(s) outil(s) voulez-vous installer? (1-5, ou 'all' pour tous): " choice

case "$choice" in
    1)
        install_tool "bat" "bat"
        ;;
    2)
        install_tool "glow" "glow"
        ;;
    3)
        install_tool "mdcat" "mdcat"
        ;;
    4)
        install_tool "pandoc" "pandoc" "pandoc" "pandoc"
        install_tool "groff" "groff" "groff" "groff"
        ;;
    5)
        install_tool "pygmentize" "python-pygments" "python3-pygments" "python3-pygments"
        ;;
    all|ALL)
        install_tool "bat" "bat"
        install_tool "glow" "glow"
        install_tool "mdcat" "mdcat"
        install_tool "pandoc" "pandoc" "pandoc" "pandoc"
        install_tool "groff" "groff" "groff" "groff"
        install_tool "pygmentize" "python-pygments" "python3-pygments" "python3-pygments"
        ;;
    *)
        echo "Installation annulée"
        exit 0
        ;;
esac

echo ""
echo -e "${GREEN}✅ Installation terminée${NC}"
echo ""
echo "💡 La fonction man() utilisera automatiquement le meilleur outil disponible"
echo "💡 Ordre de priorité: pandoc+groff > bat > mdcat > glow > pygmentize > less > cat"

