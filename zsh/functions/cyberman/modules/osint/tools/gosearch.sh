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
    
    # Vérifier Go
    if ! command -v go &>/dev/null; then
        echo -e "${YELLOW}Go n'est pas installé${RESET}"
        printf "Installer Go maintenant? (O/n): "
        read -r install_go
        install_go=${install_go:-O}
        
        if [[ "$install_go" =~ ^[oO]$ ]]; then
            ensure_tool go
        else
            return 1
        fi
    fi
    
    # Vérifier/installer GoSearch
    if ! command -v gosearch &>/dev/null && [ ! -d "$GOSEARCH_DIR" ]; then
        echo -e "${YELLOW}GoSearch n'est pas installé${RESET}"
        printf "Installer GoSearch maintenant? (O/n): "
        read -r install_choice
        install_choice=${install_choice:-O}
        
        if [[ "$install_choice" =~ ^[oO]$ ]]; then
            if command -v git &>/dev/null && command -v go &>/dev/null; then
                mkdir -p "$HOME/.local/share"
                git clone https://github.com/GoSearch-OSINT/GoSearch.git "$GOSEARCH_DIR" 2>/dev/null || \
                git clone https://github.com/apurvsinghgautam/gosearch.git "$GOSEARCH_DIR" 2>/dev/null
                cd "$GOSEARCH_DIR" || return 1
                go build -o gosearch . 2>/dev/null || go install . 2>/dev/null
                if [ -f "gosearch" ]; then
                    cp gosearch "$HOME/.local/bin/" 2>/dev/null || true
                fi
                echo -e "${GREEN}✓ GoSearch installé${RESET}"
            else
                echo -e "${RED}❌ git ou go non disponible${RESET}"
                return 1
            fi
        else
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

