#!/bin/zsh
# =============================================================================
# LLM OSINT - OSINT avec modèles de langage
# =============================================================================
# Description: Outil OSINT utilisant LLM pour analyse et collecte
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Utilise LLM OSINT pour l'analyse
# USAGE: llm_osint_tool [target]
# EXAMPLE: llm_osint_tool example.com
function llm_osint_tool() {
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
    local LLM_OSINT_DIR="$HOME/.local/share/llm-osint"
    
    # Vérifier Ollama
    if ! command -v ollama &>/dev/null; then
        echo -e "${YELLOW}Ollama n'est pas installé${RESET}"
        if ! ensure_tool ollama 2>/dev/null; then
            echo -e "${RED}❌ Ollama est requis${RESET}"
            return 1
        fi
    fi
    
    # Vérifier/installer LLM OSINT
    if [ ! -d "$LLM_OSINT_DIR" ]; then
        echo -e "${YELLOW}LLM OSINT n'est pas installé${RESET}"
        printf "Installer LLM OSINT maintenant? (O/n): "
        read -r install_choice
        install_choice=${install_choice:-O}
        
        if [[ "$install_choice" =~ ^[oO]$ ]]; then
            if command -v git &>/dev/null && command -v python3 &>/dev/null; then
                mkdir -p "$HOME/.local/share"
                git clone https://github.com/sshh12/llm_osint.git "$LLM_OSINT_DIR" 2>/dev/null
                if [ -d "$LLM_OSINT_DIR" ]; then
                    cd "$LLM_OSINT_DIR" || return 1
                    if [ -f "requirements.txt" ]; then
                        pip3 install -r requirements.txt --user
                    fi
                    echo -e "${GREEN}✓ LLM OSINT installé${RESET}"
                else
                    echo -e "${RED}❌ Échec installation LLM OSINT${RESET}"
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
                    echo "🎯 LLM OSINT: $domain"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    _run_llm_osint "$domain"
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
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━════════════════════════════════"
    echo "🎯 LLM OSINT: $domain"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    _run_llm_osint "$domain"
}

_run_llm_osint() {
    local target="$1"
    local LLM_OSINT_DIR="$HOME/.local/share/llm-osint"
    
    if [ -d "$LLM_OSINT_DIR" ]; then
        cd "$LLM_OSINT_DIR" || return 1
        if [ -f "llm_osint.py" ]; then
            echo -e "${CYAN}Analyse OSINT avec LLM...${RESET}\n"
            python3 llm_osint.py "$target" 2>&1 | head -200
            
            # Sauvegarder
            if typeset -f auto_save_recon_result >/dev/null 2>&1; then
                local output=$(python3 llm_osint.py "$target" 2>&1)
                auto_save_recon_result "llm_osint" "LLM OSINT pour $target" "$output" "success" 2>/dev/null
                echo -e "${GREEN}✓ Résultats sauvegardés${RESET}"
            fi
        elif [ -f "main.py" ]; then
            python3 main.py "$target" 2>&1 | head -200
        else
            echo -e "${YELLOW}Script Python non trouvé${RESET}"
            echo -e "${CYAN}Consultez: https://github.com/sshh12/llm_osint${RESET}"
        fi
    fi
    echo ""
}

