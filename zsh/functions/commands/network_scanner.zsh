#!/bin/zsh
# =============================================================================
# NETWORK SCANNER - Analyse réseau en temps réel
# =============================================================================
# Description: Scanner réseau en temps réel pour détecter les appareils connectés
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Scanner réseau en temps réel avec détails complets
# USAGE: network_scanner [--interface] [--range] [--continuous] [--help]
# EXAMPLE: network_scanner
# EXAMPLE: network_scanner --continuous
# EXAMPLE: netscan (alias)
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
    
    # Détecter l'interface réseau si non spécifiée
    if [ -z "$interface" ]; then
        if command -v ip &>/dev/null; then
            interface=$(ip route show default 2>/dev/null | awk '/default/ {print $5}' | head -1)
        elif command -v route &>/dev/null; then
            interface=$(route -n 2>/dev/null | awk '/^0.0.0.0/ {print $8}' | head -1)
        fi
    fi
    
    if [ -z "$interface" ]; then
        echo -e "${RED}❌ Impossible de détecter l'interface réseau${RESET}"
        echo -e "${YELLOW}💡 Spécifiez avec --interface${RESET}"
        return 1
    fi
    
    # Détecter la plage réseau si non spécifiée
    if [ -z "$network_range" ]; then
        if command -v ip &>/dev/null; then
            local ip_addr=$(ip -4 addr show "$interface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
            if [ -n "$ip_addr" ]; then
                # Extraire le préfixe réseau (ex: 192.168.1.0/24)
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
    
    # Fonction pour scanner le réseau
    scan_network() {
        clear
        echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}${BOLD}║          SCANNER RÉSEAU EN TEMPS RÉEL                        ║${RESET}"
        echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${RESET}\n"
        
        echo -e "${BLUE}Interface:${RESET} ${CYAN}$interface${RESET}"
        echo -e "${BLUE}Réseau:${RESET} ${CYAN}$network_range${RESET}"
        echo -e "${BLUE}Heure:${RESET} ${CYAN}$(date '+%Y-%m-%d %H:%M:%S')${RESET}\n"
        
        local devices_found=0
        
        # Méthode 1: ARP table (appareils actifs récents)
        echo -e "${YELLOW}${BOLD}📡 APPAREILS DÉTECTÉS (ARP Table):${RESET}\n"
        
        if [ -f /proc/net/arp ]; then
            printf "${CYAN}%-18s %-18s %-20s %-25s %-20s %-20s %s${RESET}\n" "IP" "MAC" "Interface" "Vendor" "Hostname" "OS" "Status"
            echo "────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────"
            
            while IFS= read -r line; do
                # Ignorer la ligne d'en-tête
                [[ "$line" =~ ^IP ]] && continue
                
                local ip=$(echo "$line" | awk '{print $1}')
                local mac=$(echo "$line" | awk '{print $4}')
                local iface=$(echo "$line" | awk '{print $6}')
                
                # Ignorer les entrées invalides
                [[ "$mac" == "00:00:00:00:00:00" ]] && continue
                [[ -z "$ip" ]] && continue
                
                # Récupérer le hostname
                local hostname=""
                if command -v nmblookup &>/dev/null; then
                    hostname=$(nmblookup -A "$ip" 2>/dev/null | grep -oP '<\d+>\s+\K\S+' | head -1)
                fi
                if [ -z "$hostname" ] && command -v getent &>/dev/null; then
                    hostname=$(getent hosts "$ip" 2>/dev/null | awk '{print $2}' | head -1)
                fi
                if [ -z "$hostname" ]; then
                    hostname="N/A"
                fi
                
                # Détecter le type d'appareil et OS
                local vendor=""
                local os_info=""
                
                # Scan OS avec nmap si disponible
                if command -v nmap &>/dev/null; then
                    local nmap_os=$(nmap -O --osscan-guess "$ip" 2>/dev/null | grep -i "OS details" | head -1 | sed 's/.*OS details: //')
                    if [ -n "$nmap_os" ]; then
                        os_info="$nmap_os"
                    fi
                    
                    # Détection vendor via MAC
                    local nmap_mac=$(nmap --script smb-os-discovery "$ip" 2>/dev/null | grep -i "MAC Address" | head -1)
                    if [ -n "$nmap_mac" ]; then
                        vendor=$(echo "$nmap_mac" | sed 's/.*MAC Address: //' | sed 's/ (.*//')
                    fi
                fi
                
                # Si pas de vendor, essayer de deviner via MAC prefix
                if [ -z "$vendor" ]; then
                    local mac_prefix=$(echo "$mac" | cut -d':' -f1-3 | tr ':' '-')
                    # Base de données MAC vendors courants
                    case "$mac_prefix" in
                        00-50-56|00-0c-29|00-05-69) vendor="VMware" ;;
                        08-00-27) vendor="VirtualBox" ;;
                        52-54-00) vendor="QEMU" ;;
                        00-1b-21|00-1c-42) vendor="Intel" ;;
                        00-1e-c2) vendor="Apple" ;;
                        00-23-24) vendor="Samsung" ;;
                        *) vendor="Unknown" ;;
                    esac
                fi
                
                if [ -z "$os_info" ]; then
                    os_info="Unknown"
                fi
                
                # Ping pour vérifier si actif
                local device_status=""
                if ping -c 1 -W 1 "$ip" &>/dev/null 2>&1; then
                    device_status="${GREEN}●${RESET}"
                    ((devices_found++))
                else
                    device_status="${RED}○${RESET}"
                fi
                
                printf "%-18s %-18s %-20s %-25s %-20s %s %s\n" "$ip" "$mac" "$iface" "$vendor" "$hostname" "$os_info" "$device_status"
            done < <(cat /proc/net/arp | grep -v "^IP")
        fi
        
        echo ""
        echo -e "${GREEN}Appareils actifs détectés: $devices_found${RESET}\n"
        
        # Méthode 2: Scan actif avec nmap (si disponible)
        if command -v nmap &>/dev/null; then
            echo -e "${YELLOW}${BOLD}🔍 SCAN ACTIF (nmap):${RESET}\n"
            echo -e "${CYAN}Scan en cours... (cela peut prendre quelques secondes)${RESET}\n"
            
            # Scan rapide pour détecter les hôtes actifs
            local nmap_output=$(nmap -sn "$network_range" 2>/dev/null | grep -E "Nmap scan report|MAC Address")
            
            if [ -n "$nmap_output" ]; then
                local current_ip=""
                while IFS= read -r line; do
                    if [[ "$line" =~ "Nmap scan report" ]]; then
                        current_ip=$(echo "$line" | grep -oP '\d+(\.\d+){3}')
                        if [ -n "$current_ip" ]; then
                            # Récupérer hostname
                            local hostname_nmap=$(echo "$line" | sed 's/.*for //')
                            if [ "$hostname_nmap" = "$current_ip" ]; then
                                hostname_nmap="N/A"
                            fi
                            
                            # Scan de ports pour cet hôte
                            local open_ports=""
                            local services=""
                            if command -v nmap &>/dev/null; then
                                local port_scan=$(nmap -F "$current_ip" 2>/dev/null)
                                open_ports=$(echo "$port_scan" | grep -E "open" | awk '{print $1}' | cut -d'/' -f1 | tr '\n' ',' | sed 's/,$//')
                                services=$(echo "$port_scan" | grep -E "open" | awk '{print $3}' | tr '\n' ',' | sed 's/,$//')
                            fi
                            
                            # Détection OS
                            local os_detected=""
                            if command -v nmap &>/dev/null; then
                                os_detected=$(nmap -O --osscan-guess "$current_ip" 2>/dev/null | grep -i "OS details" | head -1 | sed 's/.*OS details: //')
                            fi
                            
                            echo -e "${GREEN}●${RESET} ${CYAN}$current_ip${RESET} - ${YELLOW}$hostname_nmap${RESET}"
                            if [ -n "$os_detected" ]; then
                                echo -e "  ${BLUE}OS:${RESET} $os_detected"
                            fi
                            if [ -n "$open_ports" ]; then
                                echo -e "  ${BLUE}Ports ouverts:${RESET} $open_ports"
                                if [ -n "$services" ]; then
                                    echo -e "  ${BLUE}Services:${RESET} $services"
                                fi
                            fi
                        fi
                    elif [[ "$line" =~ "MAC Address" ]]; then
                        local mac_nmap=$(echo "$line" | grep -oP '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}')
                        local vendor_nmap=$(echo "$line" | sed 's/.*MAC Address: //' | sed 's/ (.*//')
                        if [ -n "$mac_nmap" ]; then
                            echo -e "  ${BLUE}MAC:${RESET} $mac_nmap (${vendor_nmap})"
                        fi
                    fi
                done <<< "$nmap_output"
            fi
            echo ""
        else
            echo -e "${YELLOW}💡 Installez nmap pour un scan plus détaillé:${RESET}"
            echo -e "   ${CYAN}sudo pacman -S nmap${RESET} (Arch/Manjaro)"
            echo -e "   ${CYAN}sudo apt install nmap${RESET} (Debian/Ubuntu)"
            echo ""
        fi
        
        # Méthode 3: Connexions actives (ss/netstat)
        echo -e "${YELLOW}${BOLD}🔗 CONNEXIONS ACTIVES:${RESET}\n"
        
        if command -v ss &>/dev/null; then
            local connections=$(ss -tn 2>/dev/null | grep ESTAB | awk '{print $5}' | cut -d':' -f1 | sort | uniq -c | sort -rn | head -10)
            if [ -n "$connections" ]; then
                echo "$connections" | while read count ip; do
                    echo -e "  ${GREEN}$count${RESET} connexions vers ${CYAN}$ip${RESET}"
                done
            else
                echo -e "  ${YELLOW}Aucune connexion active${RESET}"
            fi
        fi
        echo ""
        
        # Statistiques
        echo -e "${YELLOW}${BOLD}📊 STATISTIQUES:${RESET}\n"
        echo -e "  ${GREEN}Appareils détectés:${RESET} $devices_found"
        echo -e "  ${GREEN}Plage réseau:${RESET} $network_range"
        echo -e "  ${GREEN}Interface:${RESET} $interface"
        echo ""
        
        if [ "$continuous" = true ]; then
            echo -e "${CYAN}Prochain scan dans ${scan_interval}s... (Ctrl+C pour arrêter)${RESET}"
            sleep "$scan_interval"
        fi
    }
    
    # Scanner une fois ou en continu
    if [ "$continuous" = true ]; then
        while true; do
            scan_network
        done
    else
        scan_network
    fi
}

# Alias
alias netscan='network_scanner'
alias netscan-continuous='network_scanner --continuous'

