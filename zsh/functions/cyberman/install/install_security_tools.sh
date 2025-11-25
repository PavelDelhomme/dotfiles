#!/bin/bash
# =============================================================================
# INSTALL SECURITY TOOLS - Installation des outils de sécurité pour cyberman
# =============================================================================
# Description: Installe tous les outils de sécurité nécessaires
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${CYAN}🛡️  Installation des outils de sécurité Cyberman${RESET}"
echo ""

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
echo -e "${CYAN}📦 Installation des outils de base...${RESET}"
if [ "$PKG_MANAGER" = "pacman" ]; then
    sudo pacman -S --noconfirm \
        burpsuite \
        nikto \
        sqlmap \
        nmap \
        wireshark-cli \
        metasploit \
        whois \
        dnsutils \
        jq || true
elif [ "$PKG_MANAGER" = "apt" ]; then
    sudo apt update
    sudo apt install -y \
        burpsuite \
        nikto \
        sqlmap \
        nmap \
        tshark \
        metasploit-framework \
        whois \
        dnsutils \
        jq || true
fi

# Outils AUR (Arch seulement)
if [ "$PKG_MANAGER" = "pacman" ] && command -v yay >/dev/null 2>&1; then
    echo -e "${CYAN}📦 Installation des outils AUR...${RESET}"
    yay -S --noconfirm \
        xsstrike \
        dalfox \
        nuclei \
        ffuf \
        wfuzz \
        commix \
        subfinder \
        theharvester || true
fi

# Créer les répertoires nécessaires
echo -e "${CYAN}📁 Création des répertoires...${RESET}"
mkdir -p ~/.cyberman/{scans/{nuclei,xss,sqlmap,fuzzer},templates/nuclei,reports,config}

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

