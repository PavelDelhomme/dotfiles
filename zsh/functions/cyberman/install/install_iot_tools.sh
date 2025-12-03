#!/bin/bash
# =============================================================================
# INSTALL IOT TOOLS - Installation des outils pour le module IoT de cyberman
# =============================================================================
# Description: Installe tous les outils nécessaires pour le module IoT
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Ne pas exécuter automatiquement si sourcé depuis zshrc_custom
[ -z "$CYBERMAN_INSTALL_MODE" ] && return 0 2>/dev/null || true

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo -e "${CYAN}📡 Installation des outils IoT pour Cyberman${RESET}"
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

# Outils IoT disponibles via pacman/apt
missing_tools=()
if [ "$PKG_MANAGER" = "pacman" ]; then
    tools_base=("nmap" "wireshark-cli" "tshark" "tcpdump" "mosquitto-clients" "coap-client")
    for tool in "${tools_base[@]}"; do
        if ! check_package_installed_pacman "$tool" 2>/dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${CYAN}📦 Installation des outils IoT de base manquants (${#missing_tools[@]} sur ${#tools_base[@]})...${RESET}"
        sudo pacman -S --noconfirm "${missing_tools[@]}" || true
    else
        echo -e "${GREEN}✅ Tous les outils IoT de base sont déjà installés${RESET}"
    fi
elif [ "$PKG_MANAGER" = "apt" ]; then
    tools_base=("nmap" "tshark" "tcpdump" "mosquitto-clients" "coap-client")
    for tool in "${tools_base[@]}"; do
        if ! dpkg -l | grep -q "^ii.*$tool " 2>/dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${CYAN}📦 Installation des outils IoT de base manquants (${#missing_tools[@]} sur ${#tools_base[@]})...${RESET}"
        sudo apt update -qq
        sudo apt install -y "${missing_tools[@]}" || true
    else
        echo -e "${GREEN}✅ Tous les outils IoT de base sont déjà installés${RESET}"
    fi
fi

# Outils AUR (Arch seulement) pour IoT
if [ "$PKG_MANAGER" = "pacman" ] && command -v yay >/dev/null 2>&1; then
    tools_aur=("shodan" "masscan" "zmap")
    missing_aur=()
    
    for tool in "${tools_aur[@]}"; do
        if ! check_package_installed_pacman "$tool" 2>/dev/null; then
            missing_aur+=("$tool")
        fi
    done
    
    if [ ${#missing_aur[@]} -gt 0 ]; then
        echo -e "${CYAN}📦 Installation des outils IoT AUR manquants (${#missing_aur[@]} sur ${#tools_aur[@]})...${RESET}"
        yay -S --noconfirm "${missing_aur[@]}" || true
    else
        echo -e "${GREEN}✅ Tous les outils IoT AUR sont déjà installés${RESET}"
    fi
fi

# Créer les répertoires nécessaires pour IoT
echo -e "${CYAN}📁 Création des répertoires IoT...${RESET}"
mkdir -p ~/.cyberman/{scans/iot,reports/iot,config/iot}

# Configuration initiale IoT
echo -e "${CYAN}⚙️  Configuration initiale IoT...${RESET}"
cat > ~/.cyberman/config/iot.yaml <<EOF
# Cyberman IoT Configuration
scan_output_dir: ~/.cyberman/scans/iot
report_dir: ~/.cyberman/reports/iot

tools:
  nmap:
    scan_type: -sS
    timing: -T4
  masscan:
    rate: 1000
  shodan:
    api_key: ""
EOF

echo ""
echo -e "${GREEN}✅ Installation terminée !${RESET}"
echo ""
echo "📋 Outils IoT installés:"
echo "   - Nmap (scanner réseau)"
echo "   - Wireshark/TShark (analyse de trafic)"
echo "   - Tcpdump (capture de paquets)"
echo "   - Mosquitto (client MQTT)"
echo "   - CoAP Client (protocole IoT)"
echo ""
echo "💡 Utilisation:"
echo "   - Lancez cyberman pour accéder au module IoT"
echo "   - Les scans sont sauvegardés dans ~/.cyberman/scans/iot/"

