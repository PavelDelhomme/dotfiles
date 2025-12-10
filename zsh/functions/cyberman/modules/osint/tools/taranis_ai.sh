#!/bin/zsh
# =============================================================================
# TARANIS AI - OSINT avancé avec NLP et IA
# =============================================================================
# Description: Outil OSINT avancé avec reconnaissance d'entités et analyse IA
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Utilise Taranis AI pour l'OSINT
# USAGE: taranis_ai_osint [target]
# EXAMPLE: taranis_ai_osint example.com
function taranis_ai_osint() {
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
    
    local target="$1"
    local TARANIS_DIR="$HOME/.local/share/taranis-ai"
    
    # Vérifier/installer Taranis AI via ensure_tool
    if [ ! -d "$TARANIS_DIR" ] && ! command -v taranis-ai &>/dev/null; then
        if ! ensure_tool taranis-ai 2>/dev/null; then
            echo -e "${RED}❌ Échec installation Taranis AI${RESET}"
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
                    echo "🎯 Taranis AI: $domain"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    _run_taranis_ai "$domain"
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
    echo "🎯 Taranis AI: $domain"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    _run_taranis_ai "$domain"
}

_run_taranis_ai() {
    local target="$1"
    local TARANIS_DIR="$HOME/.local/share/taranis-ai"
    
    if [ -d "$TARANIS_DIR" ]; then
        cd "$TARANIS_DIR" || return 1
        if [ -f "taranis.py" ] || [ -f "main.py" ]; then
            local script_file=$(find . -maxdepth 1 -name "*.py" -type f | head -1)
            if [ -n "$script_file" ]; then
                echo -e "${CYAN}Exécution de Taranis AI sur $target...${RESET}\n"
                python3 "$script_file" "$target" 2>&1 | head -100
                
                # Sauvegarder les résultats
                if typeset -f auto_save_recon_result >/dev/null 2>&1; then
                    local output=$(python3 "$script_file" "$target" 2>&1)
                    auto_save_recon_result "taranis_ai" "Taranis AI OSINT pour $target" "$output" "success" 2>/dev/null
                    echo -e "${GREEN}✓ Résultats sauvegardés${RESET}"
                fi
            else
                echo -e "${YELLOW}Script Python non trouvé dans Taranis AI${RESET}"
                echo -e "${CYAN}Consultez la documentation: https://github.com/taranis-ai/taranis-ai${RESET}"
            fi
        else
            echo -e "${YELLOW}Taranis AI installé mais script non trouvé${RESET}"
        fi
    elif command -v taranis-ai &>/dev/null; then
        echo -e "${CYAN}Exécution de Taranis AI sur $target...${RESET}\n"
        taranis-ai "$target" 2>&1 | head -100
        
        # Sauvegarder les résultats
        if typeset -f auto_save_recon_result >/dev/null 2>&1; then
            local output=$(taranis-ai "$target" 2>&1)
            auto_save_recon_result "taranis_ai" "Taranis AI OSINT pour $target" "$output" "success" 2>/dev/null
            echo -e "${GREEN}✓ Résultats sauvegardés${RESET}"
        fi
    fi
}

