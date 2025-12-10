#!/bin/zsh
# =============================================================================
# THEHARVESTER - Collecte d'emails et sous-domaines
# =============================================================================
# Description: Collecte d'informations (emails, sous-domaines, IPs)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Utilise TheHarvester pour la collecte OSINT
# USAGE: theharvester_osint [domain]
# EXAMPLE: theharvester_osint example.com
function theharvester_osint() {
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
    local RESET='\033[0m'
    
    local target="$1"
    local HARVESTER_DIR="$HOME/.local/share/theHarvester"
    
    # Vérifier/installer TheHarvester via ensure_tool
    if ! command -v theHarvester &>/dev/null && [ ! -d "$HARVESTER_DIR" ]; then
        if ! ensure_tool theharvester 2>/dev/null; then
            echo -e "${RED}❌ Échec installation TheHarvester${RESET}"
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
                    echo "🎯 TheHarvester: $domain"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    _run_theharvester "$domain"
                done
                return 0
            else
                target=$(prompt_target "🎯 Entrez le domaine: ")
            fi
        else
            target=$(prompt_target "🎯 Entrez le domaine: ")
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
    echo "🎯 TheHarvester: $domain"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    _run_theharvester "$domain"
}

_run_theharvester() {
    local domain="$1"
    local HARVESTER_DIR="$HOME/.local/share/theHarvester"
    
    if command -v theHarvester &>/dev/null; then
        echo -e "${CYAN}Collecte d'informations en cours...${RESET}\n"
        theHarvester -d "$domain" -b all -l 500 2>&1 | head -200
        
        # Sauvegarder
        if typeset -f auto_save_recon_result >/dev/null 2>&1; then
            local output=$(theHarvester -d "$domain" -b all -l 500 2>&1)
            auto_save_recon_result "theharvester" "TheHarvester pour $domain" "$output" "success" 2>/dev/null
            echo -e "${GREEN}✓ Résultats sauvegardés${RESET}"
        fi
    elif [ -d "$HARVESTER_DIR" ]; then
        cd "$HARVESTER_DIR" || return 1
        if [ -f "theHarvester.py" ]; then
            echo -e "${CYAN}Collecte d'informations en cours...${RESET}\n"
            python3 theHarvester.py -d "$domain" -b all -l 500 2>&1 | head -200
            
            # Sauvegarder
            if typeset -f auto_save_recon_result >/dev/null 2>&1; then
                local output=$(python3 theHarvester.py -d "$domain" -b all -l 500 2>&1)
                auto_save_recon_result "theharvester" "TheHarvester pour $domain" "$output" "success" 2>/dev/null
                echo -e "${GREEN}✓ Résultats sauvegardés${RESET}"
            fi
        fi
    fi
    echo ""
}

