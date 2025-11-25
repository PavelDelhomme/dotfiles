#!/bin/zsh
# =============================================================================
# NETMAN - Network Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet des ports, connexions et informations réseau
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Gestionnaire interactif complet pour la gestion réseau. Permet de gérer les ports, connexions, interfaces réseau, DNS, et obtenir des informations détaillées sur le réseau.
# USAGE: netman [command]
# EXAMPLE: netman
# EXAMPLE: netman ports
# EXAMPLE: netman connections
netman() {
    # Configuration des couleurs
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local MAGENTA='\033[0;35m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    # Variables globales pour la fonction
    local SELECTED_PORTS=""
    local ACTION=""
    
    # Fonction pour afficher le header
    show_header() {
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                    NETMAN - Network Manager                    ║"
        echo "║                     Gestionnaire Réseau ZSH                    ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo
    }
    
    # Fonction pour afficher les ports en écoute avec interface interactive
    # DESC: Gère les ports réseau de manière interactive (liste, kill, monitoring)
    # USAGE: manage_ports
    # EXAMPLE: manage_ports
    manage_ports() {
        local SELECTED_ITEMS=""
        while true; do
            show_header
            echo -e "${YELLOW}📡 Ports en écoute sur le système${RESET}"
            echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
            
            # Récupération des ports avec sudo si disponible
            local PORTS_DATA
            if command -v sudo &> /dev/null; then
                PORTS_DATA=$(sudo lsof -i -P -n 2>/dev/null | grep LISTEN | sort -t: -k2 -n)
            else
                PORTS_DATA=$(lsof -i -P -n 2>/dev/null | grep LISTEN | sort -t: -k2 -n)
            fi
            
            if [[ -z "$PORTS_DATA" ]]; then
                echo -e "${RED}❌ Aucun port en écoute trouvé.${RESET}"
                echo
                read -k 1 "?Appuyez sur une touche pour revenir au menu..."
                return
            fi
            
            # Affichage formaté
            printf "${CYAN}%-5s %-10s %-20s %-10s %-15s %-25s %s${RESET}\n" \
                   "N°" "PORT" "COMMANDE" "PID" "USER" "ADRESSE" "STATUS"
            echo "────────────────────────────────────────────────────────────────────────────────"
            
            local port_array=()
            local i=1
            
            while IFS= read -r line; do
                port_array+=("$line")
                local CMD=$(echo "$line" | awk '{print $1}')
                local PID=$(echo "$line" | awk '{print $2}')
                local USER=$(echo "$line" | awk '{print $3}')
                local ADDR=$(echo "$line" | awk '{print $9}')
                local PORT=$(echo "$ADDR" | sed 's/.*://')
                
                # Vérifier si l'item est sélectionné
                local STATUS="[ ]"
                if [[ " $SELECTED_ITEMS " =~ " $i " ]]; then
                    STATUS="${GREEN}[✓]${RESET}"
                fi
                
                printf "%-5d %-10s %-20.20s %-10s %-15s %-25.25s %s\n" \
                       "$i" "$PORT" "$CMD" "$PID" "$USER" "$ADDR" "$STATUS"
                ((i++))
            done <<< "$PORTS_DATA"
            
            echo
            echo -e "${YELLOW}────────────────────────────────────────────────────────────────────${RESET}"
            echo -e "${GREEN}Actions disponibles:${RESET}"
            echo "  [1-9] Sélectionner/Désélectionner un port"
            echo "  [k]   Kill les processus sélectionnés"
            echo "  [i]   Informations détaillées sur les ports sélectionnés"
            echo "  [a]   Sélectionner tous les ports"
            echo "  [n]   Désélectionner tout"
            echo "  [r]   Rafraîchir la liste"
            echo "  [q]   Retour au menu principal"
            echo
            read -k 1 "action?Votre choix: "
            echo
            
            case "$action" in
                [0-9])
                    if [[ " $SELECTED_ITEMS " =~ " $action " ]]; then
                        SELECTED_ITEMS=${SELECTED_ITEMS// $action /}
                    else
                        SELECTED_ITEMS="$SELECTED_ITEMS $action "
                    fi
                    ;;
                k|K)
                    if [[ -z "$SELECTED_ITEMS" ]]; then
                        echo -e "${RED}⚠️  Aucun port sélectionné${RESET}"
                        sleep 2
                    else
                        echo -e "${YELLOW}⚠️  Confirmation requise${RESET}"
                        echo "Ports sélectionnés pour termination:"
                        for num in $SELECTED_ITEMS; do
                            local line="${port_array[$((num-1))]}"
                            local PID=$(echo "$line" | awk '{print $2}')
                            local CMD=$(echo "$line" | awk '{print $1}')
                            local PORT=$(echo "$line" | awk '{print $9}' | sed 's/.*://')
                            echo "  • Port $PORT - $CMD (PID: $PID)"
                        done
                        echo
                        read -k 1 "confirm?Confirmer la termination? [y/N]: "
                        echo
                        if [[ "$confirm" =~ ^[Yy]$ ]]; then
                            for num in $SELECTED_ITEMS; do
                                local line="${port_array[$((num-1))]}"
                                local PID=$(echo "$line" | awk '{print $2}')
                                local CMD=$(echo "$line" | awk '{print $1}')
                                local PORT=$(echo "$line" | awk '{print $9}' | sed 's/.*://')
                                echo -n "Termination de $CMD sur port $PORT (PID: $PID)... "
                                if command -v sudo &> /dev/null; then
                                    sudo kill -TERM "$PID" 2>/dev/null && echo -e "${GREEN}✓${RESET}" || echo -e "${RED}✗${RESET}"
                                else
                                    kill -TERM "$PID" 2>/dev/null && echo -e "${GREEN}✓${RESET}" || echo -e "${RED}✗${RESET}"
                                fi
                            done
                            SELECTED_ITEMS=""
                            sleep 2
                        fi
                    fi
                    ;;
                i|I)
                    if [[ -z "$SELECTED_ITEMS" ]]; then
                        echo -e "${RED}⚠️  Aucun port sélectionné${RESET}"
                        sleep 2
                    else
                        show_header
                        echo -e "${CYAN}📋 Informations détaillées${RESET}"
                        echo "════════════════════════════════════════"
                        for num in $SELECTED_ITEMS; do
                            local line="${port_array[$((num-1))]}"
                            local PID=$(echo "$line" | awk '{print $2}')
                            local PORT=$(echo "$line" | awk '{print $9}' | sed 's/.*://')
                            echo -e "${YELLOW}Port $PORT:${RESET}"
                            if command -v sudo &> /dev/null; then
                                sudo lsof -i :$PORT 2>/dev/null | sed 's/^/  /'
                                echo
                                echo "Connexions actives:"
                                sudo ss -tnp | grep ":$PORT" | sed 's/^/  /'
                            else
                                lsof -i :$PORT 2>/dev/null | sed 's/^/  /'
                                echo
                                echo "Connexions actives:"
                                ss -tn | grep ":$PORT" | sed 's/^/  /'
                            fi
                            echo "────────────────────────────────"
                        done
                        echo
                        read -k 1 "?Appuyez sur une touche pour continuer..."
                    fi
                    ;;
                a|A)
                    SELECTED_ITEMS=""
                    for ((j=1; j<i; j++)); do
                        SELECTED_ITEMS="$SELECTED_ITEMS $j "
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
    # DESC: Affiche les connexions réseau actives
    # USAGE: show_connections
    # EXAMPLE: show_connections
    show_connections() {
        show_header
        echo -e "${YELLOW}🔗 Connexions réseau actives${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        echo -e "\n${CYAN}Connexions établies (ESTABLISHED):${RESET}"
        if command -v ss &> /dev/null; then
            ss -tunap 2>/dev/null | grep ESTAB | \
            awk '{printf "%-6s %-25s %-25s %-15s\n", $1, $5, $6, $NF}' | \
            sed 's/users:((/PID: /g; s/,fd=.*//g; s/))//g'
        else
            netstat -tunap 2>/dev/null | grep ESTABLISHED
        fi
        
        echo -e "\n${CYAN}Connexions en attente (TIME_WAIT/CLOSE_WAIT):${RESET}"
        if command -v ss &> /dev/null; then
            ss -tunap 2>/dev/null | grep -E "TIME-WAIT|CLOSE-WAIT" | \
            awk '{printf "%-6s %-25s %-25s %-15s\n", $1, $5, $6, $2}'
        fi
        
        echo -e "\n${CYAN}Statistiques par protocole:${RESET}"
        local tcp_count=$(ss -t 2>/dev/null | wc -l)
        local udp_count=$(ss -u 2>/dev/null | wc -l)
        echo "  TCP: $tcp_count connexions"
        echo "  UDP: $udp_count connexions"
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Fonction pour afficher les informations IP
    # DESC: Affiche les informations IP du système
    # USAGE: show_ip_info
    # EXAMPLE: show_ip_info
    show_ip_info() {
        show_header
        echo -e "${YELLOW}🌐 Informations IP${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        # IP Publique
        echo -e "\n${CYAN}Adresse IP Publique:${RESET}"
        local public_ip=$(curl -s https://ipinfo.io/ip 2>/dev/null || echo "Non disponible")
        echo "  $public_ip"
        
        if [[ "$public_ip" != "Non disponible" ]]; then
            echo -e "\n${CYAN}Informations de géolocalisation:${RESET}"
            curl -s https://ipinfo.io 2>/dev/null | grep -E '"(city|region|country|org)"' | \
            sed 's/[",]//g; s/^/  /'
        fi
        
        # IPs Locales
        echo -e "\n${CYAN}Adresses IP Locales:${RESET}"
        ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+' | \
        while read ip; do
            local iface=$(ip -4 addr show | grep -B2 "$ip" | head -1 | awk -F: '{print $2}')
            printf "  %-15s %s\n" "$iface:" "$ip"
        done
        
        # IPv6
        echo -e "\n${CYAN}Adresses IPv6:${RESET}"
        ip -6 addr show | grep -oP '(?<=inet6\s)[\da-f:]+/\d+' | grep -v "^fe80" | \
        while read ip; do
            local iface=$(ip -6 addr show | grep -B2 "$ip" | head -1 | awk -F: '{print $2}')
            printf "  %-15s %s\n" "$iface:" "$ip"
        done
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Fonction pour afficher les informations DNS
    # DESC: Affiche la configuration DNS
    # USAGE: show_dns_info
    # EXAMPLE: show_dns_info
    show_dns_info() {
        show_header
        echo -e "${YELLOW}🔍 Configuration DNS${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        echo -e "\n${CYAN}Serveurs DNS configurés:${RESET}"
        if [[ -f /etc/resolv.conf ]]; then
            grep "nameserver" /etc/resolv.conf | awk '{printf "  • %s\n", $2}'
        fi
        
        echo -e "\n${CYAN}Domaine de recherche:${RESET}"
        grep "search\|domain" /etc/resolv.conf 2>/dev/null | sed 's/^/  /'
        
        echo -e "\n${CYAN}Test de résolution DNS:${RESET}"
        echo -n "  google.com: "
        dig +short google.com @8.8.8.8 2>/dev/null | head -1 || echo "Échec"
        echo -n "  cloudflare.com: "
        dig +short cloudflare.com @1.1.1.1 2>/dev/null | head -1 || echo "Échec"
        
        echo -e "\n${CYAN}Cache DNS local:${RESET}"
        if command -v systemd-resolve &> /dev/null; then
            systemd-resolve --statistics 2>/dev/null | grep -E "Current Cache|Cache Hits" | sed 's/^/  /'
        else
            echo "  Pas de cache systemd-resolved détecté"
        fi
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Fonction pour afficher la table de routage
    show_routing() {
        show_header
        echo -e "${YELLOW}🛣️  Table de routage${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        echo -e "\n${CYAN}Routes IPv4:${RESET}"
        ip -4 route show | while read line; do
            if [[ "$line" =~ "default" ]]; then
                echo -e "  ${GREEN}$line${RESET}"
            else
                echo "  $line"
            fi
        done
        
        echo -e "\n${CYAN}Routes IPv6:${RESET}"
        ip -6 route show 2>/dev/null | head -10 | sed 's/^/  /'
        
        echo -e "\n${CYAN}Passerelle par défaut:${RESET}"
        ip route | grep default | awk '{print "  " $3 " via " $5}'
        
        echo -e "\n${CYAN}Métriques des interfaces:${RESET}"
        ip -s link | awk '/^[0-9]+:/ {iface=$2} /RX:/ {getline; rx=$1} /TX:/ {getline; tx=$1; printf "  %-15s RX: %-15s TX: %-15s\n", iface, rx, tx}'
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Fonction pour afficher les interfaces réseau
    # DESC: Affiche les interfaces réseau disponibles
    # USAGE: show_interfaces
    # EXAMPLE: show_interfaces
    show_interfaces() {
        show_header
        echo -e "${YELLOW}🖧  Interfaces réseau${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        local interfaces=$(ip -o link show | awk -F': ' '{print $2}')
        
        for iface in $interfaces; do
            echo -e "\n${CYAN}Interface: $iface${RESET}"
            echo "─────────────────────────"
            
            # État de l'interface
            local state=$(ip link show "$iface" | grep -oP '(?<=state )\w+')
            if [[ "$state" == "UP" ]]; then
                echo -e "  État: ${GREEN}$state${RESET}"
            else
                echo -e "  État: ${RED}$state${RESET}"
            fi
            
            # Adresse MAC
            local mac=$(ip link show "$iface" | grep -oP '(?<=link/ether )[\da-f:]+' || echo "N/A")
            echo "  MAC: $mac"
            
            # Adresses IP
            echo "  IPv4:"
            ip -4 addr show "$iface" 2>/dev/null | grep inet | awk '{print "    " $2}'
            echo "  IPv6:"
            ip -6 addr show "$iface" 2>/dev/null | grep inet6 | awk '{print "    " $2}'
            
            # Statistiques
            local stats=$(ip -s link show "$iface" 2>/dev/null)
            local rx_bytes=$(echo "$stats" | awk '/RX:/{getline; print $1}')
            local tx_bytes=$(echo "$stats" | awk '/TX:/{getline; print $1}')
            
            if [[ -n "$rx_bytes" ]]; then
                echo "  Statistiques:"
                echo "    RX: $(numfmt --to=iec-i --suffix=B $rx_bytes 2>/dev/null || echo $rx_bytes)"
                echo "    TX: $(numfmt --to=iec-i --suffix=B $tx_bytes 2>/dev/null || echo $tx_bytes)"
            fi
        done
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Fonction pour scanner un port spécifique
    scan_port() {
        show_header
        echo -e "${YELLOW}🔍 Scanner de port${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo
        
        read "host?Entrez l'hôte à scanner (défaut: localhost): "
        host=${host:-localhost}
        
        read "port?Entrez le port ou la plage de ports (ex: 80 ou 80-443): "
        
        if [[ "$port" =~ ^[0-9]+$ ]]; then
            # Port unique
            echo -e "\n${CYAN}Test du port $port sur $host...${RESET}"
            if timeout 2 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
                echo -e "  Port $port: ${GREEN}OUVERT${RESET}"
                # Essayer de déterminer le service
                local service=$(grep -E "^[^#]*\s$port/" /etc/services 2>/dev/null | head -1 | awk '{print $1}')
                [[ -n "$service" ]] && echo "  Service probable: $service"
            else
                echo -e "  Port $port: ${RED}FERMÉ${RESET}"
            fi
        elif [[ "$port" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            # Plage de ports
            local start_port="${match[1]}"
            local end_port="${match[2]}"
            echo -e "\n${CYAN}Scan des ports $start_port à $end_port sur $host...${RESET}"
            echo "Ports ouverts:"
            for ((p=start_port; p<=end_port; p++)); do
                if timeout 0.5 bash -c "echo >/dev/tcp/$host/$p" 2>/dev/null; then
                    local service=$(grep -E "^[^#]*\s$p/" /etc/services 2>/dev/null | head -1 | awk '{print $1}')
                    if [[ -n "$service" ]]; then
                        echo -e "  Port $p: ${GREEN}OUVERT${RESET} ($service)"
                    else
                        echo -e "  Port $p: ${GREEN}OUVERT${RESET}"
                    fi
                fi
            done
        else
            echo -e "${RED}Format de port invalide${RESET}"
        fi
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Fonction pour kill un port spécifique
    # DESC: Tue rapidement un processus sur un port spécifique
    # USAGE: kill_port_quick <port>
    # EXAMPLE: kill_port_quick 8080
    kill_port_quick() {
        show_header
        echo -e "${YELLOW}💀 Kill rapide de port${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo
        
        read "port?Entrez le numéro du port à libérer: "
        
        if [[ ! "$port" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}❌ Port invalide${RESET}"
            sleep 2
            return
        fi
        
        echo -e "\n${CYAN}Recherche des processus sur le port $port...${RESET}"
        
        local procs
        if command -v sudo &> /dev/null; then
            procs=$(sudo lsof -i :$port 2>/dev/null | grep LISTEN)
        else
            procs=$(lsof -i :$port 2>/dev/null | grep LISTEN)
        fi
        
        if [[ -z "$procs" ]]; then
            echo -e "${GREEN}✓ Aucun processus trouvé sur le port $port${RESET}"
        else
            echo "Processus trouvés:"
            echo "$procs" | while read line; do
                local cmd=$(echo "$line" | awk '{print $1}')
                local pid=$(echo "$line" | awk '{print $2}')
                local user=$(echo "$line" | awk '{print $3}')
                echo "  • $cmd (PID: $pid, User: $user)"
            done
            
            echo
            read -k 1 "confirm?Voulez-vous tuer ces processus? [y/N]: "
            echo
            
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                echo "$procs" | awk '{print $2}' | while read pid; do
                    echo -n "Termination du PID $pid... "
                    if command -v sudo &> /dev/null; then
                        sudo kill -TERM "$pid" 2>/dev/null && echo -e "${GREEN}✓${RESET}" || echo -e "${RED}✗${RESET}"
                    else
                        kill -TERM "$pid" 2>/dev/null && echo -e "${GREEN}✓${RESET}" || echo -e "${RED}✗${RESET}"
                    fi
                done
            fi
        fi
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Fonction pour afficher les statistiques réseau
    show_network_stats() {
        show_header
        echo -e "${YELLOW}📊 Statistiques réseau${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        echo -e "\n${CYAN}Statistiques globales:${RESET}"
        if command -v netstat &> /dev/null; then
            netstat -s 2>/dev/null | grep -E "active connection|passive connection|failed connection|segments sent|segments received" | sed 's/^/  /'
        fi
        
        echo -e "\n${CYAN}Top 10 des connexions par IP:${RESET}"
        ss -tn 2>/dev/null | awk 'NR>1 {print $5}' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | \
        sort | uniq -c | sort -rn | head -10 | \
        awk '{printf "  %3d connexions: %s\n", $1, $2}'
        
        echo -e "\n${CYAN}Utilisation de la bande passante (temps réel):${RESET}"
        echo "  Appuyez sur 'q' pour quitter la surveillance..."
        echo
        
        # Surveillance en temps réel pendant 5 secondes
        local count=0
        while [[ $count -lt 5 ]]; do
            local rx_bytes=$(cat /sys/class/net/*/statistics/rx_bytes 2>/dev/null | awk '{sum+=$1} END {print sum}')
            local tx_bytes=$(cat /sys/class/net/*/statistics/tx_bytes 2>/dev/null | awk '{sum+=$1} END {print sum}')
            sleep 1
            local rx_bytes_new=$(cat /sys/class/net/*/statistics/rx_bytes 2>/dev/null | awk '{sum+=$1} END {print sum}')
            local tx_bytes_new=$(cat /sys/class/net/*/statistics/tx_bytes 2>/dev/null | awk '{sum+=$1} END {print sum}')
            
            local rx_rate=$((rx_bytes_new - rx_bytes))
            local tx_rate=$((tx_bytes_new - tx_bytes))
            
            printf "\r  ↓ RX: %s/s  ↑ TX: %s/s  " \
                   "$(numfmt --to=iec-i --suffix=B $rx_rate 2>/dev/null || echo $rx_rate)" \
                   "$(numfmt --to=iec-i --suffix=B $tx_rate 2>/dev/null || echo $tx_rate)"
            
            ((count++))
        done
        
        echo -e "\n"
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Fonction pour exporter la configuration réseau
    export_network_config() {
        show_header
        echo -e "${YELLOW}💾 Export de la configuration réseau${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local export_file="$HOME/network_config_$timestamp.txt"
        
        {
            echo "=== Configuration Réseau - Export du $(date) ==="
            echo
            echo "=== INTERFACES ==="
            ip addr show
            echo
            echo "=== ROUTES ==="
            ip route show
            echo
            echo "=== DNS ==="
            cat /etc/resolv.conf
            echo
            echo "=== PORTS EN ÉCOUTE ==="
            if command -v sudo &> /dev/null; then
                sudo lsof -i -P -n | grep LISTEN
            else
                lsof -i -P -n | grep LISTEN
            fi
            echo
            echo "=== CONNEXIONS ACTIVES ==="
            ss -tunap
            echo
            echo "=== FIREWALL (iptables) ==="
            if command -v sudo &> /dev/null; then
                sudo iptables -L -n -v 2>/dev/null || echo "iptables non disponible"
            fi
        } > "$export_file"
        
        echo -e "${GREEN}✓ Configuration exportée vers: $export_file${RESET}"
        echo
        echo "Contenu du fichier:"
        echo "─────────────────────"
        head -20 "$export_file"
        echo "..."
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Menu principal
    while true; do
        show_header
        echo -e "${GREEN}Menu Principal${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo
        echo "  ${BOLD}1${RESET}  📡 Gérer les ports en écoute (interactif)"
        echo "  ${BOLD}2${RESET}  🔗 Afficher les connexions actives"
        echo "  ${BOLD}3${RESET}  🌐 Informations IP (publique/locale)"
        echo "  ${BOLD}4${RESET}  🔍 Configuration DNS"
        echo "  ${BOLD}5${RESET}  🛣️  Table de routage"
        echo "  ${BOLD}6${RESET}  🖧  Interfaces réseau"
        echo "  ${BOLD}7${RESET}  🔍 Scanner un port spécifique"
        echo "  ${BOLD}8${RESET}  💀 Kill rapide d'un port"
        echo "  ${BOLD}9${RESET}  📊 Statistiques réseau"
        echo "  ${BOLD}0${RESET}  💾 Exporter la configuration"
        echo
        echo "  ${BOLD}h${RESET}  📚 Aide"
        echo "  ${BOLD}q${RESET}  🚪 Quitter"
        echo
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        read -k 1 "choice?Votre choix: "
        echo
        
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
            0) export_network_config ;;
            h|H)
                show_header
                echo -e "${CYAN}📚 Aide - NETMAN${RESET}"
                echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
                echo
                echo "NETMAN est un gestionnaire réseau complet pour ZSH."
                echo
                echo "Fonctionnalités principales:"
                echo "  • Gestion interactive des ports avec sélection multiple"
                echo "  • Visualisation des connexions réseau en temps réel"
                echo "  • Informations IP publiques et locales"
                echo "  • Configuration et test DNS"
                echo "  • Table de routage et métriques"
                echo "  • Scan de ports sur hosts locaux ou distants"
                echo "  • Kill rapide de processus par port"
                echo "  • Statistiques réseau détaillées"
                echo "  • Export de configuration complète"
                echo
                echo "Raccourcis:"
                echo "  netman              - Lance le gestionnaire"
                echo "  netman ports        - Accès direct aux ports"
                echo "  netman kill <port>  - Kill rapide d'un port"
                echo "  netman scan <host>  - Scan rapide d'un host"
                echo "  netman stats        - Statistiques directes"
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            q|Q)
                echo -e "${GREEN}Au revoir!${RESET}"
                break
                ;;
            *)
                echo -e "${RED}Option invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

# Alias et raccourcis
alias nm='netman'
alias ports='netman ports'
alias netstat-ports='netman ports'
alias kill-port='netman kill'

# Fonction pour accès direct aux sous-commandes
if [[ "$1" == "ports" ]]; then
    netman
    manage_ports
elif [[ "$1" == "kill" && -n "$2" ]]; then
    port="$2"
    echo "Kill rapide du port $port..."
    if command -v sudo &> /dev/null; then
        pids=$(sudo lsof -t -i:$port 2>/dev/null)
    else
        pids=$(lsof -t -i:$port 2>/dev/null)
    fi
    
    if [[ -n "$pids" ]]; then
        echo "PIDs trouvés: $pids"
        for pid in $pids; do
            if command -v sudo &> /dev/null; then
                sudo kill -TERM $pid && echo "✓ PID $pid terminé"
            else
                kill -TERM $pid && echo "✓ PID $pid terminé"
            fi
        done
    else
        echo "Aucun processus sur le port $port"
    fi
elif [[ "$1" == "scan" && -n "$2" ]]; then
    host="$2"
    port="${3:-80}"
    echo "Scan du port $port sur $host..."
    timeout 2 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null && \
        echo "✓ Port $port OUVERT" || echo "✗ Port $port FERMÉ"
elif [[ "$1" == "stats" ]]; then
    netman
    show_network_stats
fi

# Message d'initialisation
echo "🚀 NETMAN chargé - Tapez 'netman' ou 'nm' pour démarrer"
