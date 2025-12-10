#!/bin/zsh
# =============================================================================
# OSINT AI - Outil OSINT basé sur LLM
# =============================================================================
# Description: Outil OSINT utilisant des LLM pour l'analyse
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Utilise OSINT AI pour l'analyse OSINT
# USAGE: osint_ai_osint [target]
# EXAMPLE: osint_ai_osint example.com
function osint_ai_osint() {
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
    local OSINT_AI_DIR="$HOME/.local/share/osint-ai"
    
    # Vérifier/installer OSINT AI
    if [ ! -d "$OSINT_AI_DIR" ]; then
        echo -e "${YELLOW}OSINT AI n'est pas installé${RESET}"
        printf "Installer OSINT AI maintenant? (O/n): "
        read -r install_choice
        install_choice=${install_choice:-O}
        
        if [[ "$install_choice" =~ ^[oO]$ ]]; then
            if command -v git &>/dev/null && command -v python3 &>/dev/null; then
                mkdir -p "$HOME/.local/share"
                # Essayer plusieurs repos possibles
                git clone https://github.com/sshh12/llm_osint.git "$OSINT_AI_DIR" 2>/dev/null || \
                git clone https://github.com/ubikron/Awesome-AI-OSINT.git "$OSINT_AI_DIR" 2>/dev/null || \
                git clone https://github.com/mouna23/OSINT-with-LLM.git "$OSINT_AI_DIR" 2>/dev/null
                
                if [ -d "$OSINT_AI_DIR" ]; then
                    cd "$OSINT_AI_DIR" || return 1
                    if [ -f "requirements.txt" ]; then
                        pip3 install -r requirements.txt --user
                    fi
                    echo -e "${GREEN}✓ OSINT AI installé${RESET}"
                else
                    echo -e "${RED}❌ Échec installation OSINT AI${RESET}"
                    return 1
                fi
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
                    echo "🎯 OSINT AI: $domain"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    _run_osint_ai "$domain"
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
    echo "🎯 OSINT AI: $domain"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    _run_osint_ai "$domain"
}

_run_osint_ai() {
    local target="$1"
    local OSINT_AI_DIR="$HOME/.local/share/osint-ai"
    
    if [ -d "$OSINT_AI_DIR" ]; then
        cd "$OSINT_AI_DIR" || return 1
        if [ -f "osint_ai.py" ]; then
            echo -e "${CYAN}Analyse OSINT avec IA...${RESET}\n"
            python3 osint_ai.py "$target" 2>&1 | head -200
            
            # Sauvegarder
            if typeset -f auto_save_recon_result >/dev/null 2>&1; then
                local output=$(python3 osint_ai.py "$target" 2>&1)
                auto_save_recon_result "osint_ai" "OSINT AI pour $target" "$output" "success" 2>/dev/null
                echo -e "${GREEN}✓ Résultats sauvegardés${RESET}"
            fi
        elif [ -f "main.py" ]; then
            python3 main.py "$target" 2>&1 | head -200
        elif [ -f "llm_osint.py" ]; then
            python3 llm_osint.py "$target" 2>&1 | head -200
        else
            echo -e "${YELLOW}Script Python non trouvé${RESET}"
            echo -e "${CYAN}Consultez la documentation du repo${RESET}"
        fi
    fi
    echo ""
}

