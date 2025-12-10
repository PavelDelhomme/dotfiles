#!/bin/zsh
# =============================================================================
# NETWORK SCANNER INTEGRATED - Scanner réseau intégré dans cyberman
# =============================================================================
# Description: Scanner réseau complet avec sauvegarde dans sessions cyberman
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Scanner réseau complet avec sauvegarde dans cyberman
# USAGE: network_scan_cyberman [--live] [--save] [--interface] [--range]
# EXAMPLE: network_scan_cyberman
# EXAMPLE: network_scan_cyberman --live --save
function network_scan_cyberman() {
    local CYBER_DIR="${CYBER_DIR:-$HOME/dotfiles/zsh/functions/cyberman/modules/legacy}"
    
    # Charger les helpers
    if [ -f "$CYBER_DIR/helpers/auto_save_helper.sh" ]; then
        source "$CYBER_DIR/helpers/auto_save_helper.sh"
    fi
    if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
        source "$CYBER_DIR/environment_manager.sh"
    fi
    
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    local live_mode=false
    local save_results=true
    local interface=""
    local network_range=""
    
    # Parser les arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --live|-l)
                live_mode=true
                shift
                ;;
            --save|-s)
                save_results=true
                shift
                ;;
            --interface|-i)
                interface="$2"
                shift 2
                ;;
            --range|-r)
                network_range="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Charger network_scanner
    if [ -f "$HOME/dotfiles/zsh/functions/commands/network_scanner.zsh" ]; then
        source "$HOME/dotfiles/zsh/functions/commands/network_scanner.zsh"
    else
        echo -e "${RED}❌ network_scanner non disponible${RESET}"
        return 1
    fi
    
    # Fonction pour sauvegarder les résultats
    save_scan_results() {
        local scan_output="$1"
        local scan_type="$2"
        
        if [ "$save_results" = true ] && has_active_environment 2>/dev/null; then
            local env_name=$(get_current_environment)
            if [ -n "$env_name" ]; then
                # Sauvegarder dans l'environnement actif
                if typeset -f auto_save_recon_result >/dev/null 2>&1; then
                    auto_save_recon_result "$scan_type" "Network scan - $(date '+%Y-%m-%d %H:%M:%S')" "$scan_output" "success" 2>/dev/null
                    echo -e "${GREEN}✓ Scan sauvegardé dans l'environnement: $env_name${RESET}"
                fi
            fi
        fi
    }
    
    # Exécuter le scan
    if [ "$live_mode" = true ]; then
        echo -e "${CYAN}${BOLD}🔄 Mode live activé - Scan continu${RESET}\n"
        network_scanner --continuous --interface "$interface" --range "$network_range" | while IFS= read -r line; do
            echo "$line"
            # Sauvegarder périodiquement (toutes les 5 minutes)
            if [ -n "$line" ] && [[ "$line" =~ "Appareils actifs détectés" ]]; then
                save_scan_results "$line" "network_scan_live"
            fi
        done
    else
        local scan_output=$(network_scanner --interface "$interface" --range "$network_range" 2>&1)
        echo "$scan_output"
        save_scan_results "$scan_output" "network_scan"
    fi
}

