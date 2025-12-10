#!/bin/zsh
# =============================================================================
# OSINT MANAGER - Gestionnaire d'outils OSINT avec IA
# =============================================================================
# Description: Gestionnaire complet des outils OSINT avec intelligence artificielle
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Menu principal des outils OSINT
# USAGE: show_osint_menu
# EXAMPLE: show_osint_menu
show_osint_menu() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    local CYBER_DIR="${CYBER_DIR:-$HOME/dotfiles/zsh/functions/cyberman/modules/legacy}"
    local OSINT_DIR="$HOME/dotfiles/zsh/functions/cyberman/modules/osint"
    
    # Charger ensure_tool
    local UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        source "$UTILS_DIR/ensure_tool.sh" 2>/dev/null
    fi
    
    # Charger le gestionnaire de cibles
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    
    while true; do
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║              OUTILS OSINT AVEC IA - CYBERMAN                   ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}\n"
        
        echo -e "${YELLOW}${BOLD}🔍 OUTILS OSINT AVEC INTELLIGENCE ARTIFICIELLE${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        echo "1.  Taranis AI              (OSINT avancé avec NLP/IA)"
        echo "2.  Robin                   (Investigation dark web avec IA)"
        echo "3.  GoSearch                (Recherche empreintes numériques)"
        echo "4.  DarkGPT                 (Assistant OSINT GPT-4)"
        echo "5.  OSINT with LLM          (Reconnaissance avec LLM locaux)"
        echo ""
        echo -e "${YELLOW}${BOLD}🛠️  OUTILS OSINT TRADITIONNELS${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "6.  SpiderFoot              (Collecte OSINT automatisée)"
        echo "7.  Recon-ng                (Framework reconnaissance web)"
        echo "8.  Sherlock                (Recherche username réseaux sociaux)"
        echo "9.  TheHarvester            (Collecte emails/sous-domaines)"
        echo ""
        echo -e "${YELLOW}${BOLD}⚙️  INSTALLATION & CONFIGURATION${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "10. Installer outils OSINT  (Installation automatique)"
        echo "11. Configurer clés API    (Configuration clés API)"
        echo "12. Vérifier installations (Vérifier outils installés)"
        echo ""
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                source "$OSINT_DIR/tools/taranis_ai.sh" && taranis_ai_osint
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2)
                source "$OSINT_DIR/tools/robin.sh" && robin_osint
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3)
                source "$OSINT_DIR/tools/gosearch.sh" && gosearch_osint
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4)
                source "$OSINT_DIR/tools/darkgpt.sh" && darkgpt_osint
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            5)
                source "$OSINT_DIR/tools/osint_llm.sh" && osint_llm
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            6)
                source "$OSINT_DIR/tools/spiderfoot.sh" && spiderfoot_osint
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            7)
                source "$OSINT_DIR/tools/recon_ng.sh" && recon_ng_osint
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            8)
                source "$OSINT_DIR/tools/sherlock.sh" && sherlock_osint
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            9)
                source "$OSINT_DIR/tools/theharvester.sh" && theharvester_osint
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            10)
                source "$OSINT_DIR/install/install_osint_tools.sh" && install_osint_tools
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            11)
                source "$OSINT_DIR/utils/config_api_keys.sh" && config_osint_api_keys
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            12)
                source "$OSINT_DIR/utils/check_osint_tools.sh" && check_osint_tools_installed
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${RED}Choix invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

