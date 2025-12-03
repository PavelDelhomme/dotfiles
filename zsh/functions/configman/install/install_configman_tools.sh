#!/bin/bash
# =============================================================================
# INSTALL CONFIGMAN TOOLS - Installation des outils nécessaires pour configman
# =============================================================================
# Description: Installe tous les outils nécessaires pour les modules configman
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Ne pas exécuter automatiquement si sourcé depuis zshrc_custom
[ -z "$CONFIGMAN_INSTALL_MODE" ] && return 0 2>/dev/null || true

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo -e "${CYAN}⚙️  Installation des outils Configman${RESET}"
echo ""

# Fonction pour vérifier si un outil est installé
check_tool_installed() {
    local tool="$1"
    if command -v "$tool" >/dev/null 2>&1; then
        return 0  # Installé
    else
        return 1  # Non installé
    fi
}

# Fonction pour vérifier si un paquet est installé (pacman)
check_package_installed_pacman() {
    local package="$1"
    if pacman -Qi "$package" >/dev/null 2>&1; then
        return 0  # Installé
    else
        return 1  # Non installé
    fi
}

# Détecter le gestionnaire de paquets
if command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
    AUR_HELPER="yay"
elif command -v apt >/dev/null 2>&1; then
    PKG_MANAGER="apt"
    AUR_HELPER=""
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
    AUR_HELPER=""
else
    echo -e "${RED}❌ Gestionnaire de paquets non supporté${RESET}"
    exit 1
fi

# Vérifier yay pour Arch
if [ "$PKG_MANAGER" = "pacman" ] && ! command -v yay >/dev/null 2>&1; then
    echo -e "${YELLOW}📦 Installation de yay (AUR helper)...${RESET}"
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd -
fi

# =============================================================================
# OUTILS POUR MODULE SSH
# =============================================================================
echo -e "${BLUE}🔐 Outils SSH${RESET}"

ssh_tools=("openssh")
missing_ssh=()

for tool in "${ssh_tools[@]}"; do
    if [ "$PKG_MANAGER" = "pacman" ]; then
        if ! check_package_installed_pacman "$tool" 2>/dev/null; then
            missing_ssh+=("$tool")
        fi
    elif [ "$PKG_MANAGER" = "apt" ]; then
        if ! dpkg -l | grep -q "^ii.*$tool " 2>/dev/null; then
            missing_ssh+=("$tool")
        fi
    fi
done

if [ ${#missing_ssh[@]} -gt 0 ]; then
    echo -e "${CYAN}📦 Installation des outils SSH manquants...${RESET}"
    if [ "$PKG_MANAGER" = "pacman" ]; then
        sudo pacman -S --noconfirm "${missing_ssh[@]}" || true
    elif [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt update -qq
        sudo apt install -y "${missing_ssh[@]}" || true
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf install -y "${missing_ssh[@]}" || true
    fi
else
    echo -e "${GREEN}✅ Tous les outils SSH sont déjà installés${RESET}"
fi

# Vérifier ssh-copy-id (généralement inclus avec openssh)
if ! command -v ssh-copy-id >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  ssh-copy-id non trouvé, installation...${RESET}"
    if [ "$PKG_MANAGER" = "pacman" ]; then
        sudo pacman -S --noconfirm openssh || true
    elif [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt install -y openssh-client || true
    fi
fi

echo ""

# =============================================================================
# OUTILS POUR MODULE GIT
# =============================================================================
echo -e "${BLUE}📦 Outils Git${RESET}"

if ! check_tool_installed "git"; then
    echo -e "${CYAN}📦 Installation de Git...${RESET}"
    if [ "$PKG_MANAGER" = "pacman" ]; then
        sudo pacman -S --noconfirm git || true
    elif [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt update -qq
        sudo apt install -y git || true
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf install -y git || true
    fi
else
    echo -e "${GREEN}✅ Git est déjà installé${RESET}"
fi

echo ""

# =============================================================================
# OUTILS POUR MODULE SHELL
# =============================================================================
echo -e "${BLUE}🐚 Outils Shell${RESET}"

shell_tools=("zsh" "bash" "fish")
missing_shell=()

for tool in "${shell_tools[@]}"; do
    if ! check_tool_installed "$tool"; then
        missing_shell+=("$tool")
    fi
done

if [ ${#missing_shell[@]} -gt 0 ]; then
    echo -e "${CYAN}📦 Installation des shells manquants...${RESET}"
    if [ "$PKG_MANAGER" = "pacman" ]; then
        sudo pacman -S --noconfirm "${missing_shell[@]}" || true
    elif [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt update -qq
        sudo apt install -y "${missing_shell[@]}" || true
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf install -y "${missing_shell[@]}" || true
    fi
else
    echo -e "${GREEN}✅ Tous les shells sont déjà installés${RESET}"
fi

echo ""

# =============================================================================
# OUTILS POUR MODULE QEMU (si nécessaire)
# =============================================================================
echo -e "${BLUE}🖥️  Outils QEMU (optionnel)${RESET}"
echo -e "${YELLOW}💡 Les outils QEMU peuvent être installés via: configman qemu-packages${RESET}"
echo ""

# =============================================================================
# RÉSUMÉ
# =============================================================================
echo ""
echo -e "${GREEN}✅ Installation terminée !${RESET}"
echo ""
echo "📋 Outils installés:"
echo "   - OpenSSH (pour module SSH)"
echo "   - Git (pour module Git)"
echo "   - Shells (zsh, bash, fish pour module Shell)"
echo ""
echo "💡 Utilisation:"
echo "   - Lancez configman pour accéder aux modules"
echo "   - Les modules QEMU nécessitent: configman qemu-packages"

