#!/bin/zsh
# =============================================================================
# DARKGPT - Assistant OSINT basé sur GPT-4
# =============================================================================
# Description: Assistant OSINT pour bases de données compromises
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Utilise DarkGPT pour l'OSINT
# USAGE: darkgpt_osint [query]
# EXAMPLE: darkgpt_osint email@example.com
function darkgpt_osint() {
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
    
    local query="$1"
    local DARKGPT_DIR="$HOME/.local/share/darkgpt"
    
    # Vérifier/installer DarkGPT via ensure_tool
    if ! command -v darkgpt &>/dev/null && [ ! -d "$DARKGPT_DIR" ]; then
        if ! ensure_tool darkgpt 2>/dev/null; then
            echo -e "${RED}❌ Échec installation DarkGPT${RESET}"
            return 1
        fi
        echo -e "${YELLOW}⚠️  Configuration requise:${RESET}"
        echo -e "${CYAN}   - OpenAI API key (optionnel)${RESET}"
        echo -e "${CYAN}   - DeHashed API key (optionnel)${RESET}"
    fi
    
    # Obtenir la requête
    if [ -z "$query" ]; then
        printf "🎯 Entrez la requête (email, username, etc.): "
        read -r query
    fi
    
    if [ -z "$query" ]; then
        echo -e "${RED}❌ Requête requise${RESET}"
        return 1
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎯 DarkGPT: $query"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Exécuter DarkGPT
    if command -v darkgpt &>/dev/null; then
        echo -e "${CYAN}Recherche en cours...${RESET}\n"
        darkgpt "$query" 2>&1 | head -200
        
        # Sauvegarder
        if typeset -f auto_save_recon_result >/dev/null 2>&1; then
            local output=$(darkgpt "$query" 2>&1)
            auto_save_recon_result "darkgpt" "DarkGPT pour $query" "$output" "success" 2>/dev/null
            echo -e "${GREEN}✓ Résultats sauvegardés${RESET}"
        fi
    elif [ -d "$DARKGPT_DIR" ]; then
        cd "$DARKGPT_DIR" || return 1
        if [ -f "darkgpt.py" ]; then
            echo -e "${CYAN}Recherche en cours...${RESET}\n"
            python3 darkgpt.py "$query" 2>&1 | head -200
            
            # Sauvegarder
            if typeset -f auto_save_recon_result >/dev/null 2>&1; then
                local output=$(python3 darkgpt.py "$query" 2>&1)
                auto_save_recon_result "darkgpt" "DarkGPT pour $query" "$output" "success" 2>/dev/null
                echo -e "${GREEN}✓ Résultats sauvegardés${RESET}"
            fi
        elif [ -f "main.py" ]; then
            python3 main.py "$query" 2>&1 | head -200
        fi
    fi
    echo ""
}

