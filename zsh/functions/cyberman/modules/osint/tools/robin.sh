#!/bin/zsh
# =============================================================================
# ROBIN - Investigation dark web avec IA
# =============================================================================
# Description: Outil OSINT pour investigations dark web avec LLM
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Utilise Robin pour l'investigation dark web
# USAGE: robin_osint [query]
# EXAMPLE: robin_osint "bitcoin wallet"
function robin_osint() {
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
    local ROBIN_DIR="$HOME/.local/share/robin"
    
    # Vérifier/installer Robin via ensure_tool
    if ! command -v robin &>/dev/null && [ ! -d "$ROBIN_DIR" ]; then
        if ! ensure_tool robin 2>/dev/null; then
            echo -e "${RED}❌ Échec installation Robin${RESET}"
            return 1
        fi
        echo -e "${YELLOW}⚠️  Configuration requise:${RESET}"
        echo -e "${CYAN}   - OpenAI API key (pour GPT-4.1)${RESET}"
    fi
    
    # Obtenir la requête
    if [ -z "$query" ]; then
        printf "🎯 Entrez la requête de recherche dark web: "
        read -r query
    fi
    
    if [ -z "$query" ]; then
        echo -e "${RED}❌ Requête requise${RESET}"
        return 1
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎯 Robin: $query"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Exécuter Robin
    if command -v robin &>/dev/null; then
        echo -e "${CYAN}Recherche dark web en cours...${RESET}\n"
        robin "$query" 2>&1 | head -200
        
        # Sauvegarder
        if typeset -f auto_save_recon_result >/dev/null 2>&1; then
            local output=$(robin "$query" 2>&1)
            auto_save_recon_result "robin" "Robin dark web pour $query" "$output" "success" 2>/dev/null
            echo -e "${GREEN}✓ Résultats sauvegardés${RESET}"
        fi
    elif [ -d "$ROBIN_DIR" ]; then
        cd "$ROBIN_DIR" || return 1
        if [ -f "robin.py" ]; then
            echo -e "${CYAN}Recherche dark web en cours...${RESET}\n"
            python3 robin.py "$query" 2>&1 | head -200
            
            # Sauvegarder
            if typeset -f auto_save_recon_result >/dev/null 2>&1; then
                local output=$(python3 robin.py "$query" 2>&1)
                auto_save_recon_result "robin" "Robin dark web pour $query" "$output" "success" 2>/dev/null
                echo -e "${GREEN}✓ Résultats sauvegardés${RESET}"
            fi
        elif [ -f "main.py" ]; then
            python3 main.py "$query" 2>&1 | head -200
        fi
    fi
    echo ""
}

