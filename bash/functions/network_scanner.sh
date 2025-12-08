#!/bin/bash
# =============================================================================
# NETWORK SCANNER - Analyse réseau en temps réel (Bash)
# =============================================================================
# Description: Scanner réseau en temps réel pour détecter les appareils connectés
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

network_scanner() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    local interface=""
    local network_range=""
    local continuous=false
    local scan_interval=30
    
    # Parser les arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --interface|-i)
                interface="$2"
                shift 2
                ;;
            --range|-r)
                network_range="$2"
                shift 2
                ;;
            --continuous|-c)
                continuous=true
                shift
                ;;
            --interval)
                scan_interval="$2"
                shift 2
                ;;
            --help|-h)
                echo -e "${CYAN}${BOLD}NETWORK SCANNER - Analyse réseau en temps réel${RESET}\n"
                echo "Usage: network_scanner [options]"
                echo ""
                echo "Options:"
                echo "  --interface, -i <iface>  Interface réseau à utiliser"
                echo "  --range, -r <range>      Plage réseau à scanner (ex: 192.168.1.0/24)"
                echo "  --continuous, -c         Mode continu (scan répété)"
                echo "  --interval <seconds>     Intervalle entre scans (défaut: 30s)"
                echo "  --help, -h               Afficher cette aide"
                echo ""
                echo "Alias: netscan"
                return 0
                ;;
            *)
                echo -e "${RED}❌ Option inconnue: $1${RESET}"
                return 1
                ;;
        esac
    done
    
    # Détecter l'interface réseau
    if [ -z "$interface" ]; then
        if command -v ip &>/dev/null; then
            interface=$(ip route show default 2>/dev/null | awk '/default/ {print $5}' | head -1)
        fi
    fi
    
    if [ -z "$interface" ]; then
        echo -e "${RED}❌ Impossible de détecter l'interface réseau${RESET}"
        echo -e "${YELLOW}💡 Spécifiez avec --interface${RESET}"
        return 1
    fi
    
    # Détecter la plage réseau
    if [ -z "$network_range" ]; then
        if command -v ip &>/dev/null; then
            local ip_addr=$(ip -4 addr show "$interface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
            if [ -n "$ip_addr" ]; then
                local network_base=$(echo "$ip_addr" | cut -d'.' -f1-3)
                network_range="${network_base}.0/24"
            fi
        fi
    fi
    
    if [ -z "$network_range" ]; then
        echo -e "${RED}❌ Impossible de détecter la plage réseau${RESET}"
        echo -e "${YELLOW}💡 Spécifiez avec --range (ex: 192.168.1.0/24)${RESET}"
        return 1
    fi
    
    # Fonction de scan
    scan_network() {
        clear
        echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}${BOLD}║          SCANNER RÉSEAU EN TEMPS RÉEL                        ║${RESET}"
        echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${RESET}\n"
        
        echo -e "${BLUE}Interface:${RESET} ${CYAN}$interface${RESET}"
        echo -e "${BLUE}Réseau:${RESET} ${CYAN}$network_range${RESET}"
        echo -e "${BLUE}Heure:${RESET} ${CYAN}$(date '+%Y-%m-%d %H:%M:%S')${RESET}\n"
        
        local devices_found=0
        
        # ARP Table
        echo -e "${YELLOW}${BOLD}📡 APPAREILS DÉTECTÉS (ARP Table):${RESET}\n"
        
        if [ -f /proc/net/arp ]; then
            printf "${CYAN}%-18s %-18s %-20s %-15s %s${RESET}\n" "IP" "MAC" "Interface" "Type" "Hostname"
            echo "────────────────────────────────────────────────────────────────────────────────"
            
            while IFS= read -r line; do
                [[ "$line" =~ ^IP ]] && continue
                
                local ip=$(echo "$line" | awk '{print $1}')
                local mac=$(echo "$line" | awk '{print $4}')
                local iface=$(echo "$line" | awk '{print $6}')
                
                [[ "$mac" == "00:00:00:00:00:00" ]] && continue
                [[ -z "$ip" ]] && continue
                
                # Hostname
                local hostname=""
                if command -v getent &>/dev/null; then
                    hostname=$(getent hosts "$ip" 2>/dev/null | awk '{print $2}' | head -1)
                fi
                if [ -z "$hostname" ]; then
                    hostname="N/A"
                fi
                
                # Status
                local status=""
                if ping -c 1 -W 1 "$ip" &>/dev/null 2>&1; then
                    status="${GREEN}●${RESET}"
                    ((devices_found++))
                else
                    status="${RED}○${RESET}"
                fi
                
                printf "%-18s %-18s %-20s %-15s %s %s\n" "$ip" "$mac" "$iface" "Unknown" "$hostname" "$status"
            done < <(cat /proc/net/arp | grep -v "^IP")
        fi
        
        echo ""
        echo -e "${GREEN}Appareils actifs détectés: $devices_found${RESET}\n"
        
        # Scan nmap si disponible
        if command -v nmap &>/dev/null; then
            echo -e "${YELLOW}${BOLD}🔍 SCAN ACTIF (nmap):${RESET}\n"
            echo -e "${CYAN}Scan en cours...${RESET}\n"
            
            nmap -sn "$network_range" 2>/dev/null | grep -E "Nmap scan report|MAC Address" | while IFS= read -r line; do
                if [[ "$line" =~ "Nmap scan report" ]]; then
                    local current_ip=$(echo "$line" | grep -oP '\d+(\.\d+){3}')
                    if [ -n "$current_ip" ]; then
                        echo -e "${GREEN}●${RESET} ${CYAN}$current_ip${RESET}"
                    fi
                fi
            done
            echo ""
        fi
    }
    
    # Scanner
    if [ "$continuous" = true ]; then
        while true; do
            scan_network
            sleep "$scan_interval"
        done
    else
        scan_network
    fi
}

# Alias
alias netscan='network_scanner'
alias netscan-continuous='network_scanner --continuous'

