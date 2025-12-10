#!/bin/zsh
# =============================================================================
# GOSEARCH - Recherche d'empreintes numériques (Go)
# =============================================================================
# Description: Recherche d'empreintes numériques liées à des usernames (Go)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Utilise GoSearch pour la recherche d'empreintes
# USAGE: gosearch_osint [username]
# EXAMPLE: gosearch_osint johndoe
function gosearch_osint() {
    local CYBER_DIR="${CYBER_DIR:-$HOME/dotfiles/zsh/functions/cyberman/modules/legacy}"
    local UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
    
    # Charger ensure_tool
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        source "$UTILS_DIR/ensure_tool.sh" 2>/dev/null
    fi
    
    # Charger le gestionnaire de cibles
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    if [ -f "$CYBER_DIR/helpers/auto_save_helper.sh" ]; then
        source "$CYBER_DIR/helpers/auto_save_helper.sh"
    fi
    
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local CYAN='\033[0;36m'
    local RESET='\033[0m'
    
    local username="$1"
    local GOSEARCH_DIR="$HOME/.local/share/gosearch"
    
    # Vérifier/installer Go et GoSearch via ensure_tool
    if ! command -v go &>/dev/null; then
        if ! ensure_tool go 2>/dev/null; then
            echo -e "${RED}❌ Go est requis pour GoSearch${RESET}"
            return 1
        fi
    fi
    
    if ! command -v gosearch &>/dev/null && [ ! -d "$GOSEARCH_DIR" ]; then
        if ! ensure_tool gosearch 2>/dev/null; then
            echo -e "${RED}❌ Échec installation GoSearch${RESET}"
            return 1
        fi
    fi
    
    # Obtenir le username
    if [ -z "$username" ]; then
        printf "🎯 Entrez le username à rechercher: "
        read -r username
    fi
    
    if [ -z "$username" ]; then
        echo -e "${RED}❌ Username requis${RESET}"
        return 1
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎯 GoSearch: $username"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Exécuter GoSearch
    if command -v gosearch &>/dev/null; then
        echo -e "${CYAN}Recherche en cours...${RESET}\n"
        gosearch "$username" 2>&1 | head -200
        
        # Sauvegarder
        if typeset -f auto_save_recon_result >/dev/null 2>&1; then
            local output=$(gosearch "$username" 2>&1)
            auto_save_recon_result "gosearch" "GoSearch pour $username" "$output" "success" 2>/dev/null
            echo -e "${GREEN}✓ Résultats sauvegardés${RESET}"
        fi
    elif [ -d "$GOSEARCH_DIR" ]; then
        cd "$GOSEARCH_DIR" || return 1
        if [ -f "gosearch" ]; then
            echo -e "${CYAN}Recherche en cours...${RESET}\n"
            ./gosearch "$username" 2>&1 | head -200
            
            # Sauvegarder
            if typeset -f auto_save_recon_result >/dev/null 2>&1; then
                local output=$(./gosearch "$username" 2>&1)
                auto_save_recon_result "gosearch" "GoSearch pour $username" "$output" "success" 2>/dev/null
                echo -e "${GREEN}✓ Résultats sauvegardés${RESET}"
            fi
        fi
    fi
    echo ""
}

