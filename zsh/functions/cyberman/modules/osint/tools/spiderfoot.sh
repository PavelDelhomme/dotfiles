#!/bin/zsh
# =============================================================================
# SPIDERFOOT - Collecte OSINT automatisée
# =============================================================================
# Description: Outil OSINT avec 200+ modules de collecte
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Utilise SpiderFoot pour la collecte OSINT
# USAGE: spiderfoot_osint [target]
# EXAMPLE: spiderfoot_osint example.com
function spiderfoot_osint() {
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
    local SPIDERFOOT_DIR="$HOME/.local/share/spiderfoot"
    
    # Vérifier/installer SpiderFoot via ensure_tool
    if ! command -v spiderfoot &>/dev/null && [ ! -d "$SPIDERFOOT_DIR" ]; then
        if ! ensure_tool spiderfoot 2>/dev/null; then
            echo -e "${RED}❌ Échec installation SpiderFoot${RESET}"
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
                    echo "🎯 SpiderFoot: $domain"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    _run_spiderfoot "$domain"
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
    echo "🎯 SpiderFoot: $domain"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    _run_spiderfoot "$domain"
}

_run_spiderfoot() {
    local target="$1"
    local SPIDERFOOT_DIR="$HOME/.local/share/spiderfoot"
    
    echo -e "${CYAN}SpiderFoot dispose d'une interface web${RESET}"
    echo -e "${YELLOW}Démarrage du serveur SpiderFoot...${RESET}\n"
    
    if command -v spiderfoot &>/dev/null; then
        echo -e "${GREEN}SpiderFoot sera accessible sur: http://127.0.0.1:5001${RESET}"
        echo -e "${CYAN}Appuyez sur Ctrl+C pour arrêter le serveur${RESET}\n"
        spiderfoot &
        local pid=$!
        sleep 3
        if command -v xdg-open &>/dev/null; then
            xdg-open http://127.0.0.1:5001 &
        elif command -v firefox &>/dev/null; then
            firefox http://127.0.0.1:5001 &
        fi
        wait $pid
    elif [ -d "$SPIDERFOOT_DIR" ]; then
        cd "$SPIDERFOOT_DIR" || return 1
        if [ -f "sf.py" ]; then
            echo -e "${GREEN}SpiderFoot sera accessible sur: http://127.0.0.1:5001${RESET}"
            echo -e "${CYAN}Appuyez sur Ctrl+C pour arrêter le serveur${RESET}\n"
            python3 sf.py &
            local pid=$!
            sleep 3
            if command -v xdg-open &>/dev/null; then
                xdg-open http://127.0.0.1:5001 &
            elif command -v firefox &>/dev/null; then
                firefox http://127.0.0.1:5001 &
            fi
            wait $pid
        fi
    fi
}

