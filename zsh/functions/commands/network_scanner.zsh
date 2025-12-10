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
            
            # Extraire le réseau de base (ex: 192.168.1)
            local network_base=$(echo "$network_range" | cut -d'/' -f1 | cut -d'.' -f1-3)
            
            while IFS= read -r line; do
                # Ignorer la ligne d'en-tête
                [[ "$line" =~ ^IP ]] && continue
                
                local ip=$(echo "$line" | awk '{print $1}')
                local mac=$(echo "$line" | awk '{print $4}')
                local iface=$(echo "$line" | awk '{print $6}')
                
                # Ignorer les entrées invalides
                [[ "$mac" == "00:00:00:00:00:00" ]] && continue
                [[ -z "$ip" ]] && continue
                
                # Filtrer les interfaces Docker/bridge/virtual
                if [[ "$iface" =~ ^(br-|docker|virbr|veth|lo) ]]; then
                    continue
                fi
                
                # Filtrer les IPs Docker (172.16.0.0/12, 10.0.0.0/8 pour Docker)
                if [[ "$ip" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\..* ]] || [[ "$ip" =~ ^10\. ]]; then
                    continue
                fi
                
                # Filtrer pour ne garder que le réseau spécifié
                local ip_base=$(echo "$ip" | cut -d'.' -f1-3)
                if [ "$ip_base" != "$network_base" ]; then
                    continue
                fi
                
                # Ignorer l'IP locale
                if [ "$ip" = "127.0.0.1" ]; then
                    continue
                fi
                
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
                
                # Détection vendor via MAC prefix (plus rapide et fiable)
                local mac_prefix=$(echo "$mac" | cut -d':' -f1-3 | tr ':' '-')
                local mac_oui=$(echo "$mac" | cut -d':' -f1-3 | tr ':' '')
                
                # Base de données MAC vendors étendue
                case "$mac_prefix" in
                    00-50-56|00-0c-29|00-05-69) vendor="VMware" ;;
                    08-00-27) vendor="VirtualBox" ;;
                    52-54-00) vendor="QEMU" ;;
                    00-1b-21|00-1c-42|00-1e-67|00-1e-c2) vendor="Intel" ;;
                    00-1e-c2|00-23-12|00-23-24|00-23-6c|00-23-df) vendor="Apple" ;;
                    00-23-24|00-23-39|00-23-6c) vendor="Samsung" ;;
                    00-1d-0f|00-1d-7e) vendor="Sony" ;;
                    00-24-36|00-24-90) vendor="Microsoft" ;;
                    00-25-00|00-25-90) vendor="LG" ;;
                    00-26-18|00-26-4a) vendor="Huawei" ;;
                    00-26-bb) vendor="Xiaomi" ;;
                    00-27-22) vendor="TP-Link" ;;
                    00-50-f2) vendor="Cisco" ;;
                    00-90-27) vendor="Netgear" ;;
                    00-a0-c9) vendor="D-Link" ;;
                    00-e0-4c) vendor="Realtek" ;;
                    00-e0-18) vendor="Broadcom" ;;
                    00-0d-4b) vendor="Raspberry Pi" ;;
                    *) 
                        # Essayer avec nmap si disponible (plus lent mais plus précis)
                        if command -v nmap &>/dev/null; then
                            local nmap_vendor=$(nmap --script smb-os-discovery -sn "$ip" 2>/dev/null | grep -i "MAC Address" | head -1 | sed 's/.*MAC Address: //' | sed 's/ (.*//')
                            if [ -n "$nmap_vendor" ] && [ "$nmap_vendor" != "Unknown" ]; then
                                vendor="$nmap_vendor"
                            else
                                vendor="Unknown"
                            fi
                        else
                            vendor="Unknown"
                        fi
                        ;;
                esac
                
                # Détection OS (méthodes rapides d'abord)
                # Méthode 1: TTL (Time To Live) - rapide et fiable
                local ttl=$(ping -c 1 -W 1 "$ip" 2>/dev/null | grep -oP 'ttl=\K\d+' | head -1)
                if [ -n "$ttl" ]; then
                    if [ "$ttl" -le 64 ]; then
                        os_info="Linux/Unix"
                    elif [ "$ttl" -le 128 ]; then
                        os_info="Windows"
                    elif [ "$ttl" -le 255 ]; then
                        os_info="Network Device"
                    fi
                fi
                
                # Méthode 2: Scan nmap rapide (si disponible et OS non détecté)
                if [ -z "$os_info" ] || [ "$os_info" = "Unknown" ]; then
                    if command -v nmap &>/dev/null; then
                        # Scan rapide avec détection OS (timeout court)
                        local nmap_os=$(timeout 5 nmap -O --osscan-guess --max-retries 1 "$ip" 2>/dev/null | grep -i "OS details" | head -1 | sed 's/.*OS details: //' | cut -c1-30)
                        if [ -n "$nmap_os" ] && [ "$nmap_os" != "Unknown" ]; then
                            os_info="$nmap_os"
                        fi
                    fi
                fi
                
                # Méthode 3: Détection via hostname
                if [ -n "$hostname" ] && [ "$hostname" != "N/A" ]; then
                    if [[ "$hostname" =~ -[0-9]+$ ]] || [[ "$hostname" =~ ^android- ]]; then
                        os_info="Android"
                    elif [[ "$hostname" =~ ^iPhone ]] || [[ "$hostname" =~ ^iPad ]]; then
                        os_info="iOS"
                    elif [[ "$hostname" =~ ^raspberrypi ]]; then
                        os_info="Raspberry Pi OS"
                    fi
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
                
                # Utiliser echo -e pour interpréter les codes ANSI
                echo -e "$(printf '%-18s %-18s %-20s %-25s %-20s %-20s' "$ip" "$mac" "$iface" "$vendor" "$hostname" "$os_info") $device_status"
            done < <(cat /proc/net/arp | grep -v "^IP")
        fi
        
        echo ""
        echo -e "${GREEN}Appareils actifs détectés: $devices_found${RESET}\n"
        
        # Méthode 2: Scan actif avec nmap (si disponible)
        if command -v nmap &>/dev/null; then
            echo -e "${YELLOW}${BOLD}🔍 SCAN ACTIF (nmap):${RESET}\n"
            echo -e "${CYAN}Scan en cours sur $network_range via $interface... (cela peut prendre quelques secondes)${RESET}\n"
            
            # Scan rapide pour détecter les hôtes actifs (uniquement sur l'interface principale)
            local nmap_output=$(nmap -sn -e "$interface" "$network_range" 2>/dev/null | grep -E "Nmap scan report|MAC Address")
            
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

