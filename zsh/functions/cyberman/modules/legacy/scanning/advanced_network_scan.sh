#!/bin/zsh
# =============================================================================
# ADVANCED NETWORK SCAN - Scan réseau avancé avec détails complets
# =============================================================================
# Description: Scan réseau complet avec ports, services, vulnérabilités
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Scan réseau avancé avec détails complets
# USAGE: advanced_network_scan [target] [--full] [--vuln] [--save]
# EXAMPLE: advanced_network_scan 192.168.1.1
# EXAMPLE: advanced_network_scan 192.168.1.0/24 --full --vuln
function advanced_network_scan() {
    local CYBER_DIR="${CYBER_DIR:-$HOME/dotfiles/zsh/functions/cyberman/modules/legacy}"
    
    # Charger les helpers
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
    local full_scan=false
    local vuln_scan=false
    local save_results=true
    
    # Parser les arguments
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --full|-f)
                full_scan=true
                shift
                ;;
            --vuln|-v)
                vuln_scan=true
                shift
                ;;
            --save|-s)
                save_results=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Vérifier nmap
    if ! command -v nmap &>/dev/null; then
        echo -e "${RED}❌ nmap n'est pas installé${RESET}"
        echo -e "${YELLOW}💡 Installez-le: sudo pacman -S nmap${RESET}"
        return 1
    fi
    
    if [ -z "$target" ]; then
        # Utiliser les cibles configurées
        if [ -f "$CYBER_DIR/target_manager.sh" ]; then
            source "$CYBER_DIR/target_manager.sh"
            if has_targets; then
                echo -e "${CYAN}🎯 Cibles configurées:${RESET}"
                show_targets
                echo ""
                printf "Utiliser toutes les cibles? (O/n): "
                read -r use_all
                if [ "$use_all" != "n" ] && [ "$use_all" != "N" ]; then
                    for t in "${CYBER_TARGETS[@]}"; do
                        advanced_network_scan "$t" --full "$@"
                    done
                    return 0
                else
                    printf "🎯 Cible à scanner: "
                    read -r target
                fi
            else
                printf "🎯 Cible à scanner: "
                read -r target
            fi
        else
            printf "🎯 Cible à scanner: "
            read -r target
        fi
    fi
    
    if [ -z "$target" ]; then
        echo -e "${RED}❌ Aucune cible spécifiée${RESET}"
        return 1
    fi
    
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║          SCAN RÉSEAU AVANCÉ - $target                        ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${RESET}\n"
    
    local scan_output=""
    local scan_summary=""
    
    # 1. Scan de découverte d'hôtes
    echo -e "${YELLOW}${BOLD}📡 1. DÉCOUVERTE D'HÔTES${RESET}\n"
    local host_scan=$(nmap -sn "$target" 2>/dev/null)
    echo "$host_scan"
    scan_output+="=== DÉCOUVERTE D'HÔTES ===\n$host_scan\n\n"
    
    # Extraire les IPs trouvées
    local ips=($(echo "$host_scan" | grep -oP '\d+(\.\d+){3}' | sort -u))
    
    if [ ${#ips[@]} -eq 0 ]; then
        echo -e "${RED}❌ Aucun hôte trouvé${RESET}"
        return 1
    fi
    
    echo -e "${GREEN}✓ ${#ips[@]} hôte(s) trouvé(s)${RESET}\n"
    
    # 2. Scan de ports et services pour chaque hôte
    for ip in "${ips[@]}"; do
        echo -e "${YELLOW}${BOLD}🔍 2. SCAN DÉTAILLÉ: $ip${RESET}\n"
        
        # Scan de ports
        local port_scan_cmd="nmap -sV -sC"
        if [ "$full_scan" = true ]; then
            port_scan_cmd="nmap -sV -sC -p-"
        else
            port_scan_cmd="nmap -sV -sC -F"
        fi
        
        echo -e "${CYAN}Scan de ports en cours...${RESET}"
        local port_scan=$(eval "$port_scan_cmd $ip" 2>/dev/null)
        echo "$port_scan"
        scan_output+="=== SCAN DÉTAILLÉ: $ip ===\n$port_scan\n\n"
        
        # Extraire les ports ouverts
        local open_ports=($(echo "$port_scan" | grep -E "^\d+/" | grep "open" | awk '{print $1}' | cut -d'/' -f1))
        local services=($(echo "$port_scan" | grep -E "^\d+/" | grep "open" | awk '{print $3}'))
        
        if [ ${#open_ports[@]} -gt 0 ]; then
            echo -e "${GREEN}✓ Ports ouverts: ${open_ports[*]}${RESET}"
            scan_summary+="\n$ip:\n"
            scan_summary+="  Ports: ${open_ports[*]}\n"
            scan_summary+="  Services: ${services[*]}\n"
        fi
        
        # 3. Détection OS
        echo -e "${CYAN}Détection OS en cours...${RESET}"
        local os_scan=$(nmap -O --osscan-guess "$ip" 2>/dev/null | grep -i "OS details\|Running\|OS CPE")
        if [ -n "$os_scan" ]; then
            echo "$os_scan"
            scan_output+="=== OS DÉTECTION: $ip ===\n$os_scan\n\n"
        fi
        
        # 4. Scan de vulnérabilités (si demandé)
        if [ "$vuln_scan" = true ]; then
            echo -e "${CYAN}Scan de vulnérabilités en cours...${RESET}"
            local vuln_scan_result=$(nmap --script vuln "$ip" 2>/dev/null)
            if [ -n "$vuln_scan_result" ]; then
                echo "$vuln_scan_result"
                scan_output+="=== VULNÉRABILITÉS: $ip ===\n$vuln_scan_result\n\n"
            fi
        fi
        
        echo ""
    done
    
    # 5. Résumé
    echo -e "${YELLOW}${BOLD}📊 RÉSUMÉ${RESET}\n"
    echo -e "${GREEN}Hôtes scannés: ${#ips[@]}${RESET}"
    echo -e "${GREEN}Scan terminé: $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
    echo -e "$scan_summary"
    
    # Sauvegarder les résultats
    if [ "$save_results" = true ]; then
        if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
            source "$CYBER_DIR/environment_manager.sh"
            if has_active_environment 2>/dev/null; then
                local env_name=$(get_current_environment)
                if [ -n "$env_name" ] && typeset -f auto_save_recon_result >/dev/null 2>&1; then
                    auto_save_recon_result "advanced_network_scan" "Advanced network scan - $target - $(date '+%Y-%m-%d %H:%M:%S')" "$scan_output" "success" 2>/dev/null
                    echo -e "${GREEN}✓ Résultats sauvegardés dans l'environnement: $env_name${RESET}"
                fi
            fi
        fi
    fi
    
    echo ""
}

