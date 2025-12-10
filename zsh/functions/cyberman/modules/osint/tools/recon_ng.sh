#!/bin/zsh
# =============================================================================
# RECON-NG - Framework de reconnaissance web
# =============================================================================
# Description: Framework modulaire pour reconnaissance OSINT
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Utilise Recon-ng pour la reconnaissance
# USAGE: recon_ng_osint [domain]
# EXAMPLE: recon_ng_osint example.com
function recon_ng_osint() {
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
    local RECON_DIR="$HOME/.local/share/recon-ng"
    
    # Vérifier/installer Recon-ng
    if ! command -v recon-ng &>/dev/null && [ ! -d "$RECON_DIR" ]; then
        echo -e "${YELLOW}Recon-ng n'est pas installé${RESET}"
        printf "Installer Recon-ng maintenant? (O/n): "
        read -r install_choice
        install_choice=${install_choice:-O}
        
        if [[ "$install_choice" =~ ^[oO]$ ]]; then
            if command -v git &>/dev/null && command -v python3 &>/dev/null; then
                mkdir -p "$HOME/.local/share"
                git clone https://github.com/lanmaster53/recon-ng.git "$RECON_DIR"
                cd "$RECON_DIR" || return 1
                if [ -f "requirements.txt" ]; then
                    pip3 install -r requirements.txt --user
                fi
                echo -e "${GREEN}✓ Recon-ng installé${RESET}"
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
                    echo "🎯 Recon-ng: $domain"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    _run_recon_ng "$domain"
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
    echo "🎯 Recon-ng: $domain"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    _run_recon_ng "$domain"
}

_run_recon_ng() {
    local domain="$1"
    local RECON_DIR="$HOME/.local/share/recon-ng"
    
    echo -e "${CYAN}Recon-ng est un framework interactif${RESET}"
    echo -e "${YELLOW}Lancement de Recon-ng...${RESET}\n"
    echo -e "${CYAN}Commandes utiles:${RESET}"
    echo "  [recon-ng][default] > workspaces create $domain"
    echo "  [recon-ng][default] > workspaces select $domain"
    echo "  [recon-ng][$domain] > modules load recon/domains-hosts/hackertarget"
    echo "  [recon-ng][$domain] > options set SOURCE $domain"
    echo "  [recon-ng][$domain] > run"
    echo "  [recon-ng][$domain] > show hosts"
    echo ""
    printf "Lancer Recon-ng interactif? (O/n): "
    read -r launch
    launch=${launch:-O}
    
    if [[ "$launch" =~ ^[oO]$ ]]; then
        if command -v recon-ng &>/dev/null; then
            recon-ng
        elif [ -d "$RECON_DIR" ]; then
            cd "$RECON_DIR" || return 1
            if [ -f "recon-ng" ]; then
                ./recon-ng
            elif [ -f "recon.py" ]; then
                python3 recon.py
            fi
        fi
    fi
}

