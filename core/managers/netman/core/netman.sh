#!/bin/sh
# =============================================================================
# NETMAN - Network Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des ports, connexions et informations réseau
# Author: Paul Delhomme
# Version: 2.0 - Migration POSIX Complète
# =============================================================================

# Détecter le shell pour adapter certaines syntaxes
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_TYPE="fish"
else
    SHELL_TYPE="sh"
fi

# DESC: Gestionnaire interactif complet pour la gestion réseau
# USAGE: netman [command]
# EXAMPLE: netman
# EXAMPLE: netman ports
# EXAMPLE: netman connections
netman() {
    # Configuration des couleurs
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    # Variables globales pour la fonction
    SELECTED_PORTS=""
    ACTION=""
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                    NETMAN - Network Manager                    ║"
        echo "║                     Gestionnaire Réseau                       ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
        echo ""
    }
    
    # Fonction pour afficher les ports en écoute avec interface interactive
    manage_ports() {
        SELECTED_ITEMS=""
        while true; do
            show_header
            printf "${YELLOW}📡 Ports en écoute sur le système${RESET}\n"
            printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
            
            # Récupération des ports avec sudo si disponible
            PORTS_DATA=""
            if command -v sudo >/dev/null 2>&1; then
                PORTS_DATA=$(sudo lsof -i -P -n 2>/dev/null | grep LISTEN | sort -t: -k2 -n)
            else
                PORTS_DATA=$(lsof -i -P -n 2>/dev/null | grep LISTEN | sort -t: -k2 -n)
            fi
            
            if [ -z "$PORTS_DATA" ]; then
                printf "${RED}❌ Aucun port en écoute trouvé.${RESET}\n"
                echo ""
                printf "Appuyez sur Entrée pour revenir au menu... "
                read dummy
                return
            fi
            
            # Affichage formaté
            printf "${CYAN}%-5s %-10s %-20s %-10s %-15s %-25s %s${RESET}\n" \
                   "N°" "PORT" "COMMANDE" "PID" "USER" "ADRESSE" "STATUS"
            echo "────────────────────────────────────────────────────────────────────────────────"
            
            port_list=""
            i=1
            
            echo "$PORTS_DATA" | while IFS= read -r line; do
                if [ -z "$port_list" ]; then
                    port_list="$line"
                else
                    port_list="$port_list
$line"
                fi
                CMD=$(echo "$line" | awk '{print $1}')
                PID=$(echo "$line" | awk '{print $2}')
                USER=$(echo "$line" | awk '{print $3}')
                ADDR=$(echo "$line" | awk '{print $9}')
                PORT=$(echo "$ADDR" | sed 's/.*://')
                
                # Vérifier si l'item est sélectionné
                STATUS="[ ]"
                case " $SELECTED_ITEMS " in
                    *" $i "*)
                        STATUS="${GREEN}[✓]${RESET}"
                        ;;
                esac
                
                printf "%-5d %-10s %-20.20s %-10s %-15s %-25.25s %s\n" \
                       "$i" "$PORT" "$CMD" "$PID" "$USER" "$ADDR" "$STATUS"
                i=$((i + 1))
            done
            
            echo ""
            printf "${YELLOW}────────────────────────────────────────────────────────────────────${RESET}\n"
            printf "${GREEN}Actions disponibles:${RESET}\n"
            echo "  [1-9] Sélectionner/Désélectionner un port"
            echo "  [k]   Kill les processus sélectionnés"
            echo "  [i]   Informations détaillées sur les ports sélectionnés"
            echo "  [a]   Sélectionner tous les ports"
            echo "  [n]   Désélectionner tout"
            echo "  [r]   Rafraîchir la liste"
            echo "  [q]   Retour au menu principal"
            echo ""
            printf "Votre choix: "
            read action
            echo ""
            
            case "$action" in
                [0-9])
                    case " $SELECTED_ITEMS " in
                        *" $action "*)
                            SELECTED_ITEMS=$(echo "$SELECTED_ITEMS" | sed "s/ $action //")
                            ;;
                        *)
                            SELECTED_ITEMS="$SELECTED_ITEMS $action "
                            ;;
                    esac
                    ;;
                k|K)
                    if [ -z "$SELECTED_ITEMS" ]; then
                        printf "${RED}⚠️  Aucun port sélectionné${RESET}\n"
                        sleep 2
                    else
                        printf "${YELLOW}⚠️  Confirmation requise${RESET}\n"
                        echo "Ports sélectionnés pour termination:"
                        port_index=1
                        echo "$PORTS_DATA" | while IFS= read -r line; do
                            for num in $SELECTED_ITEMS; do
                                if [ "$port_index" -eq "$num" ]; then
                                    PID=$(echo "$line" | awk '{print $2}')
                                    CMD=$(echo "$line" | awk '{print $1}')
                                    PORT=$(echo "$line" | awk '{print $9}' | sed 's/.*://')
                                    echo "  • Port $PORT - $CMD (PID: $PID)"
                                fi
                            done
                            port_index=$((port_index + 1))
                        done
                        echo ""
                        printf "Confirmer la termination? [y/N]: "
                        read confirm
                        echo ""
                        case "$confirm" in
                            [yY]*)
                                port_index=1
                                echo "$PORTS_DATA" | while IFS= read -r line; do
                                    for num in $SELECTED_ITEMS; do
                                        if [ "$port_index" -eq "$num" ]; then
                                            PID=$(echo "$line" | awk '{print $2}')
                                            CMD=$(echo "$line" | awk '{print $1}')
                                            PORT=$(echo "$line" | awk '{print $9}' | sed 's/.*://')
                                            printf "Termination de %s sur port %s (PID: %s)... " "$CMD" "$PORT" "$PID"
                                            if command -v sudo >/dev/null 2>&1; then
                                                sudo kill -TERM "$PID" 2>/dev/null && printf "${GREEN}✓${RESET}\n" || printf "${RED}✗${RESET}\n"
                                            else
                                                kill -TERM "$PID" 2>/dev/null && printf "${GREEN}✓${RESET}\n" || printf "${RED}✗${RESET}\n"
                                            fi
                                        fi
                                    done
                                    port_index=$((port_index + 1))
                                done
                                SELECTED_ITEMS=""
                                sleep 2
                                ;;
                        esac
                    fi
                    ;;
                i|I)
                    if [ -z "$SELECTED_ITEMS" ]; then
                        printf "${RED}⚠️  Aucun port sélectionné${RESET}\n"
                        sleep 2
                    else
                        show_header
                        printf "${CYAN}📋 Informations détaillées${RESET}\n"
                        echo "════════════════════════════════════════"
                        port_index=1
                        echo "$PORTS_DATA" | while IFS= read -r line; do
                            for num in $SELECTED_ITEMS; do
                                if [ "$port_index" -eq "$num" ]; then
                                    PID=$(echo "$line" | awk '{print $2}')
                                    PORT=$(echo "$line" | awk '{print $9}' | sed 's/.*://')
                                    printf "${YELLOW}Port %s:${RESET}\n" "$PORT"
                                    if command -v sudo >/dev/null 2>&1; then
                                        sudo lsof -i :"$PORT" 2>/dev/null | sed 's/^/  /'
                                        echo ""
                                        echo "Connexions actives:"
                                        sudo ss -tnp 2>/dev/null | grep ":$PORT" | sed 's/^/  /'
                                    else
                                        lsof -i :"$PORT" 2>/dev/null | sed 's/^/  /'
                                        echo ""
                                        echo "Connexions actives:"
                                        ss -tn 2>/dev/null | grep ":$PORT" | sed 's/^/  /'
                                    fi
                                    echo "────────────────────────────────"
                                fi
                            done
                            port_index=$((port_index + 1))
                        done
                        echo ""
                        printf "Appuyez sur Entrée pour continuer... "
                        read dummy
                    fi
                    ;;
                a|A)
                    SELECTED_ITEMS=""
                    port_count=$(echo "$PORTS_DATA" | wc -l)
                    j=1
                    while [ $j -le "$port_count" ]; do
                        SELECTED_ITEMS="$SELECTED_ITEMS $j "
                        j=$((j + 1))
                    done
                    ;;
                n|N)
                    SELECTED_ITEMS=""
                    ;;
                r|R)
                    continue
                    ;;
                q|Q)
                    return
                    ;;
            esac
        done
    }
    
    # Fonction pour afficher les connexions actives
    show_connections() {
        show_header
        printf "${YELLOW}🔗 Connexions réseau actives${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        printf "\n${CYAN}Connexions établies (ESTABLISHED):${RESET}\n"
        if command -v ss >/dev/null 2>&1; then
            ss -tunap 2>/dev/null | grep ESTAB | \
            awk '{printf "%-6s %-25s %-25s %-15s\n", $1, $5, $6, $NF}' | \
            sed 's/users:((/PID: /g; s/,fd=.*//g; s/))//g'
        else
            netstat -tunap 2>/dev/null | grep ESTABLISHED
        fi
        
        printf "\n${CYAN}Connexions en attente (TIME_WAIT/CLOSE_WAIT):${RESET}\n"
        if command -v ss >/dev/null 2>&1; then
            ss -tunap 2>/dev/null | grep -E "TIME-WAIT|CLOSE-WAIT" | \
            awk '{printf "%-6s %-25s %-25s %-15s\n", $1, $5, $6, $2}'
        fi
        
        printf "\n${CYAN}Statistiques par protocole:${RESET}\n"
        tcp_count=$(ss -t 2>/dev/null | wc -l | tr -d ' ')
        udp_count=$(ss -u 2>/dev/null | wc -l | tr -d ' ')
        echo "  TCP: $tcp_count connexions"
        echo "  UDP: $udp_count connexions"
        
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Fonction pour afficher les informations IP
    show_ip_info() {
        show_header
        printf "${YELLOW}🌐 Informations IP${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        # IP Publique
        printf "\n${CYAN}Adresse IP Publique:${RESET}\n"
        public_ip=$(curl -s https://ipinfo.io/ip 2>/dev/null || echo "Non disponible")
        echo "  $public_ip"
        
        if [ "$public_ip" != "Non disponible" ]; then
            printf "\n${CYAN}Informations de géolocalisation:${RESET}\n"
            curl -s https://ipinfo.io 2>/dev/null | grep -E '"(city|region|country|org)"' | \
            sed 's/[",]//g; s/^/  /'
        fi
        
        # IPs Locales
        printf "\n${CYAN}Adresses IP Locales:${RESET}\n"
        ip -4 addr show 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+' | \
        while IFS= read -r ip_addr; do
            iface=$(ip -4 addr show 2>/dev/null | grep -B2 "$ip_addr" | head -1 | awk -F: '{print $2}' | tr -d ' ')
            printf "  %-15s %s\n" "$iface:" "$ip_addr"
        done
        
        # IPv6
        printf "\n${CYAN}Adresses IPv6:${RESET}\n"
        ip -6 addr show 2>/dev/null | grep -oP '(?<=inet6\s)[\da-f:]+/\d+' | grep -v "^fe80" | \
        while IFS= read -r ip_addr; do
            iface=$(ip -6 addr show 2>/dev/null | grep -B2 "$ip_addr" | head -1 | awk -F: '{print $2}' | tr -d ' ')
            printf "  %-15s %s\n" "$iface:" "$ip_addr"
        done
        
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Fonction pour afficher les informations DNS
    show_dns_info() {
        show_header
        printf "${YELLOW}🔍 Configuration DNS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        printf "\n${CYAN}Serveurs DNS configurés:${RESET}\n"
        if [ -f /etc/resolv.conf ]; then
            grep "nameserver" /etc/resolv.conf | awk '{printf "  • %s\n", $2}'
        fi
        
        printf "\n${CYAN}Domaine de recherche:${RESET}\n"
        grep "search\|domain" /etc/resolv.conf 2>/dev/null | sed 's/^/  /'
        
        printf "\n${CYAN}Test de résolution DNS:${RESET}\n"
        printf "  google.com: "
        dig +short google.com @8.8.8.8 2>/dev/null | head -1 || echo "Échec"
        printf "  cloudflare.com: "
        dig +short cloudflare.com @1.1.1.1 2>/dev/null | head -1 || echo "Échec"
        
        printf "\n${CYAN}Cache DNS local:${RESET}\n"
        if command -v systemd-resolve >/dev/null 2>&1; then
            systemd-resolve --statistics 2>/dev/null | grep -E "Current Cache|Cache Hits" | sed 's/^/  /'
        else
            echo "  Pas de cache systemd-resolved détecté"
        fi
        
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Fonction pour afficher la table de routage
    show_routing() {
        show_header
        printf "${YELLOW}🛣️  Table de routage${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        printf "\n${CYAN}Routes IPv4:${RESET}\n"
        ip -4 route show 2>/dev/null | while IFS= read -r line; do
            case "$line" in
                *default*)
                    printf "  ${GREEN}%s${RESET}\n" "$line"
                    ;;
                *)
                    echo "  $line"
                    ;;
            esac
        done
        
        printf "\n${CYAN}Routes IPv6:${RESET}\n"
        ip -6 route show 2>/dev/null | head -10 | sed 's/^/  /'
        
        printf "\n${CYAN}Passerelle par défaut:${RESET}\n"
        ip route 2>/dev/null | grep default | awk '{print "  " $3 " via " $5}'
        
        printf "\n${CYAN}Métriques des interfaces:${RESET}\n"
        ip -s link 2>/dev/null | awk '/^[0-9]+:/ {iface=$2} /RX:/ {getline; rx=$1} /TX:/ {getline; tx=$1; printf "  %-15s RX: %-15s TX: %-15s\n", iface, rx, tx}'
        
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Fonction pour afficher les interfaces réseau
    show_interfaces() {
        show_header
        printf "${YELLOW}🖧  Interfaces réseau${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        interfaces=$(ip -o link show 2>/dev/null | awk -F': ' '{print $2}')
        
        for iface in $interfaces; do
            printf "\n${CYAN}Interface: %s${RESET}\n" "$iface"
            echo "─────────────────────────"
            
            # État de l'interface
            state=$(ip link show "$iface" 2>/dev/null | grep -oP '(?<=state )\w+' || echo "UNKNOWN")
            case "$state" in
                UP)
                    printf "  État: ${GREEN}%s${RESET}\n" "$state"
                    ;;
                *)
                    printf "  État: ${RED}%s${RESET}\n" "$state"
                    ;;
            esac
            
            # Adresse MAC
            mac=$(ip link show "$iface" 2>/dev/null | grep -oP '(?<=link/ether )[\da-f:]+' || echo "N/A")
            echo "  MAC: $mac"
            
            # Adresses IP
            echo "  IPv4:"
            ip -4 addr show "$iface" 2>/dev/null | grep inet | awk '{print "    " $2}'
            echo "  IPv6:"
            ip -6 addr show "$iface" 2>/dev/null | grep inet6 | awk '{print "    " $2}'
            
            # Statistiques
            stats=$(ip -s link show "$iface" 2>/dev/null)
            rx_bytes=$(echo "$stats" | awk '/RX:/{getline; print $1}')
            tx_bytes=$(echo "$stats" | awk '/TX:/{getline; print $1}')
            
            if [ -n "$rx_bytes" ]; then
                echo "  Statistiques:"
                rx_formatted=$(numfmt --to=iec-i --suffix=B "$rx_bytes" 2>/dev/null || echo "${rx_bytes}B")
                tx_formatted=$(numfmt --to=iec-i --suffix=B "$tx_bytes" 2>/dev/null || echo "${tx_bytes}B")
                echo "    RX: $rx_formatted"
                echo "    TX: $tx_formatted"
            fi
        done
        
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Fonction pour scanner un port spécifique
    scan_port() {
        show_header
        printf "${YELLOW}🔍 Scanner de port${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo ""
        
        printf "Entrez l'hôte à scanner (défaut: localhost): "
        read host
        host="${host:-localhost}"
        
        printf "Entrez le port ou la plage de ports (ex: 80 ou 80-443): "
        read port
        
        case "$port" in
            *-*)
                # Plage de ports
                start_port=$(echo "$port" | cut -d- -f1)
                end_port=$(echo "$port" | cut -d- -f2)
                printf "\n${CYAN}Scan des ports %s à %s sur %s...${RESET}\n" "$start_port" "$end_port" "$host"
                echo "Ports ouverts:"
                p=$start_port
                while [ $p -le $end_port ]; do
                    if timeout 0.5 bash -c "echo >/dev/tcp/$host/$p" 2>/dev/null; then
                        service=$(grep -E "^[^#]*\s$p/" /etc/services 2>/dev/null | head -1 | awk '{print $1}')
                        if [ -n "$service" ]; then
                            printf "  Port %d: ${GREEN}OUVERT${RESET} (%s)\n" "$p" "$service"
                        else
                            printf "  Port %d: ${GREEN}OUVERT${RESET}\n" "$p"
                        fi
                    fi
                    p=$((p + 1))
                done
                ;;
            [0-9]*)
                # Port unique
                printf "\n${CYAN}Test du port %s sur %s...${RESET}\n" "$port" "$host"
                if timeout 2 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
                    printf "  Port %s: ${GREEN}OUVERT${RESET}\n" "$port"
                    service=$(grep -E "^[^#]*\s$port/" /etc/services 2>/dev/null | head -1 | awk '{print $1}')
                    [ -n "$service" ] && echo "  Service probable: $service"
                else
                    printf "  Port %s: ${RED}FERMÉ${RESET}\n" "$port"
                fi
                ;;
            *)
                printf "${RED}Format de port invalide${RESET}\n"
                ;;
        esac
        
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Fonction pour kill un port spécifique
    kill_port_quick() {
        show_header
        printf "${YELLOW}💀 Kill rapide de port${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo ""
        
        printf "Entrez le numéro du port à libérer: "
        read port
        
        case "$port" in
            [0-9]*)
                printf "\n${CYAN}Recherche des processus sur le port %s...${RESET}\n" "$port"
                
                procs=""
                if command -v sudo >/dev/null 2>&1; then
                    procs=$(sudo lsof -i :"$port" 2>/dev/null | grep LISTEN)
                else
                    procs=$(lsof -i :"$port" 2>/dev/null | grep LISTEN)
                fi
                
                if [ -z "$procs" ]; then
                    printf "${GREEN}✓ Aucun processus trouvé sur le port %s${RESET}\n" "$port"
                else
                    echo "Processus trouvés:"
                    echo "$procs" | while IFS= read -r line; do
                        cmd=$(echo "$line" | awk '{print $1}')
                        pid=$(echo "$line" | awk '{print $2}')
                        user=$(echo "$line" | awk '{print $3}')
                        echo "  • $cmd (PID: $pid, User: $user)"
                    done
                    
                    echo ""
                    printf "Voulez-vous tuer ces processus? [y/N]: "
                    read confirm
                    echo ""
                    
                    case "$confirm" in
                        [yY]*)
                            echo "$procs" | awk '{print $2}' | while IFS= read -r pid; do
                                printf "Termination du PID %s... " "$pid"
                                if command -v sudo >/dev/null 2>&1; then
                                    sudo kill -TERM "$pid" 2>/dev/null && printf "${GREEN}✓${RESET}\n" || printf "${RED}✗${RESET}\n"
                                else
                                    kill -TERM "$pid" 2>/dev/null && printf "${GREEN}✓${RESET}\n" || printf "${RED}✗${RESET}\n"
                                fi
                            done
                            ;;
                    esac
                fi
                ;;
            *)
                printf "${RED}❌ Port invalide${RESET}\n"
                sleep 2
                return
                ;;
        esac
        
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Fonction pour afficher les statistiques réseau
    show_network_stats() {
        show_header
        printf "${YELLOW}📊 Statistiques réseau${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        printf "\n${CYAN}Statistiques globales:${RESET}\n"
        if command -v netstat >/dev/null 2>&1; then
            netstat -s 2>/dev/null | grep -E "active connection|passive connection|failed connection|segments sent|segments received" | sed 's/^/  /'
        fi
        
        printf "\n${CYAN}Top 10 des connexions par IP:${RESET}\n"
        ss -tn 2>/dev/null | awk 'NR>1 {print $5}' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | \
        sort | uniq -c | sort -rn | head -10 | \
        awk '{printf "  %3d connexions: %s\n", $1, $2}'
        
        printf "\n${CYAN}Utilisation de la bande passante (temps réel):${RESET}\n"
        echo "  Appuyez sur 'q' pour quitter la surveillance..."
        echo ""
        
        # Surveillance en temps réel pendant 5 secondes
        count=0
        while [ $count -lt 5 ]; do
            rx_bytes=$(cat /sys/class/net/*/statistics/rx_bytes 2>/dev/null | awk '{sum+=$1} END {print sum}')
            tx_bytes=$(cat /sys/class/net/*/statistics/tx_bytes 2>/dev/null | awk '{sum+=$1} END {print sum}')
            sleep 1
            rx_bytes_new=$(cat /sys/class/net/*/statistics/rx_bytes 2>/dev/null | awk '{sum+=$1} END {print sum}')
            tx_bytes_new=$(cat /sys/class/net/*/statistics/tx_bytes 2>/dev/null | awk '{sum+=$1} END {print sum}')
            
            rx_rate=$((rx_bytes_new - rx_bytes))
            tx_rate=$((tx_bytes_new - tx_bytes))
            
            rx_formatted=$(numfmt --to=iec-i --suffix=B "$rx_rate" 2>/dev/null || echo "${rx_rate}B")
            tx_formatted=$(numfmt --to=iec-i --suffix=B "$tx_rate" 2>/dev/null || echo "${tx_rate}B")
            
            printf "\r  ↓ RX: %s/s  ↑ TX: %s/s  " "$rx_formatted" "$tx_formatted"
            
            count=$((count + 1))
        done
        
        echo ""
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Fonction pour tester la connectivité réseau
    test_connectivity() {
        show_header
        printf "${YELLOW}🌐 Test de connectivité réseau${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo ""
        
        printf "Entrez l'hôte à tester (défaut: google.com): "
        read host
        host="${host:-google.com}"
        
        echo ""
        printf "${CYAN}Ping vers %s...${RESET}\n" "$host"
        if command -v ping >/dev/null 2>&1; then
            ping -c 4 "$host" 2>/dev/null || ping -c 4 "$host" 2>/dev/null
        else
            printf "${RED}✗ ping non disponible${RESET}\n"
        fi
        
        echo ""
        printf "${CYAN}Traceroute vers %s (premiers 10 sauts)...${RESET}\n" "$host"
        if command -v traceroute >/dev/null 2>&1; then
            traceroute -m 10 "$host" 2>/dev/null | head -15
        elif command -v tracepath >/dev/null 2>&1; then
            tracepath "$host" 2>/dev/null | head -15
        else
            printf "${YELLOW}⚠️  traceroute/tracepath non disponible${RESET}\n"
        fi
        
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Fonction pour tester la vitesse réseau
    test_network_speed() {
        show_header
        printf "${YELLOW}⚡ Test de vitesse réseau${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo ""
        
        printf "${CYAN}Test de téléchargement...${RESET}\n"
        echo "Téléchargement d'un fichier de test (10MB)..."
        
        start_time=$(date +%s)
        downloaded=$(curl -s -o /dev/null -w "%{size_download}" --max-time 30 "http://speedtest.tele2.net/10MB.zip" 2>/dev/null || echo "0")
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        
        if [ "$downloaded" != "0" ] && [ "$duration" -gt 0 ]; then
            speed=$((downloaded * 8 / duration / 1000))  # en Kbps
            speed_mbps=$((speed / 1000))
            printf "${GREEN}✓ Vitesse de téléchargement: %d Mbps (%d Kbps)${RESET}\n" "$speed_mbps" "$speed"
        else
            printf "${RED}✗ Échec du test de téléchargement${RESET}\n"
        fi
        
        echo ""
        printf "${CYAN}Test de latence...${RESET}\n"
        if command -v ping >/dev/null 2>&1; then
            ping_result=$(ping -c 5 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}')
            if [ -n "$ping_result" ]; then
                printf "${GREEN}✓ Latence moyenne: %s ms${RESET}\n" "$ping_result"
            else
                printf "${RED}✗ Échec du test de latence${RESET}\n"
            fi
        fi
        
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Fonction pour monitorer la bande passante en temps réel
    monitor_bandwidth() {
        show_header
        printf "${YELLOW}📊 Monitoring de bande passante en temps réel${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo ""
        echo "Appuyez sur 'q' puis Entrée pour quitter..."
        echo ""
        
        interface=$(ip route 2>/dev/null | grep default | awk '{print $5}' | head -1)
        if [ -z "$interface" ]; then
            interface="eth0"
        fi
        
        printf "${CYAN}Interface: %s${RESET}\n" "$interface"
        echo ""
        
        while true; do
            rx_bytes=$(cat "/sys/class/net/$interface/statistics/rx_bytes" 2>/dev/null || echo "0")
            tx_bytes=$(cat "/sys/class/net/$interface/statistics/tx_bytes" 2>/dev/null || echo "0")
            
            sleep 1
            
            rx_bytes_new=$(cat "/sys/class/net/$interface/statistics/rx_bytes" 2>/dev/null || echo "0")
            tx_bytes_new=$(cat "/sys/class/net/$interface/statistics/tx_bytes" 2>/dev/null || echo "0")
            
            rx_rate=$((rx_bytes_new - rx_bytes))
            tx_rate=$((tx_bytes_new - tx_bytes))
            
            rx_formatted=$(numfmt --to=iec-i --suffix=B/s "$rx_rate" 2>/dev/null || echo "${rx_rate}B/s")
            tx_formatted=$(numfmt --to=iec-i --suffix=B/s "$tx_rate" 2>/dev/null || echo "${tx_rate}B/s")
            
            printf "\r  ↓ RX: %-12s  ↑ TX: %-12s  [Appuyez sur 'q' puis Entrée pour quitter]" "$rx_formatted" "$tx_formatted"
            
            # Vérifier si 'q' a été pressé (non-bloquant)
            if read -t 0.1 key 2>/dev/null; then
                case "$key" in
                    q|Q)
                        echo ""
                        break
                        ;;
                esac
            fi
        done
        
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Fonction pour analyser le trafic réseau
    analyze_traffic() {
        show_header
        printf "${YELLOW}🔍 Analyse du trafic réseau${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo ""
        
        printf "${CYAN}Top 10 des connexions par IP:${RESET}\n"
        ss -tn 2>/dev/null | awk 'NR>1 {print $5}' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | \
        sort | uniq -c | sort -rn | head -10 | \
        awk '{printf "  %3d connexions: %s\n", $1, $2}'
        
        echo ""
        printf "${CYAN}Top 10 des ports utilisés:${RESET}\n"
        ss -tn 2>/dev/null | awk 'NR>1 {print $5}' | grep -oE ':[0-9]+' | sed 's/://' | \
        sort | uniq -c | sort -rn | head -10 | \
        awk '{printf "  %3d connexions: port %s\n", $1, $2}'
        
        echo ""
        printf "${CYAN}Répartition par état:${RESET}\n"
        ss -tn 2>/dev/null | awk 'NR>1 {print $1}' | sort | uniq -c | \
        awk '{printf "  %-15s: %3d connexions\n", $2, $1}'
        
        echo ""
        printf "${CYAN}Protocoles utilisés:${RESET}\n"
        ss -tn 2>/dev/null | awk 'NR>1 {print $1}' | sort | uniq | \
        while IFS= read -r proto; do
            count=$(ss -tn 2>/dev/null | grep -c "^$proto")
            echo "  $proto: $count connexions"
        done
        
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Fonction pour exporter la configuration réseau
    export_network_config() {
        show_header
        printf "${YELLOW}💾 Export de la configuration réseau${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        timestamp=$(date +%Y%m%d_%H%M%S)
        export_file="$HOME/network_config_$timestamp.txt"
        
        {
            echo "=== Configuration Réseau - Export du $(date) ==="
            echo ""
            echo "=== INTERFACES ==="
            ip addr show
            echo ""
            echo "=== ROUTES ==="
            ip route show
            echo ""
            echo "=== DNS ==="
            cat /etc/resolv.conf
            echo ""
            echo "=== PORTS EN ÉCOUTE ==="
            if command -v sudo >/dev/null 2>&1; then
                sudo lsof -i -P -n 2>/dev/null | grep LISTEN
            else
                lsof -i -P -n 2>/dev/null | grep LISTEN
            fi
            echo ""
            echo "=== CONNEXIONS ACTIVES ==="
            ss -tunap
            echo ""
            echo "=== FIREWALL (iptables) ==="
            if command -v sudo >/dev/null 2>&1; then
                sudo iptables -L -n -v 2>/dev/null || echo "iptables non disponible"
            fi
        } > "$export_file"
        
        printf "${GREEN}✓ Configuration exportée vers: %s${RESET}\n" "$export_file"
        echo ""
        echo "Contenu du fichier:"
        echo "─────────────────────"
        head -20 "$export_file"
        echo "..."
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Gestion des arguments en ligne de commande
    if [ -n "$1" ]; then
        _nmdf="${DOTFILES_DIR:-$HOME/dotfiles}"
        if [ -f "$_nmdf/scripts/lib/managers_log_posix.sh" ]; then
            # shellcheck source=managers_log_posix.sh
            . "$_nmdf/scripts/lib/managers_log_posix.sh"
            managers_cli_log netman "$@"
        fi
        case "$1" in
            ports)
                manage_ports
                ;;
            connections|conn)
                show_connections
                ;;
            ip|ipinfo)
                show_ip_info
                ;;
            dns)
                show_dns_info
                ;;
            routing|route)
                show_routing
                ;;
            interfaces|iface)
                show_interfaces
                ;;
            scan)
                if [ -n "$2" ]; then
                    host="$2"
                    port="${3:-80}"
                    printf "Scan du port %s sur %s...\n" "$port" "$host"
                    if timeout 2 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
                        printf "${GREEN}✓ Port %s OUVERT${RESET}\n" "$port"
                    else
                        printf "${RED}✗ Port %s FERMÉ${RESET}\n" "$port"
                    fi
                else
                    scan_port
                fi
                ;;
            kill)
                if [ -n "$2" ]; then
                    port="$2"
                    printf "Kill rapide du port %s...\n" "$port"
                    pids=""
                    if command -v sudo >/dev/null 2>&1; then
                        pids=$(sudo lsof -t -i:"$port" 2>/dev/null)
                    else
                        pids=$(lsof -t -i:"$port" 2>/dev/null)
                    fi
                    
                    if [ -n "$pids" ]; then
                        echo "PIDs trouvés: $pids"
                        for pid in $pids; do
                            if command -v sudo >/dev/null 2>&1; then
                                sudo kill -TERM "$pid" 2>/dev/null && printf "✓ PID %s terminé\n" "$pid"
                            else
                                kill -TERM "$pid" 2>/dev/null && printf "✓ PID %s terminé\n" "$pid"
                            fi
                        done
                    else
                        printf "Aucun processus sur le port %s\n" "$port"
                    fi
                else
                    kill_port_quick
                fi
                ;;
            stats)
                show_network_stats
                ;;
            connectivity|ping)
                test_connectivity
                ;;
            speed)
                test_network_speed
                ;;
            monitor|bandwidth)
                monitor_bandwidth
                ;;
            analyze|traffic)
                analyze_traffic
                ;;
            export)
                export_network_config
                ;;
            help|--help|-h)
                show_header
                printf "${CYAN}📚 Aide - NETMAN${RESET}\n"
                printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
                echo ""
                echo "NETMAN est un gestionnaire réseau complet."
                echo ""
                echo "Fonctionnalités principales:"
                echo "  • Gestion interactive des ports avec sélection multiple"
                echo "  • Visualisation des connexions réseau en temps réel"
                echo "  • Informations IP publiques et locales"
                echo "  • Configuration et test DNS"
                echo "  • Table de routage et métriques"
                echo "  • Scan de ports sur hosts locaux ou distants"
                echo "  • Kill rapide de processus par port"
                echo "  • Statistiques réseau détaillées"
                echo "  • Test de connectivité (ping/traceroute)"
                echo "  • Test de vitesse réseau"
                echo "  • Monitoring de bande passante en temps réel"
                echo "  • Analyse du trafic réseau"
                echo "  • Export de configuration complète"
                echo ""
                echo "Raccourcis:"
                echo "  netman              - Lance le gestionnaire"
                echo "  netman ports        - Accès direct aux ports"
                echo "  netman kill <port>  - Kill rapide d'un port"
                echo "  netman scan <host>  - Scan rapide d'un host"
                echo "  netman stats        - Statistiques directes"
                echo ""
                ;;
            *)
                printf "${RED}Commande inconnue: %s${RESET}\n" "$1"
                echo "Utilisez 'netman help' pour voir les commandes disponibles"
                return 1
                ;;
        esac
    else
        # Menu principal interactif
        while true; do
            show_header
            printf "${GREEN}Menu Principal${RESET}\n"
            printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
            echo ""
            echo "  ${BOLD}1${RESET}  📡 Gérer les ports en écoute (interactif)"
            echo "  ${BOLD}2${RESET}  🔗 Afficher les connexions actives"
            echo "  ${BOLD}3${RESET}  🌐 Informations IP (publique/locale)"
            echo "  ${BOLD}4${RESET}  🔍 Configuration DNS"
            echo "  ${BOLD}5${RESET}  🛣️  Table de routage"
            echo "  ${BOLD}6${RESET}  🖧  Interfaces réseau"
            echo "  ${BOLD}7${RESET}  🔍 Scanner un port spécifique"
            echo "  ${BOLD}8${RESET}  💀 Kill rapide d'un port"
            echo "  ${BOLD}9${RESET}  📊 Statistiques réseau"
            echo "  ${BOLD}a${RESET}  🌐 Test de connectivité (ping/traceroute)"
            echo "  ${BOLD}b${RESET}  ⚡ Test de vitesse réseau"
            echo "  ${BOLD}c${RESET}  📊 Monitoring bande passante (temps réel)"
            echo "  ${BOLD}d${RESET}  🔍 Analyse du trafic réseau"
            echo "  ${BOLD}0${RESET}  💾 Exporter la configuration"
            echo ""
            echo "  ${BOLD}h${RESET}  📚 Aide"
            echo "  ${BOLD}q${RESET}  🚪 Quitter"
            echo ""
            printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
            printf "Votre choix: "
            read choice
            echo ""
            
            case "$choice" in
                1) manage_ports ;;
                2) show_connections ;;
                3) show_ip_info ;;
                4) show_dns_info ;;
                5) show_routing ;;
                6) show_interfaces ;;
                7) scan_port ;;
                8) kill_port_quick ;;
                9) show_network_stats ;;
                a|A) test_connectivity ;;
                b|B) test_network_speed ;;
                c|C) monitor_bandwidth ;;
                d|D) analyze_traffic ;;
                0) export_network_config ;;
                h|H)
                    show_header
                    printf "${CYAN}📚 Aide - NETMAN${RESET}\n"
                    printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
                    echo ""
                    echo "NETMAN est un gestionnaire réseau complet."
                    echo ""
                    echo "Fonctionnalités principales:"
                    echo "  • Gestion interactive des ports avec sélection multiple"
                    echo "  • Visualisation des connexions réseau en temps réel"
                    echo "  • Informations IP publiques et locales"
                    echo "  • Configuration et test DNS"
                    echo "  • Table de routage et métriques"
                    echo "  • Scan de ports sur hosts locaux ou distants"
                    echo "  • Kill rapide de processus par port"
                    echo "  • Statistiques réseau détaillées"
                    echo "  • Test de connectivité (ping/traceroute)"
                    echo "  • Test de vitesse réseau"
                    echo "  • Monitoring de bande passante en temps réel"
                    echo "  • Analyse du trafic réseau"
                    echo "  • Export de configuration complète"
                    echo ""
                    echo "Raccourcis:"
                    echo "  netman              - Lance le gestionnaire"
                    echo "  netman ports        - Accès direct aux ports"
                    echo "  netman kill <port>  - Kill rapide d'un port"
                    echo "  netman scan <host>  - Scan rapide d'un host"
                    echo "  netman stats       - Statistiques directes"
                    echo ""
                    printf "Appuyez sur Entrée pour continuer... "
                    read dummy
                    ;;
                q|Q)
                    printf "${GREEN}Au revoir!${RESET}\n"
                    break
                    ;;
                *)
                    printf "${RED}Option invalide${RESET}\n"
                    sleep 1
                    ;;
            esac
        done
    fi
}
