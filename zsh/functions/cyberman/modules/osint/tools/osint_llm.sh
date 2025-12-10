#!/bin/zsh
# =============================================================================
# OSINT WITH LLM - Reconnaissance avec LLM locaux
# =============================================================================
# Description: OSINT automatisé avec LLM locaux via Ollama
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Utilise OSINT with LLM pour la reconnaissance automatisée
# USAGE: osint_llm [target] [type]
# EXAMPLE: osint_llm example.com domain
function osint_llm() {
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
    
    local target="$1"
    local target_type="${2:-auto}"
    local OSINT_LLM_DIR="$HOME/.local/share/osint-llm"
    
    # Vérifier Ollama
    if ! command -v ollama &>/dev/null; then
        echo -e "${YELLOW}Ollama n'est pas installé${RESET}"
        echo -e "${CYAN}Ollama est requis pour OSINT with LLM${RESET}"
        printf "Installer Ollama maintenant? (O/n): "
        read -r install_ollama
        install_ollama=${install_ollama:-O}
        
        if [[ "$install_ollama" =~ ^[oO]$ ]]; then
            echo -e "${CYAN}Installation d'Ollama...${RESET}"
            curl -fsSL https://ollama.com/install.sh | sh
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ Ollama installé${RESET}"
            else
                echo -e "${RED}❌ Échec installation Ollama${RESET}"
                return 1
            fi
        else
            return 1
        fi
    fi
    
    # Vérifier/installer OSINT with LLM
    if [ ! -d "$OSINT_LLM_DIR" ]; then
        echo -e "${YELLOW}OSINT with LLM n'est pas installé${RESET}"
        printf "Installer OSINT with LLM maintenant? (O/n): "
        read -r install_choice
        install_choice=${install_choice:-O}
        
        if [[ "$install_choice" =~ ^[oO]$ ]]; then
            if command -v git &>/dev/null && command -v python3 &>/dev/null; then
                mkdir -p "$HOME/.local/share"
                git clone https://github.com/mouna23/OSINT-with-LLM.git "$OSINT_LLM_DIR" 2>/dev/null
                cd "$OSINT_LLM_DIR" || return 1
                if [ -f "requirements.txt" ]; then
                    pip3 install -r requirements.txt --user
                fi
                echo -e "${GREEN}✓ OSINT with LLM installé${RESET}"
            else
                echo -e "${RED}❌ git ou python3 non disponible${RESET}"
                return 1
            fi
        else
            return 1
        fi
    fi
    
    # Obtenir la cible
    if [ -z "$target" ]; then
        if has_targets; then
            echo "🎯 Utilisation des cibles configurées:"
            show_targets
            echo ""
            printf "Utiliser toutes les cibles? (O/n): "
            read -r use_all
            if [ "$use_all" != "n" ] && [ "$use_all" != "N" ]; then
                for t in "${CYBER_TARGETS[@]}"; do
                    local domain="$t"
                    if [[ "$t" =~ ^https?:// ]]; then
                        domain=$(echo "$t" | sed -E 's|^https?://||' | sed 's|/.*||')
                    fi
                    echo ""
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo "🎯 OSINT LLM: $domain"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    _run_osint_llm "$domain" "$target_type"
                done
                return 0
            else
                target=$(prompt_target "🎯 Entrez la cible: ")
            fi
        else
            target=$(prompt_target "🎯 Entrez la cible: ")
        fi
    fi
    
    if [ -z "$target" ]; then
        return 1
    fi
    
    local domain="$target"
    if [[ "$target" =~ ^https?:// ]]; then
        domain=$(echo "$target" | sed -E 's|^https?://||' | sed 's|/.*||')
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎯 OSINT LLM: $domain"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    _run_osint_llm "$domain" "$target_type"
}

_run_osint_llm() {
    local target="$1"
    local target_type="$2"
    local OSINT_LLM_DIR="$HOME/.local/share/osint-llm"
    
    if [ -d "$OSINT_LLM_DIR" ]; then
        cd "$OSINT_LLM_DIR" || return 1
        if [ -f "osint_llm.py" ]; then
            echo -e "${CYAN}Reconnaissance automatisée avec LLM local...${RESET}\n"
            python3 osint_llm.py "$target" "$target_type" 2>&1 | head -200
            
            # Sauvegarder
            if typeset -f auto_save_recon_result >/dev/null 2>&1; then
                local output=$(python3 osint_llm.py "$target" "$target_type" 2>&1)
                auto_save_recon_result "osint_llm" "OSINT LLM pour $target" "$output" "success" 2>/dev/null
                echo -e "${GREEN}✓ Résultats sauvegardés${RESET}"
            fi
        elif [ -f "main.py" ]; then
            python3 main.py "$target" "$target_type" 2>&1 | head -200
        else
            echo -e "${YELLOW}Script Python non trouvé${RESET}"
            echo -e "${CYAN}Consultez: https://github.com/mouna23/OSINT-with-LLM${RESET}"
        fi
    fi
    echo ""
}

