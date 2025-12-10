#!/bin/zsh
# =============================================================================
# INSTALL OSINT TOOLS - Installation des outils OSINT
# =============================================================================
# Description: Installation automatique des outils OSINT avec IA
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Installe les outils OSINT
# USAGE: install_osint_tools
# EXAMPLE: install_osint_tools
function install_osint_tools() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    local UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        source "$UTILS_DIR/ensure_tool.sh" 2>/dev/null
    fi
    
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║          INSTALLATION OUTILS OSINT AVEC IA                    ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${RESET}\n"
    
    # Vérifier les prérequis
    if ! command -v git &>/dev/null; then
        echo -e "${RED}❌ git n'est pas installé${RESET}"
        return 1
    fi
    
    if ! command -v python3 &>/dev/null; then
        echo -e "${RED}❌ python3 n'est pas installé${RESET}"
        return 1
    fi
    
    mkdir -p "$HOME/.local/share"
    
    # Liste des outils à installer
    local tools=(
        "sherlock:sherlock-project/sherlock:OSINT username search"
        "theHarvester:laramies/theHarvester:Collecte emails/sous-domaines"
        "recon-ng:lanmaster53/recon-ng:Framework reconnaissance web"
    )
    
    echo -e "${YELLOW}${BOLD}Outils OSINT disponibles:${RESET}\n"
    echo "1.  Sherlock (username search)"
    echo "2.  TheHarvester (collecte emails/sous-domaines)"
    echo "3.  Recon-ng (framework reconnaissance)"
    echo "4.  Taranis AI (OSINT avec IA)"
    echo "5.  SpiderFoot (collecte automatisée)"
    echo "6.  Installer tous les outils de base"
    echo "0.  Retour"
    echo ""
    printf "Choix: "
    read -r choice
    choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
    
    case "$choice" in
        1)
            _install_sherlock
            ;;
        2)
            _install_theharvester
            ;;
        3)
            _install_recon_ng
            ;;
        4)
            _install_taranis_ai
            ;;
        5)
            _install_spiderfoot
            ;;
        6)
            _install_sherlock
            _install_theharvester
            _install_recon_ng
            ;;
        0)
            return 0
            ;;
        *)
            echo -e "${RED}Choix invalide${RESET}"
            ;;
    esac
}

_install_sherlock() {
    local SHERLOCK_DIR="$HOME/.local/share/sherlock"
    echo -e "${CYAN}Installation de Sherlock...${RESET}"
    
    if [ -d "$SHERLOCK_DIR" ]; then
        cd "$SHERLOCK_DIR" && git pull
    else
        git clone https://github.com/sherlock-project/sherlock.git "$SHERLOCK_DIR"
    fi
    
    cd "$SHERLOCK_DIR" || return 1
    if [ -f "requirements.txt" ]; then
        pip3 install -r requirements.txt --user
    fi
    echo -e "${GREEN}✓ Sherlock installé${RESET}\n"
}

_install_theharvester() {
    local HARVESTER_DIR="$HOME/.local/share/theHarvester"
    echo -e "${CYAN}Installation de TheHarvester...${RESET}"
    
    if [ -d "$HARVESTER_DIR" ]; then
        cd "$HARVESTER_DIR" && git pull
    else
        git clone https://github.com/laramies/theHarvester.git "$HARVESTER_DIR"
    fi
    
    cd "$HARVESTER_DIR" || return 1
    if [ -f "requirements.txt" ]; then
        pip3 install -r requirements.txt --user
    fi
    echo -e "${GREEN}✓ TheHarvester installé${RESET}\n"
}

_install_recon_ng() {
    local RECON_DIR="$HOME/.local/share/recon-ng"
    echo -e "${CYAN}Installation de Recon-ng...${RESET}"
    
    if [ -d "$RECON_DIR" ]; then
        cd "$RECON_DIR" && git pull
    else
        git clone https://github.com/lanmaster53/recon-ng.git "$RECON_DIR"
    fi
    
    cd "$RECON_DIR" || return 1
    if [ -f "requirements.txt" ]; then
        pip3 install -r requirements.txt --user
    fi
    echo -e "${GREEN}✓ Recon-ng installé${RESET}\n"
}

_install_taranis_ai() {
    local TARANIS_DIR="$HOME/.local/share/taranis-ai"
    echo -e "${CYAN}Installation de Taranis AI...${RESET}"
    
    if [ -d "$TARANIS_DIR" ]; then
        cd "$TARANIS_DIR" && git pull
    else
        git clone https://github.com/taranis-ai/taranis-ai.git "$TARANIS_DIR"
    fi
    
    cd "$TARANIS_DIR" || return 1
    if [ -f "requirements.txt" ]; then
        pip3 install -r requirements.txt --user
    fi
    echo -e "${GREEN}✓ Taranis AI installé${RESET}\n"
}

_install_spiderfoot() {
    local SPIDERFOOT_DIR="$HOME/.local/share/spiderfoot"
    echo -e "${CYAN}Installation de SpiderFoot...${RESET}"
    
    if [ -d "$SPIDERFOOT_DIR" ]; then
        cd "$SPIDERFOOT_DIR" && git pull
    else
        git clone https://github.com/smicallef/spiderfoot.git "$SPIDERFOOT_DIR"
    fi
    
    cd "$SPIDERFOOT_DIR" || return 1
    if [ -f "requirements.txt" ]; then
        pip3 install -r requirements.txt --user
    fi
    echo -e "${GREEN}✓ SpiderFoot installé${RESET}\n"
}

