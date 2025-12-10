#!/bin/zsh
# =============================================================================
# CONFIG API KEYS - Configuration des clés API pour outils OSINT
# =============================================================================
# Description: Configuration des clés API pour outils OSINT
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Configure les clés API pour outils OSINT
# USAGE: config_osint_api_keys
# EXAMPLE: config_osint_api_keys
function config_osint_api_keys() {
    local CYAN='\033[0;36m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local RESET='\033[0m'
    
    local CONFIG_DIR="$HOME/.cyberman/config"
    local CONFIG_FILE="$CONFIG_DIR/osint.conf"
    
    mkdir -p "$CONFIG_DIR"
    
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║          CONFIGURATION CLÉS API OSINT                         ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${RESET}\n"
    
    echo "Configuration des clés API (optionnelles):"
    echo ""
    
    # Charger la config existante
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
    
    printf "OpenAI API Key (pour DarkGPT, Robin): "
    read -r openai_key
    if [ -n "$openai_key" ]; then
        echo "export OPENAI_API_KEY=\"$openai_key\"" >> "$CONFIG_FILE"
    fi
    
    printf "DeHashed API Key (pour DarkGPT): "
    read -r dehashed_key
    if [ -n "$dehashed_key" ]; then
        echo "export DEHASHED_API_KEY=\"$dehashed_key\"" >> "$CONFIG_FILE"
    fi
    
    printf "Shodan API Key (pour SpiderFoot): "
    read -r shodan_key
    if [ -n "$shodan_key" ]; then
        echo "export SHODAN_API_KEY=\"$shodan_key\"" >> "$CONFIG_FILE"
    fi
    
    printf "VirusTotal API Key (pour SpiderFoot): "
    read -r virustotal_key
    if [ -n "$virustotal_key" ]; then
        echo "export VT_API_KEY=\"$virustotal_key\"" >> "$CONFIG_FILE"
    fi
    
    echo ""
    echo -e "${GREEN}✓ Configuration sauvegardée dans $CONFIG_FILE${RESET}"
    echo -e "${YELLOW}💡 Rechargez votre shell ou sourcez le fichier pour activer${RESET}"
}

