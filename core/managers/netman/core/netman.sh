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
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    if [ -f "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh"
    fi
    
    # Variables globales pour la fonction
    SELECTED_PORTS=""
    ACTION=""
    pause_if_tty() {
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée pour continuer... "
            read dummy
        fi
    }

    netman_fzf_pick_line() {
        _prompt="$1"
        if [ -t 0 ] && [ -t 1 ] && command -v fzf >/dev/null 2>&1; then
            fzf --height=85% --layout=reverse --border --ansi \
                --prompt="$_prompt > " \
                --preview='echo "{}"' --preview-window=down,35%:wrap
        else
            return 1
        fi
    }

    # Aide courte (stdout) — netman help | -h et option « h » du menu
    netman_print_quick_help() {
        printf "${CYAN}NETMAN — raccourcis${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo ""
        echo "Sous-commandes :"
        echo "  netman ports              Ports en écoute (ou menu dédié)"
        echo "  netman connections        Connexions actives"
        echo "  netman ip | dns | routing | interfaces"
        echo "  netman routeman           Gestionnaire de routes"
        echo "  netman scan <host> [port]   Test port TCP rapide"
        echo "  netman kill <port>       Kill processus sur port"
        echo "  netman stats             Statistiques"
        echo "  netman diagnose | diag-report | diagnose-deep"
        echo "  netman dns-bench [opts]  Benchmark DNS"
        echo "  netman firewall          ufw / nft / iptables"
        echo "  netman lookup <cible>    DNS + extrait whois"
        echo "  netman trace <hôte>      traceroute (ou tracepath)"
        echo "  netman mtr <hôte>        diagnostic route/latence (si mtr installé)"
        echo "  netman whois <cible>     whois détaillé"
        echo "  netman connectivity | speed | monitor | analyze | export"
        echo ""
        echo "Interface :"
        echo "  netman / netman --help    menu (avec --help : aide puis Entrée)"
        echo "  netman -h, netman help    cette page (stdout)"
        echo ""
    }
    
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
                if [ -t 0 ] && [ -t 1 ]; then
                    printf "Appuyez sur Entrée pour revenir au menu... "
                    read dummy
                fi
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
                        pause_if_tty
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
        _conn_rows=""
        if command -v ss >/dev/null 2>&1; then
            _conn_rows=$(ss -tunap 2>/dev/null | grep ESTAB | \
            awk '{printf "%-6s %-25s %-25s %-15s\n", $1, $5, $6, $NF}' | \
            sed 's/users:((/PID: /g; s/,fd=.*//g; s/))//g')
        else
            _conn_rows=$(netstat -tunap 2>/dev/null | grep ESTABLISHED)
        fi
        if [ -n "$_conn_rows" ]; then
            if _picked_conn=$(printf '%s\n' "$_conn_rows" | netman_fzf_pick_line "Connexions ESTAB"); then
                printf "%s\n" "$_picked_conn"
            else
                printf '%s\n' "$_conn_rows"
            fi
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
        pause_if_tty
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
        pause_if_tty
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
        pause_if_tty
    }

    # Diagnostic réseau complet (couche locale -> internet -> DNS -> HTTP)
    network_diagnose() {
        show_header
        printf "${YELLOW}🩺 Diagnostic réseau complet${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"

        default_iface=$(ip route 2>/dev/null | awk '/default/ {print $5; exit}')
        default_gw=$(ip route 2>/dev/null | awk '/default/ {print $3; exit}')

        printf "\n${CYAN}1) Interface / lien local${RESET}\n"
        if [ -n "$default_iface" ]; then
            iface_state=$(ip link show "$default_iface" 2>/dev/null | grep -o 'state [A-Z]*' | awk '{print $2}')
            printf "  Interface par defaut: %s\n" "$default_iface"
            printf "  Etat: %s\n" "${iface_state:-UNKNOWN}"
            ip -4 addr show "$default_iface" 2>/dev/null | awk '/inet / {print "  IPv4: " $2}'
        else
            printf "  ${RED}✗ Pas d'interface par defaut detectee${RESET}\n"
        fi

        printf "\n${CYAN}2) Passerelle${RESET}\n"
        if [ -n "$default_gw" ]; then
            printf "  Gateway: %s\n" "$default_gw"
            if ping -c 1 -W 1 "$default_gw" >/dev/null 2>&1; then
                printf "  ${GREEN}✓ Gateway joignable${RESET}\n"
            else
                printf "  ${RED}✗ Gateway non joignable${RESET}\n"
            fi
        else
            printf "  ${RED}✗ Pas de route par defaut${RESET}\n"
        fi

        printf "\n${CYAN}3) Connectivite IP externe${RESET}\n"
        if ping -c 1 -W 1 1.1.1.1 >/dev/null 2>&1; then
            printf "  ${GREEN}✓ Ping 1.1.1.1 OK${RESET}\n"
        else
            printf "  ${RED}✗ Ping 1.1.1.1 KO${RESET}\n"
        fi
        if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
            printf "  ${GREEN}✓ Ping 8.8.8.8 OK${RESET}\n"
        else
            printf "  ${RED}✗ Ping 8.8.8.8 KO${RESET}\n"
        fi

        printf "\n${CYAN}4) Resolution DNS${RESET}\n"
        if command -v dig >/dev/null 2>&1; then
            dns_ip=$(dig +short google.com @1.1.1.1 2>/dev/null | head -1)
            if [ -n "$dns_ip" ]; then
                printf "  ${GREEN}✓ DNS OK${RESET} (google.com -> %s)\n" "$dns_ip"
            else
                printf "  ${RED}✗ DNS KO${RESET}\n"
            fi
        else
            if getent hosts google.com >/dev/null 2>&1; then
                printf "  ${GREEN}✓ DNS OK (getent)${RESET}\n"
            else
                printf "  ${RED}✗ DNS KO${RESET}\n"
            fi
        fi

        printf "\n${CYAN}5) Sortie HTTP/HTTPS${RESET}\n"
        if command -v curl >/dev/null 2>&1; then
            http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 https://example.com 2>/dev/null)
            if [ "$http_code" = "200" ] || [ "$http_code" = "301" ] || [ "$http_code" = "302" ]; then
                printf "  ${GREEN}✓ HTTPS OK${RESET} (code %s)\n" "$http_code"
            else
                printf "  ${YELLOW}⚠ HTTPS incertain${RESET} (code %s)\n" "${http_code:-N/A}"
            fi
        else
            printf "  ${YELLOW}⚠ curl non installe${RESET}\n"
        fi

        echo ""
        pause_if_tty
    }

    # Rapport de diagnostic exportable (non interactif)
    network_diagnose_report() {
        ts=$(date +%Y%m%d_%H%M%S)
        report_file="${2:-$HOME/netman_diag_${ts}.txt}"
        {
            echo "=== NETMAN DIAG REPORT $(date) ==="
            echo ""
            echo "[ROUTES]"
            ip route 2>/dev/null
            echo ""
            echo "[INTERFACES]"
            ip -br addr 2>/dev/null
            echo ""
            echo "[PING GW]"
            gw=$(ip route 2>/dev/null | awk '/default/ {print $3; exit}')
            [ -n "$gw" ] && ping -c 1 -W 1 "$gw" 2>/dev/null || echo "gateway-unavailable"
            echo ""
            echo "[PING INTERNET]"
            ping -c 1 -W 1 1.1.1.1 2>/dev/null || true
            ping -c 1 -W 1 8.8.8.8 2>/dev/null || true
            echo ""
            echo "[DNS]"
            if command -v dig >/dev/null 2>&1; then
                dig +short google.com @1.1.1.1 2>/dev/null
            else
                getent hosts google.com 2>/dev/null
            fi
            echo ""
            echo "[HTTPS]"
            if command -v curl >/dev/null 2>&1; then
                curl -s -o /dev/null -w "http_code=%{http_code} connect=%{time_connect} ttfb=%{time_starttransfer}\n" --max-time 8 https://example.com 2>/dev/null
            fi
            echo ""
            echo "[SOCKETS TOP]"
            ss -tnp 2>/dev/null | head -40
        } > "$report_file"
        printf "${GREEN}✓ Rapport créé: %s${RESET}\n" "$report_file"
    }

    # Benchmark rapide DNS
    dns_benchmark() {
        show_header
        printf "${YELLOW}⚡ Benchmark DNS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"

        test_domain="google.com"
        [ -n "$1" ] && test_domain="$1"
        printf "Domaine de test: %s\n\n" "$test_domain"

        if ! command -v dig >/dev/null 2>&1; then
            printf "${RED}❌ dig non disponible (installez dnsutils/bind-tools)${RESET}\n"
            pause_if_tty
            return 1
        fi

        for resolver in 1.1.1.1 8.8.8.8 9.9.9.9; do
            ms=$(dig @"$resolver" "$test_domain" +stats +time=2 +tries=1 2>/dev/null | awk -F': ' '/Query time/ {print $2}' | awk '{print $1}')
            ip_result=$(dig +short @"$resolver" "$test_domain" +time=2 +tries=1 2>/dev/null | head -1)
            if [ -n "$ms" ]; then
                printf "  ${GREEN}%s${RESET} -> %4sms | %s\n" "$resolver" "$ms" "${ip_result:-no-answer}"
            else
                printf "  ${RED}%s${RESET} -> timeout/erreur\n" "$resolver"
            fi
        done

        echo ""
        pause_if_tty
    }

    # Diagnostic approfondi orienté incident perf (RX/TX, erreurs, drops, top talkers)
    network_diagnose_deep() {
        show_header
        printf "${YELLOW}🧪 Diagnostic réseau approfondi${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"

        active_if=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
        [ -z "$active_if" ] && active_if="wlan0"

        printf "\n${CYAN}Interface active detectee:${RESET} %s\n" "$active_if"

        # Snapshot 1
        rx1=$(cat "/sys/class/net/$active_if/statistics/rx_bytes" 2>/dev/null || echo 0)
        tx1=$(cat "/sys/class/net/$active_if/statistics/tx_bytes" 2>/dev/null || echo 0)
        rxe1=$(cat "/sys/class/net/$active_if/statistics/rx_errors" 2>/dev/null || echo 0)
        txe1=$(cat "/sys/class/net/$active_if/statistics/tx_errors" 2>/dev/null || echo 0)
        rxd1=$(cat "/sys/class/net/$active_if/statistics/rx_dropped" 2>/dev/null || echo 0)
        txd1=$(cat "/sys/class/net/$active_if/statistics/tx_dropped" 2>/dev/null || echo 0)

        printf "${CYAN}Mesure debit instantane sur 3s...${RESET}\n"
        sleep 3

        # Snapshot 2
        rx2=$(cat "/sys/class/net/$active_if/statistics/rx_bytes" 2>/dev/null || echo 0)
        tx2=$(cat "/sys/class/net/$active_if/statistics/tx_bytes" 2>/dev/null || echo 0)
        rxe2=$(cat "/sys/class/net/$active_if/statistics/rx_errors" 2>/dev/null || echo 0)
        txe2=$(cat "/sys/class/net/$active_if/statistics/tx_errors" 2>/dev/null || echo 0)
        rxd2=$(cat "/sys/class/net/$active_if/statistics/rx_dropped" 2>/dev/null || echo 0)
        txd2=$(cat "/sys/class/net/$active_if/statistics/tx_dropped" 2>/dev/null || echo 0)

        rx_rate=$(( (rx2 - rx1) / 3 ))
        tx_rate=$(( (tx2 - tx1) / 3 ))
        rx_h=$(numfmt --to=iec-i --suffix=B/s "$rx_rate" 2>/dev/null || echo "${rx_rate}B/s")
        tx_h=$(numfmt --to=iec-i --suffix=B/s "$tx_rate" 2>/dev/null || echo "${tx_rate}B/s")

        printf "\n${CYAN}Debit instantane (%s):${RESET}\n" "$active_if"
        printf "  RX: %s\n" "$rx_h"
        printf "  TX: %s\n" "$tx_h"

        drx_err=$((rxe2 - rxe1))
        dtx_err=$((txe2 - txe1))
        drx_drop=$((rxd2 - rxd1))
        dtx_drop=$((txd2 - txd1))
        printf "\n${CYAN}Compteurs erreurs/drops (delta 3s):${RESET}\n"
        printf "  rx_errors=%s tx_errors=%s rx_dropped=%s tx_dropped=%s\n" "$drx_err" "$dtx_err" "$drx_drop" "$dtx_drop"

        printf "\n${CYAN}Top processus reseau (ss):${RESET}\n"
        if command -v ss >/dev/null 2>&1; then
            ss -tpn 2>/dev/null | awk 'NR>1 {print $0}' | head -20 | sed 's/^/  /'
        else
            echo "  ss indisponible"
        fi

        printf "\n${CYAN}Interfaces qui consomment le plus (compteurs totaux):${RESET}\n"
        for i in /sys/class/net/*; do
            iface=$(basename "$i")
            [ "$iface" = "lo" ] && continue
            rb=$(cat "$i/statistics/rx_bytes" 2>/dev/null || echo 0)
            tb=$(cat "$i/statistics/tx_bytes" 2>/dev/null || echo 0)
            echo "$iface $rb $tb"
        done | sort -k2,2nr | head -8 | awk '{printf "  %-16s RX=%s TX=%s\n",$1,$2,$3}'

        printf "\n${CYAN}Interprétation rapide:${RESET}\n"
        if [ "$drx_err" -gt 0 ] || [ "$dtx_err" -gt 0 ] || [ "$drx_drop" -gt 0 ] || [ "$dtx_drop" -gt 0 ]; then
            printf "  ${YELLOW}⚠ Erreurs/drops detectes pendant la mesure${RESET}\n"
        else
            printf "  ${GREEN}✓ Pas d'erreurs/drops detectees sur la fenetre mesuree${RESET}\n"
        fi
        printf "  ${BLUE}ℹ Si RX/TX semble anormal, verifier surtout les interfaces docker/veth${RESET}\n"

        echo ""
        pause_if_tty
    }

    # Statut firewall synthétique (ufw / nftables / iptables)
    firewall_status() {
        show_header
        printf "${YELLOW}🛡️ Statut Firewall${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"

        if command -v ufw >/dev/null 2>&1; then
            printf "\n${CYAN}UFW:${RESET}\n"
            ufw status 2>/dev/null | sed 's/^/  /'
        fi

        if command -v nft >/dev/null 2>&1; then
            printf "\n${CYAN}nftables (resume):${RESET}\n"
            nft list ruleset 2>/dev/null | awk 'NR<=40 {print "  " $0} NR==41 {print "  ..."}'
        fi

        if command -v iptables >/dev/null 2>&1; then
            printf "\n${CYAN}iptables (policies):${RESET}\n"
            iptables -S 2>/dev/null | awk '/^-P / {print "  " $0}'
        fi

        if ! command -v ufw >/dev/null 2>&1 && ! command -v nft >/dev/null 2>&1 && ! command -v iptables >/dev/null 2>&1; then
            printf "${YELLOW}⚠ Aucun outil firewall detecte (ufw/nft/iptables)${RESET}\n"
        fi

        echo ""
        pause_if_tty
    }

    # Lookup IP/domaine (dig + whois + reverse DNS)
    network_lookup() {
        show_header
        printf "${YELLOW}🔎 Lookup réseau (IP / domaine)${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        printf "Cible (IP ou domaine): "
        read target

        if [ -z "$target" ]; then
            printf "${RED}❌ Cible vide${RESET}\n"
            sleep 1
            return 1
        fi

        printf "\n${CYAN}Resolution DNS:${RESET}\n"
        if command -v dig >/dev/null 2>&1; then
            dig +short "$target" 2>/dev/null | sed 's/^/  /'
        else
            getent hosts "$target" 2>/dev/null | sed 's/^/  /'
        fi

        printf "\n${CYAN}Reverse DNS:${RESET}\n"
        if command -v dig >/dev/null 2>&1; then
            dig +short -x "$target" 2>/dev/null | sed 's/^/  /'
        fi

        if command -v whois >/dev/null 2>&1; then
            printf "\n${CYAN}WHOIS (extrait):${RESET}\n"
            whois "$target" 2>/dev/null | awk 'NR<=25 {print "  " $0}'
        else
            printf "\n${YELLOW}⚠ whois non installe${RESET}\n"
        fi

        echo ""
        pause_if_tty
    }

    network_trace() {
        show_header
        printf "${YELLOW}🧭 Traceroute / Tracepath${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        _target="${1:-}"
        if [ -z "$_target" ]; then
            printf "Hôte ou IP cible: "
            read _target
        fi
        [ -z "$_target" ] && printf "${RED}❌ Cible vide${RESET}\n" && return 1
        if command -v traceroute >/dev/null 2>&1; then
            traceroute -n "$_target" 2>/dev/null | sed -n '1,40p'
        elif command -v tracepath >/dev/null 2>&1; then
            tracepath "$_target" 2>/dev/null | sed -n '1,40p'
        else
            printf "${YELLOW}⚠ traceroute/tracepath non installé${RESET}\n"
            return 1
        fi
        echo ""
        pause_if_tty
    }

    network_mtr() {
        show_header
        printf "${YELLOW}🧪 MTR (latence/pertes)${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        _target="${1:-}"
        if [ -z "$_target" ]; then
            printf "Hôte ou IP cible: "
            read _target
        fi
        [ -z "$_target" ] && printf "${RED}❌ Cible vide${RESET}\n" && return 1
        if command -v mtr >/dev/null 2>&1; then
            mtr -rw -c 8 "$_target" 2>/dev/null
        else
            printf "${YELLOW}⚠ mtr non installé${RESET}\n"
            return 1
        fi
        echo ""
        pause_if_tty
    }

    network_whois() {
        show_header
        printf "${YELLOW}📄 WHOIS détaillé${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        _target="${1:-}"
        if [ -z "$_target" ]; then
            printf "Domaine/IP cible: "
            read _target
        fi
        [ -z "$_target" ] && printf "${RED}❌ Cible vide${RESET}\n" && return 1
        if command -v whois >/dev/null 2>&1; then
            whois "$_target" 2>/dev/null | sed -n '1,120p'
        else
            printf "${YELLOW}⚠ whois non installé${RESET}\n"
            return 1
        fi
        echo ""
        pause_if_tty
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
        pause_if_tty
    }

    # Lancer le manager de routes dédié
    launch_routeman() {
        _routeman_core_path="${DOTFILES_DIR:-$HOME/dotfiles}/core/managers/routeman/core/routeman.sh"
        if command -v routeman >/dev/null 2>&1; then
            routeman
        elif [ -f "$_routeman_core_path" ]; then
            # shellcheck source=/dev/null
            . "$_routeman_core_path"
            if command -v routeman >/dev/null 2>&1; then
                routeman
            else
                printf "${RED}❌ routeman chargé mais commande indisponible${RESET}\n"
                sleep 2
            fi
        else
            printf "${RED}❌ ROUTEMAN non trouvé (%s)${RESET}\n" "$_routeman_core_path"
            sleep 2
        fi
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
        # Non bloquant hors TTY (tests Docker / CI / pipes)
        if [ -t 0 ] && [ -t 1 ]; then
            pause_if_tty
        fi
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
        pause_if_tty
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
        pause_if_tty
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
        pause_if_tty
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
        pause_if_tty
    }
    
    # Fonction pour tester la vitesse réseau
    test_network_speed() {
        show_header
        printf "${YELLOW}⚡ Test de vitesse réseau${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo ""

        # Paramètres (CLI): test_network_speed [taille]
        # Tailles supportées: 10M,100M,1G,5G
        size_arg="${1:-}"
        if [ -z "$size_arg" ] && [ -t 0 ] && [ -t 1 ]; then
            printf "Taille de test [10M/100M/1G/5G] (defaut: 5G): "
            read size_arg
        fi
        size_arg="${size_arg:-5G}"

        case "$size_arg" in
            10M|10m)
                label="10MB"
                test_urls="https://proof.ovh.net/files/10Mb.dat
https://speed.hetzner.de/10MB.bin"
                ;;
            100M|100m)
                label="100MB"
                test_urls="https://proof.ovh.net/files/100Mb.dat
https://speed.hetzner.de/100MB.bin"
                ;;
            1G|1g)
                label="1GB"
                test_urls="https://proof.ovh.net/files/1Gb.dat
https://speed.hetzner.de/1GB.bin"
                ;;
            5G|5g)
                label="5GB"
                test_urls="https://proof.ovh.net/files/5Gb.dat
https://speed.hetzner.de/5GB.bin"
                ;;
            *)
                printf "${YELLOW}⚠ Taille inconnue '%s', fallback 5G${RESET}\n" "$size_arg"
                label="5GB"
                test_urls="https://proof.ovh.net/files/5Gb.dat
https://speed.hetzner.de/5GB.bin"
                ;;
        esac

        if [ "$label" = "5GB" ] && [ -t 0 ] && [ -t 1 ]; then
            printf "${YELLOW}⚠ Ce test va telecharger 5GB reels.${RESET}\n"
            printf "Continuer ? [y/N]: "
            read confirm_speed
            case "$confirm_speed" in
                [yY]*) ;;
                *)
                    printf "${BLUE}Test annule.${RESET}\n"
                    return 0
                    ;;
            esac
        fi

        printf "${CYAN}Test de téléchargement (%s)...${RESET}\n" "$label"
        if ! command -v curl >/dev/null 2>&1; then
            printf "${RED}✗ curl non disponible${RESET}\n"
            return 1
        fi

        # Téléchargement réel vers /dev/null pour mesurer un débit crédible
        # Une seule passe: taille + durée via write-out curl.
        end_ok=1
        downloaded=0
        elapsed=0
        test_url=""
        echo "$test_urls" | while IFS= read -r candidate_url; do
            [ -z "$candidate_url" ] && continue
            curl_out=$(curl -L -s --output /dev/null -w "%{size_download} %{time_total}" "$candidate_url" 2>/dev/null)
            rc=$?
            dl=$(echo "$curl_out" | awk '{print $1}')
            tt=$(echo "$curl_out" | awk '{print $2}')
            if [ "$rc" -eq 0 ] && awk -v b="$dl" 'BEGIN { exit !(b+0 > 0) }'; then
                echo "$candidate_url|$dl|$tt"
                exit 0
            fi
        done > /tmp/netman_speed_result.$$ 2>/dev/null

        if [ -s /tmp/netman_speed_result.$$ ]; then
            end_ok=0
            test_url=$(cut -d'|' -f1 /tmp/netman_speed_result.$$)
            downloaded=$(cut -d'|' -f2 /tmp/netman_speed_result.$$)
            elapsed=$(cut -d'|' -f3 /tmp/netman_speed_result.$$)
        fi
        rm -f /tmp/netman_speed_result.$$ 2>/dev/null

        if [ "$end_ok" -eq 0 ] && [ "$downloaded" != "0" ]; then
            # conversion en Mbps
            if awk -v s="$elapsed" 'BEGIN { exit !(s+0 > 0) }'; then
                mbps=$(awk -v b="$downloaded" -v s="$elapsed" 'BEGIN { printf "%.2f", (b*8)/(s*1000000) }')
                mbytes=$(awk -v b="$downloaded" 'BEGIN { printf "%.2f", b/1048576 }')
                printf "${GREEN}✓ Download: %s MB transferes en %ss${RESET}\n" "$mbytes" "$elapsed"
                printf "${GREEN}✓ Vitesse moyenne: %s Mbps${RESET}\n" "$mbps"
            else
                printf "${YELLOW}⚠ Transfert fait, mais duree non exploitable pour calcul precis${RESET}\n"
            fi
        else
            printf "${RED}✗ Échec du test de téléchargement sur %s${RESET}\n" "$test_url"
        fi

        echo ""
        printf "${CYAN}Test de latence...${RESET}\n"
        if command -v ping >/dev/null 2>&1; then
            # Latence vers DNS public + latence TCP/HTTPS
            ping_google=$(ping -c 5 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}')
            ping_cf=$(ping -c 5 1.1.1.1 2>/dev/null | tail -1 | awk -F '/' '{print $5}')
            [ -n "$ping_google" ] && printf "${GREEN}✓ Latence moyenne (8.8.8.8): %s ms${RESET}\n" "$ping_google"
            [ -n "$ping_cf" ] && printf "${GREEN}✓ Latence moyenne (1.1.1.1): %s ms${RESET}\n" "$ping_cf"
        else
            printf "${YELLOW}⚠ ping non disponible${RESET}\n"
        fi

        if command -v curl >/dev/null 2>&1; then
            conn_time=$(curl -o /dev/null -s -w "%{time_connect}" https://example.com 2>/dev/null)
            ttfb_time=$(curl -o /dev/null -s -w "%{time_starttransfer}" https://example.com 2>/dev/null)
            [ -n "$conn_time" ] && printf "${GREEN}✓ TCP connect (example.com): %ss${RESET}\n" "$conn_time"
            [ -n "$ttfb_time" ] && printf "${GREEN}✓ TTFB HTTPS (example.com): %ss${RESET}\n" "$ttfb_time"
        fi

        echo ""
        pause_if_tty
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
        pause_if_tty
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
        pause_if_tty
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
        pause_if_tty
    }
    
    # Gestion des arguments en ligne de commande
    if [ -z "$1" ] || [ "$1" = "--help" ]; then
        :
    elif [ -n "$1" ]; then
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
            routeman|routes|route-manager)
                launch_routeman
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
            diagnose|diag|health)
                network_diagnose
                ;;
            diagnose-report|diag-report)
                network_diagnose_report "$@"
                ;;
            dns-bench|dnsbench)
                dns_benchmark "$2"
                ;;
            diagnose-deep|diag-deep|health-deep)
                network_diagnose_deep
                ;;
            firewall|fw)
                firewall_status
                ;;
            lookup|resolve)
                if [ -n "$2" ]; then
                    show_header
                    printf "${YELLOW}🔎 Lookup réseau (IP / domaine)${RESET}\n"
                    printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
                    target="$2"
                    printf "Cible: %s\n\n" "$target"
                    printf "${CYAN}Resolution DNS:${RESET}\n"
                    if command -v dig >/dev/null 2>&1; then
                        dig +short "$target" 2>/dev/null | sed 's/^/  /'
                        printf "\n${CYAN}Reverse DNS:${RESET}\n"
                        dig +short -x "$target" 2>/dev/null | sed 's/^/  /'
                    else
                        getent hosts "$target" 2>/dev/null | sed 's/^/  /'
                    fi
                    if command -v whois >/dev/null 2>&1; then
                        printf "\n${CYAN}WHOIS (extrait):${RESET}\n"
                        whois "$target" 2>/dev/null | awk 'NR<=25 {print "  " $0}'
                    fi
                else
                    network_lookup
                fi
                ;;
            trace|traceroute|tracepath)
                network_trace "$2"
                ;;
            mtr)
                network_mtr "$2"
                ;;
            whois)
                network_whois "$2"
                ;;
            connectivity|ping)
                test_connectivity
                ;;
            speed)
                test_network_speed "$2"
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
            help|-h)
                netman_print_quick_help
                ;;
            *)
                printf "${RED}Commande inconnue: %s${RESET}\n" "$1"
                echo "Utilisez 'netman help' pour voir les commandes disponibles"
                return 1
                ;;
        esac
    fi
    if [ -z "$1" ] || [ "$1" = "--help" ]; then
        if [ "$1" = "--help" ]; then
            netman help
            if ! { [ -t 0 ] && [ -t 1 ]; }; then
                return 0
            fi
            pause_if_tty
        fi
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
            echo "  ${BOLD}e${RESET}  🧭 Gestionnaire de routes (routeman)"
            echo "  ${BOLD}6${RESET}  🖧  Interfaces réseau"
            echo "  ${BOLD}7${RESET}  🔍 Scanner un port spécifique"
            echo "  ${BOLD}8${RESET}  💀 Kill rapide d'un port"
            echo "  ${BOLD}9${RESET}  📊 Statistiques réseau"
            echo "  ${BOLD}f${RESET}  🩺 Diagnostic réseau complet"
            echo "  ${BOLD}k${RESET}  🧪 Diagnostic profond perf (RX/TX)"
            echo "  ${BOLD}g${RESET}  ⚡ Benchmark DNS"
            echo "  ${BOLD}i${RESET}  🛡️ Statut firewall"
            echo "  ${BOLD}j${RESET}  🔎 Lookup IP / domaine"
            echo "  ${BOLD}t${RESET}  🧭 Traceroute / tracepath"
            echo "  ${BOLD}m${RESET}  🧪 MTR (latence/pertes)"
            echo "  ${BOLD}w${RESET}  📄 WHOIS détaillé"
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
            choice=""
            if [ -t 0 ] && [ -t 1 ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
                menu_input_file=$(mktemp)
                cat > "$menu_input_file" <<'EOF'
Gerer les ports en ecoute (interactif)|1
Afficher les connexions actives|2
Informations IP (publique/locale)|3
Configuration DNS|4
Table de routage|5
Gestionnaire de routes (routeman)|e
Interfaces reseau|6
Scanner un port specifique|7
Kill rapide d'un port|8
Statistiques reseau|9
Diagnostic reseau complet|f
Diagnostic profond perf (RX/TX)|k
Benchmark DNS|g
Statut firewall|i
Lookup IP / domaine|j
Traceroute / tracepath|t
MTR (latence/pertes)|m
WHOIS detaille|w
Test de connectivite (ping/traceroute)|a
Test de vitesse reseau|b
Monitoring bande passante (temps reel)|c
Analyse du trafic reseau|d
Exporter la configuration|0
Aide|h
Quitter|q
EOF
                choice=$(dotfiles_ncmenu_select "NETMAN - Menu principal" < "$menu_input_file" 2>/dev/null || true)
                rm -f "$menu_input_file"
                echo ""
            fi
            if [ -z "$choice" ]; then
                printf "Votre choix: "
                read choice
                echo ""
            fi
            
            case "$choice" in
                1) manage_ports ;;
                2) show_connections ;;
                3) show_ip_info ;;
                4) show_dns_info ;;
                5) show_routing ;;
                e|E) launch_routeman ;;
                6) show_interfaces ;;
                7) scan_port ;;
                8) kill_port_quick ;;
                9) show_network_stats ;;
                f|F) network_diagnose ;;
                k|K) network_diagnose_deep ;;
                g|G) dns_benchmark ;;
                i|I) firewall_status ;;
                j|J) network_lookup ;;
                t|T) network_trace ;;
                m|M) network_mtr ;;
                w|W) network_whois ;;
                a|A) test_connectivity ;;
                b|B) test_network_speed ;;
                c|C) monitor_bandwidth ;;
                d|D) analyze_traffic ;;
                0) export_network_config ;;
                h|H)
                    show_header
                    netman_print_quick_help
                    pause_if_tty
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
