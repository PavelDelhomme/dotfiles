#!/bin/zsh
# =============================================================================
# SHERLOCK - Recherche username sur réseaux sociaux
# =============================================================================
# Description: Recherche d'empreintes numériques via usernames
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Utilise Sherlock pour rechercher un username
# USAGE: sherlock_osint [username]
# EXAMPLE: sherlock_osint johndoe
function sherlock_osint() {
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
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    local username="$1"
    local SHERLOCK_DIR="$HOME/.local/share/sherlock"
    
    # Vérifier/installer Sherlock via ensure_tool
    if ! command -v sherlock &>/dev/null && [ ! -d "$SHERLOCK_DIR" ]; then
        if ! ensure_tool sherlock 2>/dev/null; then
            echo -e "${RED}❌ Échec installation Sherlock${RESET}"
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
    echo "🎯 Sherlock: $username"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Exécuter Sherlock
    if command -v sherlock &>/dev/null; then
        echo -e "${CYAN}Recherche en cours sur 300+ plateformes...${RESET}\n"
        sherlock "$username" --no-color 2>&1 | head -200
        
        # Sauvegarder
        if typeset -f auto_save_recon_result >/dev/null 2>&1; then
            local output=$(sherlock "$username" --no-color 2>&1)
            auto_save_recon_result "sherlock" "Sherlock search pour $username" "$output" "success" 2>/dev/null
            echo -e "${GREEN}✓ Résultats sauvegardés${RESET}"
        fi
    elif [ -d "$SHERLOCK_DIR" ]; then
        cd "$SHERLOCK_DIR" || return 1
        if [ -f "sherlock.py" ]; then
            echo -e "${CYAN}Recherche en cours sur 300+ plateformes...${RESET}\n"
            python3 sherlock.py "$username" --no-color 2>&1 | head -200
            
            # Sauvegarder
            if typeset -f auto_save_recon_result >/dev/null 2>&1; then
                local output=$(python3 sherlock.py "$username" --no-color 2>&1)
                auto_save_recon_result "sherlock" "Sherlock search pour $username" "$output" "success" 2>/dev/null
                echo -e "${GREEN}✓ Résultats sauvegardés${RESET}"
            fi
        fi
    fi
    
    echo ""
}

