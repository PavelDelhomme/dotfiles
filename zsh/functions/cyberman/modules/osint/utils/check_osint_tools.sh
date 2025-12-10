#!/bin/zsh
# =============================================================================
# CHECK OSINT TOOLS - Vérification des outils OSINT installés
# =============================================================================
# Description: Vérifie quels outils OSINT sont installés
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Vérifie les outils OSINT installés
# USAGE: check_osint_tools_installed
# EXAMPLE: check_osint_tools_installed
function check_osint_tools_installed() {
    local GREEN='\033[0;32m'
    local RED='\033[0;31m'
    local YELLOW='\033[1;33m'
    local CYAN='\033[0;36m'
    local RESET='\033[0m'
    
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║          VÉRIFICATION OUTILS OSINT                            ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${RESET}\n"
    
    local tools_installed=0
    local tools_missing=0
    
    # Vérifier chaque outil
    _check_tool "Sherlock" "sherlock" "$HOME/.local/share/sherlock"
    _check_tool "TheHarvester" "theHarvester" "$HOME/.local/share/theHarvester"
    _check_tool "Recon-ng" "recon-ng" "$HOME/.local/share/recon-ng"
    _check_tool "Taranis AI" "taranis-ai" "$HOME/.local/share/taranis-ai"
    _check_tool "SpiderFoot" "spiderfoot" "$HOME/.local/share/spiderfoot"
    _check_tool "GoSearch" "gosearch" "$HOME/.local/share/gosearch"
    _check_tool "DarkGPT" "darkgpt" "$HOME/.local/share/darkgpt"
    _check_tool "Robin" "robin" "$HOME/.local/share/robin"
    _check_tool "OSINT LLM" "osint-llm" "$HOME/.local/share/osint-llm"
    _check_tool "Ollama" "ollama" ""
    
    echo ""
    echo -e "${CYAN}Résumé:${RESET}"
    echo -e "  ${GREEN}Installés: $tools_installed${RESET}"
    echo -e "  ${RED}Manquants: $tools_missing${RESET}"
    echo ""
}

_check_tool() {
    local tool_name="$1"
    local command_name="$2"
    local install_dir="$3"
    
    if command -v "$command_name" &>/dev/null || [ -d "$install_dir" ]; then
        echo -e "${GREEN}✓${RESET} $tool_name: ${GREEN}Installé${RESET}"
        ((tools_installed++))
    else
        echo -e "${RED}✗${RESET} $tool_name: ${RED}Non installé${RESET}"
        ((tools_missing++))
    fi
}

