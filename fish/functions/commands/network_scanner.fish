# =============================================================================
# NETWORK SCANNER - Analyse réseau en temps réel (Fish)
# =============================================================================
# Description: Scanner réseau en temps réel pour détecter les appareils connectés
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

function network_scanner --description "Scanner réseau en temps réel avec détails complets"
    set -l RED '\033[0;31m'
    set -l GREEN '\033[0;32m'
    set -l YELLOW '\033[1;33m'
    set -l BLUE '\033[0;34m'
    set -l CYAN '\033[0;36m'
    set -l BOLD '\033[1m'
    set -l RESET '\033[0m'
    
    set -l interface ""
    set -l network_range ""
    set -l continuous false
    set -l scan_interval 30
    
    # Parser les arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --interface -i
                set interface $argv[(math $i + 1)]
                set i (math $i + 2)
            case --range -r
                set network_range $argv[(math $i + 1)]
                set i (math $i + 2)
            case --continuous -c
                set continuous true
                set i (math $i + 1)
            case --interval
                set scan_interval $argv[(math $i + 1)]
                set i (math $i + 2)
            case --help -h
                echo -e "$CYAN$BOLD""NETWORK SCANNER - Analyse réseau en temps réel""$RESET\n"
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
            case '*'
                echo -e "$RED""❌ Option inconnue: $argv[$i]""$RESET"
                return 1
        end
    end
    
    # Détecter l'interface réseau
    if test -z "$interface"
        if command -v ip >/dev/null 2>&1
            set interface (ip route show default 2>/dev/null | awk '/default/ {print $5}' | head -1)
        end
    end
    
    if test -z "$interface"
        echo -e "$RED""❌ Impossible de détecter l'interface réseau""$RESET"
        echo -e "$YELLOW""💡 Spécifiez avec --interface""$RESET"
        return 1
    end
    
    # Détecter la plage réseau
    if test -z "$network_range"
        if command -v ip >/dev/null 2>&1
            set -l ip_addr (ip -4 addr show "$interface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
            if test -n "$ip_addr"
                set -l network_base (echo "$ip_addr" | cut -d'.' -f1-3)
                set network_range "$network_base.0/24"
            end
        end
    end
    
    if test -z "$network_range"
        echo -e "$RED""❌ Impossible de détecter la plage réseau""$RESET"
        echo -e "$YELLOW""💡 Spécifiez avec --range (ex: 192.168.1.0/24)""$RESET"
        return 1
    end
    
    # Fonction de scan
    function scan_network
        clear
        echo -e "$CYAN$BOLD""╔════════════════════════════════════════════════════════════════╗""$RESET"
        echo -e "$CYAN$BOLD""║          SCANNER RÉSEAU EN TEMPS RÉEL                        ║""$RESET"
        echo -e "$CYAN$BOLD""╚════════════════════════════════════════════════════════════════╝""\n"
        
        echo -e "$BLUE""Interface:""$RESET"" $CYAN$interface$RESET"
        echo -e "$BLUE""Réseau:""$RESET"" $CYAN$network_range$RESET"
        echo -e "$BLUE""Heure:""$RESET"" $CYAN"(date '+%Y-%m-%d %H:%M:%S')"$RESET\n"
        
        set -l devices_found 0
        
        # ARP Table
        echo -e "$YELLOW$BOLD""📡 APPAREILS DÉTECTÉS (ARP Table):""$RESET\n"
        
        if test -f /proc/net/arp
            printf "$CYAN""%-18s %-18s %-20s %-15s %s""$RESET\n" "IP" "MAC" "Interface" "Type" "Hostname"
            echo "────────────────────────────────────────────────────────────────────────────────"
            
            cat /proc/net/arp | grep -v "^IP" | while read -l line
                set -l ip (echo "$line" | awk '{print $1}')
                set -l mac (echo "$line" | awk '{print $4}')
                set -l iface (echo "$line" | awk '{print $6}')
                
                if test "$mac" = "00:00:00:00:00:00"; or test -z "$ip"
                    continue
                end
                
                # Hostname
                set -l hostname ""
                if command -v getent >/dev/null 2>&1
                    set hostname (getent hosts "$ip" 2>/dev/null | awk '{print $2}' | head -1)
                end
                if test -z "$hostname"
                    set hostname "N/A"
                end
                
                # Status
                set -l status ""
                if ping -c 1 -W 1 "$ip" >/dev/null 2>&1
                    set status "$GREEN●$RESET"
                    set devices_found (math $devices_found + 1)
                else
                    set status "$RED○$RESET"
                end
                
                printf "%-18s %-18s %-20s %-15s %s %s\n" "$ip" "$mac" "$iface" "Unknown" "$hostname" "$status"
            end
        end
        
        echo ""
        echo -e "$GREEN""Appareils actifs détectés: $devices_found""$RESET\n"
        
        # Scan nmap si disponible
        if command -v nmap >/dev/null 2>&1
            echo -e "$YELLOW$BOLD""🔍 SCAN ACTIF (nmap):""$RESET\n"
            echo -e "$CYAN""Scan en cours...""$RESET\n"
            
            nmap -sn "$network_range" 2>/dev/null | grep -E "Nmap scan report|MAC Address" | while read -l line
                if echo "$line" | grep -q "Nmap scan report"
                    set -l current_ip (echo "$line" | grep -oP '\d+(\.\d+){3}')
                    if test -n "$current_ip"
                        echo -e "$GREEN●$RESET $CYAN$current_ip$RESET"
                    end
                end
            end
            echo ""
        end
    end
    
    # Scanner
    if test "$continuous" = "true"
        while true
            scan_network
            sleep "$scan_interval"
        end
    else
        scan_network
    end
end

# Alias
function netscan; network_scanner $argv; end
function netscan-continuous; network_scanner --continuous $argv; end

