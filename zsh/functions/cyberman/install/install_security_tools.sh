#!/bin/bash
# =============================================================================
# INSTALL SECURITY TOOLS - Installation des outils de sécurité pour cyberman
# =============================================================================
# Description: Installe tous les outils de sécurité nécessaires
# Author: Paul Delhomme
# Version: 1.1 - Ajout vérification si outils déjà installés
# =============================================================================

# Ne pas exécuter automatiquement si sourcé (méthode standard)
# Ce script doit être appelé explicitement
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return 0 2>/dev/null || exit 0
fi

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${CYAN}🛡️  Installation des outils de sécurité Cyberman${RESET}"
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

# Outils disponibles via pacman/apt
# Vérifier d'abord quels outils manquent
missing_tools=()
if [ "$PKG_MANAGER" = "pacman" ]; then
    tools_base=("burpsuite" "nikto" "sqlmap" "nmap" "wireshark-cli" "metasploit" "whois" "dnsutils" "jq")
    for tool in "${tools_base[@]}"; do
        if ! check_package_installed_pacman "$tool" 2>/dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${CYAN}📦 Installation des outils de base manquants (${#missing_tools[@]} sur ${#tools_base[@]})...${RESET}"
        sudo pacman -S --noconfirm "${missing_tools[@]}" || true
    else
        echo -e "${GREEN}✅ Tous les outils de base sont déjà installés${RESET}"
    fi
elif [ "$PKG_MANAGER" = "apt" ]; then
    tools_base=("burpsuite" "nikto" "sqlmap" "nmap" "tshark" "metasploit-framework" "whois" "dnsutils" "jq")
    for tool in "${tools_base[@]}"; do
        if ! dpkg -l | grep -q "^ii.*$tool " 2>/dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${CYAN}📦 Installation des outils de base manquants (${#missing_tools[@]} sur ${#tools_base[@]})...${RESET}"
        sudo apt update -qq
        sudo apt install -y "${missing_tools[@]}" || true
    else
        echo -e "${GREEN}✅ Tous les outils de base sont déjà installés${RESET}"
    fi
fi

# Outils AUR (Arch seulement)
if [ "$PKG_MANAGER" = "pacman" ] && command -v yay >/dev/null 2>&1; then
    tools_aur=("xsstrike" "dalfox" "nuclei" "ffuf" "wfuzz" "commix" "subfinder" "theharvester")
    missing_aur=()
    
    for tool in "${tools_aur[@]}"; do
        if ! check_package_installed_pacman "$tool" 2>/dev/null; then
            missing_aur+=("$tool")
        fi
    done
    
    if [ ${#missing_aur[@]} -gt 0 ]; then
        echo -e "${CYAN}📦 Installation des outils AUR manquants (${#missing_aur[@]} sur ${#tools_aur[@]})...${RESET}"
        yay -S --noconfirm "${missing_aur[@]}" || true
    else
        echo -e "${GREEN}✅ Tous les outils AUR sont déjà installés${RESET}"
    fi
fi

# Créer les répertoires nécessaires
echo -e "${CYAN}📁 Création des répertoires...${RESET}"
mkdir -p ~/.cyberman/{scans/{nuclei,xss,sqlmap,fuzzer},templates/nuclei,reports,config}
# Sécuriser les permissions (700 pour dossiers, 600 pour fichiers)
chmod -R 700 ~/.cyberman 2>/dev/null || true
find ~/.cyberman -type f -exec chmod 600 {} \; 2>/dev/null || true
chown -R "$USER:$USER" ~/.cyberman 2>/dev/null || true

# Mettre à jour les templates Nuclei
if command -v nuclei >/dev/null 2>&1; then
    echo -e "${CYAN}🔄 Mise à jour des templates Nuclei...${RESET}"
    nuclei -update-templates 2>/dev/null || true
fi

# Configuration initiale
echo -e "${CYAN}⚙️  Configuration initiale...${RESET}"
cat > ~/.cyberman/config.yaml <<EOF
# Cyberman Security Configuration
scan_output_dir: ~/.cyberman/scans
template_dir: ~/.cyberman/templates
report_dir: ~/.cyberman/reports

tools:
  xsstrike:
    threads: 20
    crawl: true
  nuclei:
    severity: critical,high,medium
    rate_limit: 150
  sqlmap:
    level: 3
    risk: 2
  ffuf:
    threads: 50
    timeout: 10
EOF

echo ""
echo -e "${GREEN}✅ Installation terminée !${RESET}"
echo ""
echo "📋 Outils installés:"
echo "   - Nuclei (scanner de vulnérabilités)"
echo "   - XSStrike (scanner XSS)"
echo "   - Dalfox (scanner XSS rapide)"
echo "   - SQLMap (SQL injection)"
echo "   - ffuf (fuzzer rapide)"
echo "   - wfuzz (fuzzer Python)"
echo "   - Burp Suite"
echo "   - Nikto"
echo ""
echo "💡 Utilisation:"
echo "   - Lancez cyberman pour accéder aux outils"
echo "   - Les scans sont sauvegardés dans ~/.cyberman/scans/"

