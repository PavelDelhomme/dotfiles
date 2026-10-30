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
    if [ -f "$DOTFILES_DIR/scripts/lib/manager_ui.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/manager_ui.sh"
        dotfiles_manager_load_ui_libs
        if command -v manager_deps_check_once >/dev/null 2>&1; then
            manager_deps_check_once netman 2>/dev/null || true
        fi
    elif [ -f "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh" ]; then
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
        _preview_cmd="$2"
        if [ -z "$_preview_cmd" ]; then
            _preview_cmd='echo {}'
        fi
        if [ -t 0 ] && [ -t 1 ] && command -v fzf >/dev/null 2>&1; then
            fzf --height=85% --layout=reverse --border --ansi \
                --prompt="$_prompt > " \
                --preview="$_preview_cmd" --preview-window=down,35%:wrap
        else
            return 1
        fi
    }

    netman_dotcli_menu_pick() {
        _title="$1"
        _file="$2"
        if command -v manager_ui_select_file >/dev/null 2>&1; then
            manager_ui_select_file "$_title" "$_file"
            return $?
        fi
        return 1
    }

    netman_show_interface_details() {
        iface="$1"
        [ -z "$iface" ] && return 1
        iface=$(printf '%s' "$iface" | awk '{print $1}' | sed 's/:$//')
        iface_base=${iface%%@*}
        [ -z "$iface_base" ] && iface_base="$iface"
        printf "\n${CYAN}Interface: %s${RESET}\n" "$iface"
        echo "─────────────────────────"

        state=$(ip link show "$iface_base" 2>/dev/null | awk '/state/ {for(i=1;i<=NF;i++) if($i=="state"){print $(i+1); exit}}')
        [ -z "$state" ] && state="UNKNOWN"
        case "$state" in
            UP) printf "  État: ${GREEN}%s${RESET}\n" "$state" ;;
            *) printf "  État: ${RED}%s${RESET}\n" "$state" ;;
        esac

        mac=$(ip link show "$iface_base" 2>/dev/null | awk '/link\/ether/ {print $2; exit}')
        [ -z "$mac" ] && mac="N/A"
        echo "  MAC: $mac"
        echo "  IPv4:"
        ip -4 addr show "$iface_base" 2>/dev/null | awk '/inet / {print "    " $2}'
        echo "  IPv6:"
        ip -6 addr show "$iface_base" 2>/dev/null | awk '/inet6 / {print "    " $2}'

        stats=$(ip -s link show "$iface_base" 2>/dev/null)
        rx_bytes=$(echo "$stats" | awk '/RX:/{getline; print $1}')
        tx_bytes=$(echo "$stats" | awk '/TX:/{getline; print $1}')
        if [ -n "$rx_bytes" ]; then
            echo "  Statistiques:"
            rx_formatted=$(numfmt --to=iec-i --suffix=B "$rx_bytes" 2>/dev/null || echo "${rx_bytes}B")
            tx_formatted=$(numfmt --to=iec-i --suffix=B "$tx_bytes" 2>/dev/null || echo "${tx_bytes}B")
            echo "    RX: $rx_formatted"
            echo "    TX: $tx_formatted"
        fi
    }

    netman_collect_listening_ports() {
        NETMAN_PORT_SOURCE=""
        if command -v lsof >/dev/null 2>&1; then
            if command -v sudo >/dev/null 2>&1; then
                _lsof_data=$(sudo lsof -i -P -n 2>/dev/null | grep LISTEN)
            else
                _lsof_data=$(lsof -i -P -n 2>/dev/null | grep LISTEN)
            fi
            if [ -n "$_lsof_data" ]; then
                NETMAN_PORT_SOURCE="lsof"
                printf "%s\n" "$_lsof_data"
                return 0
            fi
        fi

        if command -v ss >/dev/null 2>&1; then
            _ss_data=$(ss -ltnup 2>/dev/null | awk 'NR > 1 { addr=$5; proc=$NF; cmd=proc; pid="-"; gsub(/\[|\]/, "", addr); gsub(/^users:\(\("/, "", cmd); gsub(/".*/, "", cmd); if (cmd == "" || cmd == "-") cmd="ss"; if (match(proc, /pid=[0-9]+/)) pid=substr(proc, RSTART+4, RLENGTH-4); printf "%s %s - - - - - - %s\n", cmd, pid, addr }')
            if [ -n "$_ss_data" ]; then
                NETMAN_PORT_SOURCE="ss"
                printf "%s\n" "$_ss_data"
                return 0
            fi
        fi

        if command -v netstat >/dev/null 2>&1; then
            _netstat_data=$(netstat -lntup 2>/dev/null | awk 'NR > 2 { addr=$4; pidprog=$7; pid="-"; cmd="-"; split(pidprog, a, "/"); if (a[1] != "" && a[1] != "-") pid=a[1]; if (a[2] != "") cmd=a[2]; printf "%s %s - - - - - - %s\n", cmd, pid, addr }')
            if [ -n "$_netstat_data" ]; then
                NETMAN_PORT_SOURCE="netstat"
                printf "%s\n" "$_netstat_data"
                return 0
            fi
        fi

        return 1
    }

    # -------------------------------------------------------------------------
    # Aide par sous-commande (netman help dig | netman dig sans args)
    # -------------------------------------------------------------------------
    netman_print_cmd_help() {
        _cmd="${1:-}"
        case "$_cmd" in
        dig|dns-query)
            cat <<'EOF'
netman dig — requêtes DNS (binaire « dig », paquet bind/dnsutils/bind-utils)

Accepte aussi une URL collée (normalisée vers le host).

Usage :
  netman dig                         cette aide
  netman dig help | -h               idem
  netman dig <domaine|URL>           A + AAAA (+short)
  netman dig @<résolveur> <domaine>  ex. @1.1.1.1 example.com
  netman dig <type> <domaine>        A|AAAA|MX|NS|TXT|SOA|CNAME|ANY
  netman dig -x <ip|domaine>         PTR (si domaine : PTR de chaque A/AAAA)
  netman dig +trace <domaine>        délégation DNS
  netman dig --raw <args…>           passe-plat vers dig

Exemples :
  netman dig example.com
  netman dig https://example.com/path
  netman dig MX example.com
  netman dig @8.8.8.8 google.com
  netman dig -x 1.1.1.1

Voir aussi : netman lookup · netman probe · netman dns-bench · helpman netman dig
EOF
            ;;
        lookup|resolve)
            cat <<'EOF'
netman lookup — fiche DNS dig-like + reverse PTR + whois

Accepte IP, domaine ou URL (https://host/path → host).

Usage :
  netman lookup                      cette aide
  netman lookup <cible>              A/AAAA (+ NS/MX) · PTR par IP · whois
  netman lookup --interactive        demande la cible (TTY)

Exemples :
  netman lookup example.com
  netman lookup https://example.com/foo
  netman lookup 8.8.8.8
  netman lookup 1.1.1.1

Notes :
  • Reverse sur un domaine = PTR de chaque A/AAAA (pas dig -x du nom).
  • Affichage aligné sur netman dig (sections claires, pas un dump brut).

Voir aussi : netman dig · netman probe · netman whois · helpman netman lookup
EOF
            ;;
        dns)
            cat <<'EOF'
netman dns — afficher la config / serveurs DNS locaux

Usage :
  netman dns                         statut DNS (resolv.conf / systemd-resolved…)
  netman dns help                    cette aide

Voir aussi : netman dig · netman dns-bench · netman lookup
EOF
            ;;
        dns-bench|dnsbench)
            cat <<'EOF'
netman dns-bench — comparer la latence de plusieurs résolveurs

Usage :
  netman dns-bench                   benchmark (domaine défaut)
  netman dns-bench <domaine>         ex. netman dns-bench cloudflare.com
  netman dns-bench help              cette aide

Requis : dig. Install : packages_base / installman network-tools
EOF
            ;;
        whois)
            cat <<'EOF'
netman whois — fiche whois

Usage :
  netman whois                       cette aide
  netman whois <cible>               whois détaillé

Voir aussi : netman lookup
EOF
            ;;
        trace|traceroute|tracepath)
            cat <<'EOF'
netman trace — chemin réseau (traceroute / tracepath)

Usage :
  netman trace                       cette aide
  netman trace <hôte>                traceroute -n (ou tracepath)

Voir aussi : netman mtr · netman connectivity
EOF
            ;;
        mtr)
            cat <<'EOF'
netman mtr — latence / pertes (si mtr installé)

Usage :
  netman mtr                         cette aide
  netman mtr <hôte>                  rapport mtr

Install : sudo pacman -S mtr  |  apt install mtr-tiny
EOF
            ;;
        scan)
            cat <<'EOF'
netman scan — test TCP rapide (/dev/tcp)

Usage :
  netman scan                        aide / mode interactif selon TTY
  netman scan <hôte> [port]          défaut port 80
  netman scan help                   cette aide

Exemple : netman scan 192.168.1.1 22
EOF
            ;;
        kill)
            cat <<'EOF'
netman kill — terminer le processus qui écoute un port

Usage :
  netman kill                        aide / interactif
  netman kill <port>                 kill -TERM via lsof
  netman kill help                   cette aide

Exemple : netman kill 8080
EOF
            ;;
        ports)
            cat <<'EOF'
netman ports — ports en écoute / gestion

Usage :
  netman ports                       liste / menu ports
  netman ports help                  cette aide

Voir aussi : netman kill · netman connections
EOF
            ;;
        connections|conn)
            cat <<'EOF'
netman connections — connexions réseau actives

Usage : netman connections | netman conn
EOF
            ;;
        diagnose|diag|health|diagnose-deep|diag-deep)
            cat <<'EOF'
netman diagnose — diagnostic réseau

Usage :
  netman diagnose                    checks interface / gateway / DNS / HTTP
  netman diagnose-deep               + RX/TX, drops, processus
  netman diag-report                 rapport fichier

Voir aussi : netman dns-bench · netman firewall
EOF
            ;;
        firewall|fw)
            cat <<'EOF'
netman firewall — statut ufw / nftables / iptables

Usage : netman firewall | netman fw
EOF
            ;;
        ip|ipinfo)
            cat <<'EOF'
netman ip — adresses publique / locale

Usage :
  netman ip | netman ipinfo          affiche IPs + aperçu
  netman ip help                     cette aide

Voir aussi : netman interfaces · netman connections
EOF
            ;;
        interfaces|iface)
            cat <<'EOF'
netman interfaces — détails par interface (ip link/addr)

Usage :
  netman interfaces | netman iface
  netman interfaces help
EOF
            ;;
        routing|route)
            cat <<'EOF'
netman routing — table de routage (lecture seule)

Usage :
  netman routing | netman route      IPv4/IPv6 + gateway
  netman routing help

Pour ajouter / supprimer / remplacer une route :
  netman routeman                    → manager dédié
  netman routeman show|add|del|…
EOF
            ;;
        routeman|routes|route-manager)
            cat <<'EOF'
netman routeman — pont vers le manager de routes

Usage :
  netman routeman                    menu TTY (sinon show)
  netman routeman show               routes IPv4/IPv6
  netman routeman add <cidr> [gw] [dev] [metric]
  netman routeman del <cidr|default>
  netman routeman replace …
  netman routeman menu

Équivalent direct : routeman <args>
EOF
            ;;
        stats)
            cat <<'EOF'
netman stats — statistiques RX/TX / erreurs

Usage : netman stats
EOF
            ;;
        connectivity|ping)
            cat <<'EOF'
netman connectivity — tests ping / reachability

Usage :
  netman connectivity [hôte]
  netman ping [hôte]

Voir aussi : netman probe · netman trace · netman mtr
EOF
            ;;
        speed)
            cat <<'EOF'
netman speed — test de débit approximatif

Usage : netman speed
EOF
            ;;
        monitor|bandwidth)
            cat <<'EOF'
netman monitor — bande passante temps réel

Usage : netman monitor | netman bandwidth
EOF
            ;;
        analyze|traffic)
            cat <<'EOF'
netman analyze — aperçu du trafic / connexions

Usage : netman analyze | netman traffic
EOF
            ;;
        export)
            cat <<'EOF'
netman export — exporter un snapshot de config réseau

Usage : netman export
EOF
            ;;
        tor)
            cat <<'EOF'
netman tor — statut / contrôle Tor via anonyman

Usage :
  netman tor [status|…]
  anonyman tor …
EOF
            ;;
        i2p|i2pd)
            cat <<'EOF'
netman i2p — statut I2P via anonyman

Usage :
  netman i2p [status|…]
  anonyman i2p · configman i2p
EOF
            ;;
        neigh|arp|neighbors)
            cat <<'EOF'
netman neigh — table des voisins L2 (ARP / NDP)

Usage :
  netman neigh | netman arp          ip neigh show
  netman neigh help

Soft recon LAN. Voir aussi : netman lan
EOF
            ;;
        probe|recon)
            cat <<'EOF'
netman probe — soft recon one-shot d'une cible

Enchaîne : normalize URL → DNS+PTR+whois → ping → traceroute court → ports courants.

Usage :
  netman probe <cible>               IP, domaine ou URL
  netman probe help

Exemple : netman probe https://example.com
Mode soft (pas de scan agressif). Pour LAN : netman lan
EOF
            ;;
        lan|discover|lan-scan)
            cat <<'EOF'
netman lan — découverte du réseau local (soft)

Usage :
  netman lan                         neigh + arp-scan/nmap -sn si dispo
  netman lan help

Outils optionnels : arp-scan, nmap (host discovery -sn uniquement).
EOF
            ;;
        menu)
            cat <<'EOF'
netman menu — menu TUI interactif

Usage :
  netman menu | netman --interactive
EOF
            ;;
        ""|*)
            printf '%s\n' "Sous-commande inconnue pour l'aide: ${_cmd:-(vide)}"
            printf '%s\n' "Essayez: netman help"
            return 1
            ;;
        esac
        return 0
    }

    # Aide courte (stdout) — netman | netman help | -h
    netman_print_quick_help() {
        printf "${CYAN}${BOLD}NETMAN${RESET} — couteau suisse réseau (local · DNS · soft recon)\n"
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        echo ""
        echo "Usage :"
        echo "  netman                         cette page"
        echo "  netman help <sous-commande>    aide détaillée (ex. : netman help lookup)"
        echo "  netman help --interactive      aide + pause (TTY)"
        echo "  netman menu | --interactive    menu TUI"
        echo "  helpman netman [sous-cmd]      même contenu via helpman"
        echo ""
        echo "DNS / identité (accepte aussi les URL collées) :"
        echo "  dig …                 requêtes dig (A/AAAA/MX/NS/TXT, @résolveur, -x, +trace)"
        echo "  lookup <cible>        fiche dig-like + PTR par IP + whois"
        echo "  probe <cible>         soft recon (DNS+ping+trace+ports courants)"
        echo "  dns | dns-bench       config locale / latence multi-résolveurs"
        echo "  whois <cible>         fiche whois"
        echo ""
        echo "Hôte / chemin :"
        echo "  ip | interfaces | connections | ports | stats"
        echo "  routing               table (lecture)   ·  routeman [show|add|del|…]  (édition)"
        echo "  trace | mtr | connectivity | speed"
        echo "  scan <hôte> [port] | kill <port>"
        echo ""
        echo "Soft recon / LAN :"
        echo "  neigh | arp           voisins L2 (ARP/NDP)"
        echo "  lan                   découverte locale (neigh + arp-scan/nmap -sn)"
        echo "  diagnose | diagnose-deep | diag-report | firewall"
        echo "  monitor | analyze | export"
        echo ""
        echo "Anonymat (délègue) :  tor | i2p  → anonyman"
        echo ""
        echo "Exemples :"
        echo "  netman lookup https://example.com/path"
        echo "  netman dig -x 1.1.1.1"
        echo "  netman probe 8.8.8.8"
        echo "  netman routeman show"
        echo "  netman help dig"
        echo ""
    }

    # Aide « longue » sans ouvrir tout le menu (TTY) — netman help --interactive
    netman_interactive_help_cli() {
        show_header
        printf "${CYAN}NETMAN — aide guidée (mode interactif)${RESET}\n"
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        echo ""
        echo "Rappel : les sous-commandes s'exécutent en non interactif."
        echo "Menu TUI : netman menu   ·   Aide dig : netman dig   ·   helpman netman dig"
        echo ""
        netman_print_quick_help
        pause_if_tty
    }

    # Exécution dig (CLI) — sans dig → message deps
    netman_cmd_dig() {
        if [ -z "${1:-}" ] || [ "${1:-}" = "help" ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
            netman_print_cmd_help dig
            return 0
        fi
        if ! command -v dig >/dev/null 2>&1; then
            printf "${YELLOW}⚠ dig absent${RESET} — Arch: sudo pacman -S bind · Debian: apt install dnsutils\n" >&2
            printf "    ou: bash \"\${DOTFILES_DIR:-\$HOME/dotfiles}/scripts/install/system/packages_base.sh\"\n" >&2
            return 1
        fi
        # Passe-plat
        if [ "$1" = "--raw" ]; then
            shift
            dig "$@"
            return $?
        fi
        # Reverse
        if [ "$1" = "-x" ] || [ "$1" = "+x" ]; then
            shift
            [ -n "${1:-}" ] || { netman_print_cmd_help dig; return 1; }
            _rx=$(netman_normalize_host "$1")
            [ -n "$_rx" ] || _rx="$1"
            if netman_is_ip "$_rx"; then
                printf "${CYAN}PTR / reverse %s${RESET}\n" "$_rx"
                dig +short -x "$_rx"
                return $?
            fi
            # Domaine collé à -x → reverse chaque A/AAAA (comme lookup)
            printf "${CYAN}PTR / reverse via A/AAAA de %s${RESET}\n" "$_rx"
            _had=0
            for _ip in $(dig +short A "$_rx" 2>/dev/null; dig +short AAAA "$_rx" 2>/dev/null); do
                [ -n "$_ip" ] || continue
                _had=1
                printf "  %s → " "$_ip"
                dig +short -x "$_ip" 2>/dev/null | tr '\n' ' '
                printf "\n"
            done
            [ "$_had" -eq 1 ] || printf "${YELLOW}  (aucune IP)${RESET}\n"
            return 0
        fi
        # Trace délégation
        if [ "$1" = "+trace" ]; then
            shift
            [ -n "${1:-}" ] || { netman_print_cmd_help dig; return 1; }
            _tr=$(netman_normalize_host "$1")
            dig +trace "${_tr:-$1}"
            return $?
        fi
        _resolver=""
        _type=""
        _target=""
        # @resolver
        case "$1" in
        @*)
            _resolver="$1"
            shift
            ;;
        esac
        # TYPE domaine  OU  domaine seul
        case "${1:-}" in
        [Aa]|AAAA|aaaa|[Mm][Xx]|[Nn][Ss]|TXT|txt|SOA|soa|CNAME|cname|ANY|any|PTR|ptr)
            _type=$(printf '%s' "$1" | tr 'a-z' 'A-Z')
            shift
            _target="${1:-}"
            ;;
        *)
            _target="${1:-}"
            ;;
        esac
        if [ -z "$_target" ]; then
            netman_print_cmd_help dig
            return 1
        fi
        _norm=$(netman_normalize_host "$_target")
        if [ -n "$_norm" ] && [ "$_norm" != "$_target" ]; then
            printf "${YELLOW}↳ normalisé${RESET} %s → %s\n" "$_target" "$_norm"
            _target="$_norm"
        elif [ -n "$_norm" ]; then
            _target="$_norm"
        fi
        if [ -n "$_type" ]; then
            printf "${CYAN}dig %s %s %s${RESET}\n" "${_resolver:-(système)}" "$_type" "$_target"
            if [ -n "$_resolver" ]; then
                dig "$_resolver" "$_type" "$_target" +noall +answer
            else
                dig "$_type" "$_target" +noall +answer
            fi
        else
            printf "${CYAN}dig A/AAAA %s %s${RESET}\n" "${_resolver:-(système)}" "$_target"
            if [ -n "$_resolver" ]; then
                printf "A:    "; dig "$_resolver" +short A "$_target"
                printf "AAAA: "; dig "$_resolver" +short AAAA "$_target"
            else
                printf "A:    "; dig +short A "$_target"
                printf "AAAA: "; dig +short AAAA "$_target"
            fi
        fi
    }
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}"
        if command -v manager_ui_print_banner >/dev/null 2>&1; then
            manager_ui_print_banner "NETMAN - Network Manager" "Gestionnaire Reseau"
        else
            echo "╔════════════════════════════════════════════════════════════════╗"
            echo "║                    NETMAN - Network Manager                    ║"
            echo "║                     Gestionnaire Réseau                       ║"
            echo "╚════════════════════════════════════════════════════════════════╝"
        fi
        printf "${RESET}"
        echo ""
    }
    
    # Fonction pour afficher les ports en écoute avec interface interactive
    manage_ports() {
        SELECTED_ITEMS=""
        PORT_PAGE=0
        while true; do
            show_header
            printf "${YELLOW}📡 Ports en écoute sur le système${RESET}\n"
            manager_ui_section_line "${BLUE}" "${RESET}\n"
            
            # Récupération des ports (lsof -> ss -> netstat)
            PORTS_DATA=$(netman_collect_listening_ports)
            
            if [ -z "$PORTS_DATA" ]; then
                printf "${RED}❌ Aucun port en écoute trouvé.${RESET}\n"
                if ! command -v lsof >/dev/null 2>&1 && ! command -v ss >/dev/null 2>&1 && ! command -v netstat >/dev/null 2>&1; then
                    printf "${YELLOW}⚠ Aucun outil détecté (lsof/ss/netstat).${RESET}\n"
                fi
                echo ""
                if [ -t 0 ] && [ -t 1 ]; then
                    printf "Appuyez sur Entrée pour revenir au menu... "
                    read dummy
                fi
                return
            fi
            
            port_count=$(printf '%s\n' "$PORTS_DATA" | grep -c . 2>/dev/null || printf '0')
            if command -v tui_menu_height >/dev/null 2>&1; then
                PORTS_PER_PAGE=$(tui_menu_height 18)
            else
                PORTS_PER_PAGE=12
            fi
            case "$PORTS_PER_PAGE" in
                ''|*[!0-9]*) PORTS_PER_PAGE=12 ;;
            esac
            [ "$PORTS_PER_PAGE" -lt 5 ] && PORTS_PER_PAGE=5
            [ "$PORTS_PER_PAGE" -gt 25 ] && PORTS_PER_PAGE=25
            total_pages=$(( (port_count + PORTS_PER_PAGE - 1) / PORTS_PER_PAGE ))
            [ "$total_pages" -lt 1 ] && total_pages=1
            if [ "$PORT_PAGE" -ge "$total_pages" ]; then
                PORT_PAGE=$((total_pages - 1))
            fi
            [ "$PORT_PAGE" -lt 0 ] && PORT_PAGE=0
            page_start=$((PORT_PAGE * PORTS_PER_PAGE + 1))
            page_end=$(((PORT_PAGE + 1) * PORTS_PER_PAGE))
            [ "$page_end" -gt "$port_count" ] && page_end="$port_count"

            # Affichage formaté (page courante uniquement)
            printf "${CYAN}%-5s %-10s %-20s %-10s %-15s %-25s %s${RESET}\n" \
                   "N°" "PORT" "COMMANDE" "PID" "USER" "ADRESSE" "STATUS"
            echo "────────────────────────────────────────────────────────────────────────────────"
            if [ -n "$NETMAN_PORT_SOURCE" ]; then
                printf "${BLUE}Source: %s${RESET}\n" "$NETMAN_PORT_SOURCE"
            fi
            if [ "$total_pages" -gt 1 ]; then
                printf "${BLUE}Page %s/%s — ports %s-%s/%s${RESET}\n" \
                    "$((PORT_PAGE + 1))" "$total_pages" "$page_start" "$page_end" "$port_count"
            fi
            
            i=1
            
            echo "$PORTS_DATA" | while IFS= read -r line; do
                if [ "$i" -lt "$page_start" ] || [ "$i" -gt "$page_end" ]; then
                    i=$((i + 1))
                    continue
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
                
                printf "%-5d %-10s %-20.20s %-10s %-15s %-25.25s %b\n" \
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
            echo "  [f]   Explorer les ports via fzf (preview)"
            echo "  [r]   Rafraîchir la liste"
            if [ "$total_pages" -gt 1 ]; then
                echo "  [>]   Page suivante"
                echo "  [<]   Page précédente"
            fi
            echo "  [0]   Retour au menu principal"
            echo "  [q]   Retour au menu principal"
            echo ""
            action=""
            if [ -t 0 ] && [ -t 1 ] && [ "${DOTFILES_DOTCLI_ENABLE:-0}" = "1" ]; then
                _ports_actions_file=$(mktemp)
                cat > "$_ports_actions_file" <<'EOF'
Basculer selection par numero de ligne|g
Kill processus selectionnes|k
Infos detaillees ports selectionnes|i
Selectionner tous les ports|a
Desel. tous les ports|n
Explorer ports via fzf preview|f
Rafraichir la liste|r
EOF
                if [ "$total_pages" -gt 1 ]; then
                    cat >> "$_ports_actions_file" <<'EOF'
Page suivante|]
Page precedente|[
EOF
                fi
                cat >> "$_ports_actions_file" <<'EOF'
Retour menu principal|0
Retour menu principal|q
EOF
                action=$(netman_dotcli_menu_pick "NETMAN - Ports actions" "$_ports_actions_file" || true)
                rm -f "$_ports_actions_file"
            fi
            if [ -z "$action" ]; then
                printf "Votre choix: "
                read action
            fi
            echo ""
            
            case "$action" in
                g|G)
                    printf "Numéro de ligne port: "
                    read num
                    case "$num" in
                        [0-9])
                            case " $SELECTED_ITEMS " in
                                *" $num "*)
                                    SELECTED_ITEMS=$(echo "$SELECTED_ITEMS" | sed "s/ $num //")
                                    ;;
                                *)
                                    SELECTED_ITEMS="$SELECTED_ITEMS $num "
                                    ;;
                            esac
                            ;;
                    esac
                    ;;
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
                f|F)
                    if [ -t 0 ] && [ -t 1 ] && command -v fzf >/dev/null 2>&1; then
                        picked_port=$(
                            echo "$PORTS_DATA" | awk '{ cmd=$1; pid=$2; user=$3; addr=$9; port=addr; sub(/.*:/,"",port); printf "%-8s %-18s %-10s %-14s %s\n", port, cmd, pid, user, addr }' \
                                | netman_fzf_pick_line "Ports LISTEN" 'printf "%s\n" "{}"'
                        )
                        if [ -n "$picked_port" ]; then
                            echo "Sélection: $picked_port"
                            echo ""
                            pause_if_tty
                        fi
                    else
                        printf "${YELLOW}⚠ fzf indisponible (fallback menu classique)${RESET}\n"
                        sleep 1
                    fi
                    ;;
                r|R)
                    continue
                    ;;
                \]|\>|next|suivant)
                    if [ "$total_pages" -gt 1 ]; then
                        PORT_PAGE=$((PORT_PAGE + 1))
                        [ "$PORT_PAGE" -ge "$total_pages" ] && PORT_PAGE=0
                    fi
                    continue
                    ;;
                \[|\<|prev|precedent|précédent)
                    if [ "$total_pages" -gt 1 ]; then
                        PORT_PAGE=$((PORT_PAGE - 1))
                        [ "$PORT_PAGE" -lt 0 ] && PORT_PAGE=$((total_pages - 1))
                    fi
                    continue
                    ;;
                0|q|Q|quit|exit)
                    return
                    ;;
            esac
        done
    }
    
    # Fonction pour afficher les connexions actives
    show_connections() {
        show_header
        printf "${YELLOW}🔗 Connexions réseau actives${RESET}\n"
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        
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
            if _picked_conn=$(printf '%s\n' "$_conn_rows" | netman_fzf_pick_line "Connexions ESTAB" 'printf "%s\n" "{}"'); then
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
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        
        # IP Publique
        printf "\n${CYAN}Adresse IP Publique:${RESET}\n"
        public_ip=$(curl -s https://ipinfo.io/ip 2>/dev/null || echo "Non disponible")
        echo "  $public_ip"
        
        if [ "$public_ip" != "Non disponible" ]; then
            printf "\n${CYAN}Informations de géolocalisation:${RESET}\n"
            curl -s https://ipinfo.io 2>/dev/null | grep -E '"(city|region|country|org)"' | \
            sed 's/[",]//g; s/^/  /'
        fi
        
        # IPs Locales — `ip -o` : une ligne par adresse (iface en $2, addr en $4).
        # L'ancien grep -B2 + awk -F':' cassait dès qu'une adresse IPv6 contenait des ':'.
        printf "\n${CYAN}Adresses IP Locales:${RESET}\n"
        if ip -4 -o addr show >/dev/null 2>&1; then
            ip -4 -o addr show 2>/dev/null | awk '$3 == "inet" { printf "  %-15s %s\n", $2 ":", $4 }' | sort -u
        else
            echo "  (iproute2 « ip -o » indisponible — installer iproute2)"
        fi
        
        # IPv6 — idem ; exclure link-local fe80::…
        printf "\n${CYAN}Adresses IPv6:${RESET}\n"
        if ip -6 -o addr show >/dev/null 2>&1; then
            ip -6 -o addr show 2>/dev/null | awk '$3 == "inet6" && $4 !~ /^fe80/ { printf "  %-15s %s\n", $2 ":", $4 }' | sort -u
        else
            echo "  (iproute2 « ip -o » indisponible — installer iproute2)"
        fi
        
        echo ""
        pause_if_tty
    }
    
    # Fonction pour afficher les informations DNS
    show_dns_info() {
        show_header
        printf "${YELLOW}🔍 Configuration DNS${RESET}\n"
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        
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
        manager_ui_section_line "${BLUE}" "${RESET}\n"

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
        manager_ui_section_line "${BLUE}" "${RESET}\n"

        test_domain="google.com"
        [ -n "$1" ] && test_domain="$1"
        printf "Domaine de test: %s\n\n" "$test_domain"

        if ! command -v dig >/dev/null 2>&1; then
            printf "${YELLOW}⚠ dig non disponible: benchmark par résolveurs impossible.${RESET}\n"
            printf "${CYAN}Fallback: résolution système (getent) x3${RESET}\n"
            if command -v getent >/dev/null 2>&1; then
                i=1
                while [ "$i" -le 3 ]; do
                    start_ms=$(date +%s%3N 2>/dev/null || date +%s000)
                    ans=$(getent hosts "$test_domain" 2>/dev/null | awk 'NR==1 {print $1}')
                    end_ms=$(date +%s%3N 2>/dev/null || date +%s000)
                    delta=$((end_ms - start_ms))
                    if [ -n "$ans" ]; then
                        printf "  ${GREEN}system${RESET}  essai %s -> %4sms | %s\n" "$i" "$delta" "$ans"
                    else
                        printf "  ${RED}system${RESET}  essai %s -> echec\n" "$i"
                    fi
                    i=$((i + 1))
                done
                echo ""
                printf "${BLUE}Installez dnsutils/bind-tools pour benchmark multi-résolveurs.${RESET}\n"
                echo ""
                pause_if_tty
                return 0
            fi
            printf "${RED}❌ getent indisponible aussi: impossible de résoudre %s${RESET}\n" "$test_domain"
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
        manager_ui_section_line "${BLUE}" "${RESET}\n"

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
        manager_ui_section_line "${BLUE}" "${RESET}\n"

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

    # -------------------------------------------------------------------------
    # Helpers cibles (URL → host) + lookup dig-like + reverse PTR correct
    # -------------------------------------------------------------------------
    # DESC: extrait host/IP d'une URL ou chaîne collée (https://a/b → a)
    netman_normalize_host() {
        _raw="${1:-}"
        [ -n "$_raw" ] || { printf '\n'; return 1; }
        # trim espaces
        _raw=$(printf '%s' "$_raw" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        # scheme://
        _raw=$(printf '%s' "$_raw" | sed 's|^[a-zA-Z][a-zA-Z0-9+.-]*://||')
        # userinfo@
        case "$_raw" in
            *@*) _raw=$(printf '%s' "$_raw" | sed 's/^[^@]*@//') ;;
        esac
        # IPv6 entre crochets [2001:db8::1]:443
        case "$_raw" in
            \[*\]*)
                _raw=$(printf '%s' "$_raw" | sed 's/^\[\([^]]*\)\].*/\1/')
                printf '%s\n' "$_raw"
                return 0
                ;;
        esac
        # chemin / query / fragment
        _raw=$(printf '%s' "$_raw" | sed 's/[/?#].*$//')
        # port :443 (sauf IPv6 déjà géré)
        case "$_raw" in
            *:*)
                # si ça ressemble à IPv4:port → strip port ; sinon laisser (hostname rare avec :)
                if printf '%s' "$_raw" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$'; then
                    _raw=$(printf '%s' "$_raw" | sed 's/:[0-9]*$//')
                elif printf '%s' "$_raw" | grep -Eq '^[A-Za-z0-9._-]+:[0-9]+$'; then
                    _raw=$(printf '%s' "$_raw" | sed 's/:[0-9]*$//')
                fi
                ;;
        esac
        # trailing dot DNS optionnel conservé ; strip slash résiduel
        _raw=$(printf '%s' "$_raw" | sed 's|/*$||')
        printf '%s\n' "$_raw"
    }

    netman_is_ip() {
        _t="${1:-}"
        # IPv4
        printf '%s' "$_t" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' && return 0
        # IPv6 grossier
        printf '%s' "$_t" | grep -Eq '^[0-9a-fA-F:]+$' && printf '%s' "$_t" | grep -q ':' && return 0
        return 1
    }

    # Affiche PTR pour une IP ; retourne 0 si au moins une ligne
    netman_ptr_of_ip() {
        _ip="${1:-}"
        [ -n "$_ip" ] || return 1
        if command -v dig >/dev/null 2>&1; then
            dig +short -x "$_ip" 2>/dev/null | sed '/^$/d'
        elif command -v getent >/dev/null 2>&1; then
            getent hosts "$_ip" 2>/dev/null | awk '{print $2}'
        else
            return 1
        fi
    }

    # DESC: lookup unifié (CLI + interactif) — affichage style dig, reverse OK
    # USAGE: netman_cmd_lookup [cible|--interactive]
    netman_cmd_lookup() {
        if [ -z "${1:-}" ] || [ "${1:-}" = "help" ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
            netman_print_cmd_help lookup
            return 0
        fi
        _target=""
        _show_hdr=0
        if [ "$1" = "--interactive" ] || [ "$1" = "-i" ]; then
            if ! { [ -t 0 ] && [ -t 1 ]; }; then
                printf '%s\n' "netman lookup: --interactive nécessite un TTY." >&2
                return 2
            fi
            _show_hdr=1
            show_header
            printf "${YELLOW}🔎 Lookup réseau (IP / domaine / URL)${RESET}\n"
            manager_ui_section_line "${BLUE}" "${RESET}\n"
            printf "Cible (IP, domaine ou URL): "
            read _target
        else
            _target="$1"
        fi
        if [ -z "$_target" ]; then
            printf "${RED}❌ Cible vide${RESET}\n" >&2
            return 1
        fi

        _raw="$_target"
        _host=$(netman_normalize_host "$_raw")
        if [ -z "$_host" ]; then
            printf "${RED}❌ Impossible d'extraire un hôte depuis: %s${RESET}\n" "$_raw" >&2
            return 1
        fi

        if [ "$_show_hdr" -eq 0 ]; then
            printf "${CYAN}${BOLD}netman lookup${RESET}  raw=%s  →  host=%s\n" "$_raw" "$_host"
            manager_ui_section_line "${BLUE}" "${RESET}\n"
        else
            printf "\n  raw : %s\n  host: %s\n" "$_raw" "$_host"
        fi

        _ips=""
        if netman_is_ip "$_host"; then
            printf "\n${CYAN}Type${RESET}     IP (pas de résolution forward)\n"
            printf "${CYAN}Adresse${RESET}  %s\n" "$_host"
            _ips="$_host"
        else
            printf "\n${CYAN}Forward DNS (A / AAAA)${RESET}  — style dig +short\n"
            if command -v dig >/dev/null 2>&1; then
                _a=$(dig +short A "$_host" 2>/dev/null | sed '/^$/d')
                _aaaa=$(dig +short AAAA "$_host" 2>/dev/null | sed '/^$/d')
                if [ -n "$_a" ]; then
                    printf "  ${BOLD}A${RESET}\n"
                    printf '%s\n' "$_a" | sed 's/^/    /'
                    _ips=$(printf '%s\n%s\n' "$_ips" "$_a")
                else
                    printf "  ${BOLD}A${RESET}     (aucun)\n"
                fi
                if [ -n "$_aaaa" ]; then
                    printf "  ${BOLD}AAAA${RESET}\n"
                    printf '%s\n' "$_aaaa" | sed 's/^/    /'
                    _ips=$(printf '%s\n%s\n' "$_ips" "$_aaaa")
                else
                    printf "  ${BOLD}AAAA${RESET}  (aucun)\n"
                fi
                # NS / MX utiles en un coup d'œil
                _ns=$(dig +short NS "$_host" 2>/dev/null | sed '/^$/d' | head -6)
                _mx=$(dig +short MX "$_host" 2>/dev/null | sed '/^$/d' | head -6)
                if [ -n "$_ns" ]; then
                    printf "  ${BOLD}NS${RESET}\n"
                    printf '%s\n' "$_ns" | sed 's/^/    /'
                fi
                if [ -n "$_mx" ]; then
                    printf "  ${BOLD}MX${RESET}\n"
                    printf '%s\n' "$_mx" | sed 's/^/    /'
                fi
            else
                getent hosts "$_host" 2>/dev/null | sed 's/^/  /'
                _ips=$(getent hosts "$_host" 2>/dev/null | awk '{print $1}')
            fi
        fi

        printf "\n${CYAN}Reverse DNS (PTR)${RESET}\n"
        _ip_list=$(printf '%s\n' "$_ips" | sed '/^$/d')
        if [ -z "$_ip_list" ]; then
            printf "  ${YELLOW}(aucune IP à reverse)${RESET}\n"
        else
            # IFS newline pour itérer sans sous-shell pipe
            old_ifs=$IFS
            IFS='
'
            for _ip in $_ip_list; do
                IFS=$old_ifs
                [ -n "$_ip" ] || continue
                _ptrs=$(netman_ptr_of_ip "$_ip")
                if [ -n "$_ptrs" ]; then
                    printf "  ${GREEN}%s${RESET}\n" "$_ip"
                    printf '%s\n' "$_ptrs" | sed 's/^/    PTR  /'
                else
                    printf "  %s\n    ${YELLOW}PTR  (aucun)${RESET}\n" "$_ip"
                fi
                IFS='
'
            done
            IFS=$old_ifs
        fi

        if command -v whois >/dev/null 2>&1; then
            printf "\n${CYAN}WHOIS (extrait, 30 lignes)${RESET}  — cible whois=%s\n" "$_host"
            whois "$_host" 2>/dev/null | awk '
                BEGIN { n=0 }
                /^[Ss]earching|^%\s|^#|^$/ { next }
                { print "  " $0; n++; if (n>=30) exit }
            '
        else
            printf "\n${YELLOW}⚠ whois non installé${RESET} (pacman -S whois)\n"
        fi

        echo ""
        if [ "$_show_hdr" -eq 1 ]; then
            pause_if_tty
        fi
        return 0
    }

    # Compat menu interactif (ancien nom)
    network_lookup() {
        netman_cmd_lookup --interactive
    }

    network_trace() {
        _cli=0
        [ -n "${1:-}" ] && _cli=1
        if [ "$_cli" -eq 0 ]; then
            show_header
            printf "${YELLOW}🧭 Traceroute / Tracepath${RESET}\n"
            manager_ui_section_line "${BLUE}" "${RESET}\n"
        fi
        _target="${1:-}"
        if [ -z "$_target" ]; then
            printf "Hôte ou IP cible: "
            read _target
        fi
        [ -z "$_target" ] && printf "${RED}❌ Cible vide${RESET}\n" && return 1
        _n=$(netman_normalize_host "$_target")
        [ -n "$_n" ] && _target="$_n"
        printf "${CYAN}trace → %s${RESET}\n" "$_target"
        if command -v traceroute >/dev/null 2>&1; then
            traceroute -n "$_target" 2>/dev/null | sed -n '1,40p'
        elif command -v tracepath >/dev/null 2>&1; then
            tracepath "$_target" 2>/dev/null | sed -n '1,40p'
        else
            printf "${YELLOW}⚠ traceroute/tracepath non installé${RESET}\n"
            return 1
        fi
        echo ""
        [ "$_cli" -eq 0 ] && pause_if_tty
        return 0
    }

    network_mtr() {
        show_header
        printf "${YELLOW}🧪 MTR (latence/pertes)${RESET}\n"
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        _target="${1:-}"
        if [ -z "$_target" ]; then
            printf "Hôte ou IP cible: "
            read _target
        fi
        [ -z "$_target" ] && printf "${RED}❌ Cible vide${RESET}\n" && return 1
        _mn=$(netman_normalize_host "$_target")
        [ -n "$_mn" ] && _target="$_mn"
        case "$_target" in
            127.0.0.1|localhost|::1)
                printf "${BLUE}Cible loopback détectée, test local via ping.${RESET}\n"
                if command -v ping >/dev/null 2>&1; then
                    ping -c 4 "$_target" 2>/dev/null || ping -c 4 127.0.0.1 2>/dev/null
                    echo ""
                    pause_if_tty
                    return 0
                fi
                ;;
        esac
        if command -v mtr >/dev/null 2>&1; then
            if mtr -rw -n -c 8 "$_target" 2>/dev/null; then
                echo ""
                pause_if_tty
                return 0
            fi
            printf "${YELLOW}⚠ mtr a échoué sur %s, fallback trace/ping.${RESET}\n" "$_target"
        else
            printf "${YELLOW}⚠ mtr non installé, fallback trace/ping.${RESET}\n"
        fi
        if command -v traceroute >/dev/null 2>&1; then
            traceroute -n "$_target" 2>/dev/null | sed -n '1,25p'
        elif command -v tracepath >/dev/null 2>&1; then
            tracepath "$_target" 2>/dev/null | sed -n '1,25p'
        fi
        if command -v ping >/dev/null 2>&1; then
            echo ""
            ping -c 4 "$_target" 2>/dev/null
        fi
        echo ""
        pause_if_tty
        return 0
    }

    network_whois() {
        _cli=0
        [ -n "${1:-}" ] && _cli=1
        if [ "$_cli" -eq 0 ]; then
            show_header
            printf "${YELLOW}📄 WHOIS détaillé${RESET}\n"
            manager_ui_section_line "${BLUE}" "${RESET}\n"
        fi
        _target="${1:-}"
        if [ -z "$_target" ]; then
            printf "Domaine/IP cible: "
            read _target
        fi
        [ -z "$_target" ] && printf "${RED}❌ Cible vide${RESET}\n" && return 1
        _n=$(netman_normalize_host "$_target")
        [ -n "$_n" ] && _target="$_n"
        printf "${CYAN}whois → %s${RESET}\n" "$_target"
        if command -v whois >/dev/null 2>&1; then
            whois "$_target" 2>/dev/null | sed -n '1,120p'
        else
            printf "${YELLOW}⚠ whois non installé${RESET}\n"
            return 1
        fi
        echo ""
        [ "$_cli" -eq 0 ] && pause_if_tty
        return 0
    }

    # Voisinage L2 (ARP / NDP) — soft recon LAN
    netman_cmd_neigh() {
        if [ "${1:-}" = "help" ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
            netman_print_cmd_help neigh
            return 0
        fi
        printf "${CYAN}${BOLD}netman neigh${RESET} — table voisins (ARP / NDP)\n"
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        if command -v ip >/dev/null 2>&1; then
            printf "${YELLOW}IPv4 (ip -4 neigh)${RESET}\n"
            ip -4 neigh show 2>/dev/null | sed 's/^/  /' || printf "  (vide)\n"
            echo ""
            printf "${YELLOW}IPv6 (ip -6 neigh)${RESET}\n"
            ip -6 neigh show 2>/dev/null | sed 's/^/  /' | head -40 || printf "  (vide)\n"
        elif command -v arp >/dev/null 2>&1; then
            arp -an 2>/dev/null | sed 's/^/  /'
        else
            printf "${RED}ip/arp introuvable${RESET}\n" >&2
            return 1
        fi
        echo ""
        return 0
    }

    # Soft recon one-shot : normalize + dig + reverse + ping + whois extrait
    netman_cmd_probe() {
        if [ -z "${1:-}" ] || [ "${1:-}" = "help" ] || [ "${1:-}" = "-h" ]; then
            netman_print_cmd_help probe
            return 0
        fi
        _raw="$1"
        _host=$(netman_normalize_host "$_raw")
        [ -n "$_host" ] || { printf "${RED}cible invalide${RESET}\n" >&2; return 1; }
        printf "${CYAN}${BOLD}netman probe${RESET} (soft)  %s → %s\n" "$_raw" "$_host"
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        echo ""
        printf "${YELLOW}1/4 DNS${RESET}\n"
        netman_cmd_lookup "$_host"
        echo ""
        printf "${YELLOW}2/4 Ping (4 paquets)${RESET}\n"
        if command -v ping >/dev/null 2>&1; then
            if netman_is_ip "$_host" && printf '%s' "$_host" | grep -q ':'; then
                ping -6 -c 4 -W 2 "$_host" 2>/dev/null || ping -c 4 -W 2 "$_host" 2>/dev/null || true
            else
                ping -c 4 -W 2 "$_host" 2>/dev/null || true
            fi
        else
            printf "  ${YELLOW}ping absent${RESET}\n"
        fi
        echo ""
        printf "${YELLOW}3/4 Chemin (10 premiers hops)${RESET}\n"
        if command -v traceroute >/dev/null 2>&1; then
            traceroute -n -w 2 -q 1 -m 10 "$_host" 2>/dev/null | sed 's/^/  /'
        elif command -v tracepath >/dev/null 2>&1; then
            tracepath -m 10 "$_host" 2>/dev/null | sed 's/^/  /'
        else
            printf "  ${YELLOW}traceroute absent${RESET}\n"
        fi
        echo ""
        printf "${YELLOW}4/4 Ports courants (soft /dev/tcp)${RESET}\n"
        for _p in 22 53 80 443 8080; do
            if timeout 1 bash -c "echo >/dev/tcp/$_host/$_p" 2>/dev/null; then
                printf "  ${GREEN}%-5s OPEN${RESET}\n" "$_p"
            else
                printf "  %-5s closed/filtered\n" "$_p"
            fi
        done
        echo ""
        return 0
    }

    # Découverte LAN soft (neigh + optionnel nmap/arp-scan si présents)
    netman_cmd_lan() {
        if [ "${1:-}" = "help" ] || [ "${1:-}" = "-h" ]; then
            netman_print_cmd_help lan
            return 0
        fi
        printf "${CYAN}${BOLD}netman lan${RESET} — découverte locale (soft)\n"
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        _iface=$(ip route show default 2>/dev/null | awk '/default/ {print $5; exit}')
        _cidr=$(ip -4 -o addr show dev "${_iface:-}" 2>/dev/null | awk '{print $4; exit}')
        printf "  iface=%s  cidr=%s\n\n" "${_iface:-(?)}" "${_cidr:-(?)}"
        netman_cmd_neigh
        if command -v arp-scan >/dev/null 2>&1 && [ -n "$_iface" ]; then
            printf "${YELLOW}arp-scan (local)${RESET}\n"
            if [ "$(id -u)" -eq 0 ]; then
                arp-scan -I "$_iface" --localnet 2>/dev/null | sed 's/^/  /' | head -40
            elif command -v sudo >/dev/null 2>&1; then
                sudo arp-scan -I "$_iface" --localnet 2>/dev/null | sed 's/^/  /' | head -40
            else
                printf "  ${YELLOW}sudo requis pour arp-scan${RESET}\n"
            fi
            echo ""
        fi
        if command -v nmap >/dev/null 2>&1 && [ -n "$_cidr" ]; then
            printf "${YELLOW}nmap -sn %s (host discovery)${RESET}\n" "$_cidr"
            nmap -sn "$_cidr" 2>/dev/null | sed 's/^/  /' | head -60
            echo ""
        else
            printf "${BLUE}Astuce${RESET} : pacman -S arp-scan nmap pour un scan LAN plus riche.\n"
        fi
        return 0
    }
    
    # Fonction pour afficher la table de routage
    show_routing() {
        show_header
        printf "${YELLOW}🛣️  Table de routage${RESET}\n"
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        
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

    # Pont vers routeman — passe-plat des args ; sans args → menu TTY ou show
    launch_routeman() {
        _routeman_core_path="${DOTFILES_DIR:-$HOME/dotfiles}/core/managers/routeman/core/routeman.sh"
        if ! command -v routeman >/dev/null 2>&1; then
            if [ -f "$_routeman_core_path" ]; then
                # shellcheck source=/dev/null
                . "$_routeman_core_path"
            else
                printf "${RED}❌ ROUTEMAN non trouvé (%s)${RESET}\n" "$_routeman_core_path" >&2
                return 1
            fi
        fi
        if ! command -v routeman >/dev/null 2>&1; then
            printf "${RED}❌ routeman chargé mais commande indisponible${RESET}\n" >&2
            return 1
        fi
        if [ "$#" -eq 0 ]; then
            if [ -t 0 ] && [ -t 1 ]; then
                routeman menu
            else
                routeman show
            fi
            return $?
        fi
        if [ "$1" = "help" ] || [ "$1" = "-h" ]; then
            netman_print_cmd_help routeman
            return 0
        fi
        routeman "$@"
    }
    
    # Fonction pour afficher les interfaces réseau
    show_interfaces() {
        show_header
        printf "${YELLOW}🖧  Interfaces réseau${RESET}\n"
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        
        interfaces=$(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | cut -d: -f1)
        if [ -t 0 ] && [ -t 1 ] && command -v fzf >/dev/null 2>&1; then
            picked_iface=$(
                ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | cut -d: -f1 | \
                netman_fzf_pick_line "Interfaces" 'printf "%s\n" "{}"'
            )
            if [ -n "$picked_iface" ]; then
                netman_show_interface_details "$picked_iface"
            else
                for iface in $interfaces; do
                    netman_show_interface_details "$iface"
                done
            fi
        else
            for iface in $interfaces; do
                netman_show_interface_details "$iface"
            done
        fi
        
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
        manager_ui_section_line "${BLUE}" "${RESET}\n"
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
        manager_ui_section_line "${BLUE}" "${RESET}\n"
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
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        
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
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        echo ""

        host="${1:-}"
        if [ -z "$host" ] && [ -t 0 ] && [ -t 1 ]; then
            printf "Entrez l'hôte à tester (défaut: google.com): "
            read host
        fi
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
        manager_ui_section_line "${BLUE}" "${RESET}\n"
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
                test_urls="https://proof.ovh.net/files/10Mb.dat https://speed.hetzner.de/10MB.bin"
                ;;
            100M|100m)
                label="100MB"
                test_urls="https://proof.ovh.net/files/100Mb.dat https://speed.hetzner.de/100MB.bin"
                ;;
            1G|1g)
                label="1GB"
                test_urls="https://proof.ovh.net/files/1Gb.dat https://speed.hetzner.de/1GB.bin"
                ;;
            5G|5g)
                label="5GB"
                test_urls="https://proof.ovh.net/files/5Gb.dat https://speed.hetzner.de/5GB.bin"
                ;;
            *)
                printf "${YELLOW}⚠ Taille inconnue '%s', fallback 5G${RESET}\n" "$size_arg"
                label="5GB"
                test_urls="https://proof.ovh.net/files/5Gb.dat https://speed.hetzner.de/5GB.bin"
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
        : > /tmp/netman_speed_result.$$
        for candidate_url in $test_urls; do
            [ -z "$candidate_url" ] && continue
            curl_out=$(curl -L -s --output /dev/null -w "%{size_download} %{time_total}" "$candidate_url" 2>/dev/null)
            rc=$?
            dl=$(echo "$curl_out" | awk '{print $1}')
            tt=$(echo "$curl_out" | awk '{print $2}')
            if [ "$rc" -eq 0 ] && awk -v b="$dl" 'BEGIN { exit !(b+0 > 0) }'; then
                echo "$candidate_url|$dl|$tt" > /tmp/netman_speed_result.$$
                break
            fi
        done

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
        manager_ui_section_line "${BLUE}" "${RESET}\n"
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
            
            printf "\r  ↓ RX: %-12s  ↑ TX: %-12s  [Appuyez sur '0' ou 'q' puis Entrée pour quitter]" "$rx_formatted" "$tx_formatted"
            
            # Vérifier si 'q' a été pressé (non-bloquant)
            if read -t 0.1 key 2>/dev/null; then
                case "$key" in
                    0|q|Q|quit|exit)
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
        manager_ui_section_line "${BLUE}" "${RESET}\n"
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
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        
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
    # Convention : sans arg / help / -h = stdout ; help <cmd> = aide sous-commande ;
    # help --interactive = aide TTY ; menu | --interactive = menu TUI.
    if [ -z "${1:-}" ]; then
        netman_print_quick_help
        return 0
    fi
    if [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        case "${2:-}" in
        --interactive|-i)
            if [ -t 0 ] && [ -t 1 ]; then
                netman_interactive_help_cli
            else
                printf '%s\n' "netman: help --interactive nécessite un terminal (TTY)." >&2
                netman_print_quick_help
            fi
            return 0
            ;;
        "")
            netman_print_quick_help
            return 0
            ;;
        *)
            # netman help dig | netman help lookup …
            netman_print_cmd_help "$2"
            return $?
            ;;
        esac
    fi

    # Menu TUI — traité AVANT le case CLI (sinon « Commande inconnue »)
    if [ "$1" = "menu" ] || [ "$1" = "--interactive" ]; then
        if ! { [ -t 0 ] && [ -t 1 ]; }; then
            printf '%s\n' "netman: menu nécessite un terminal (TTY)." >&2
            return 2
        fi
        while true; do
            show_header
            printf "${GREEN}Menu Principal${RESET}\n"
            manager_ui_section_line "${BLUE}" "${RESET}\n"
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
            echo "  ${BOLD}j${RESET}  🔎 Lookup IP / domaine / URL"
            echo "  ${BOLD}p${RESET}  🕵️  Probe soft recon"
            echo "  ${BOLD}n${RESET}  📡 Voisins ARP/NDP (neigh)"
            echo "  ${BOLD}l${RESET}  🏠 Découverte LAN"
            echo "  ${BOLD}t${RESET}  🧭 Traceroute / tracepath"
            echo "  ${BOLD}m${RESET}  🧪 MTR (latence/pertes)"
            echo "  ${BOLD}w${RESET}  📄 WHOIS détaillé"
            echo "  ${BOLD}a${RESET}  🌐 Test de connectivité (ping/traceroute)"
            echo "  ${BOLD}b${RESET}  ⚡ Test de vitesse réseau"
            echo "  ${BOLD}c${RESET}  📊 Monitoring bande passante (temps réel)"
            echo "  ${BOLD}d${RESET}  🔍 Analyse du trafic réseau"
            echo "  ${BOLD}x${RESET}  💾 Exporter la configuration"
            echo ""
            echo "  ${BOLD}h${RESET}  📚 Aide"
            echo "  ${BOLD}q${RESET}  🚪 Quitter"
            echo ""
            manager_ui_section_line "${BLUE}" "${RESET}\n"
            choice=""
            if [ -t 0 ] && [ -t 1 ]; then
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
Lookup IP / domaine / URL|j
Probe soft recon|p
Voisins ARP/NDP (neigh)|n
Decouverte LAN|l
Traceroute / tracepath|t
MTR (latence/pertes)|m
WHOIS detaille|w
Test de connectivite (ping/traceroute)|a
Test de vitesse reseau|b
Monitoring bande passante (temps reel)|c
Analyse du trafic reseau|d
Exporter la configuration|x
Aide|h
Quitter|0
Quitter|q
EOF
                choice=$(netman_dotcli_menu_pick "NETMAN - Menu principal" "$menu_input_file" || true)
                if [ -z "$choice" ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
                    choice=$(dotfiles_ncmenu_select "NETMAN - Menu principal" < "$menu_input_file" 2>/dev/null || true)
                fi
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
                p|P)
                    printf "Cible probe (IP/domaine/URL): "
                    read _probe_t
                    [ -n "$_probe_t" ] && netman_cmd_probe "$_probe_t"
                    pause_if_tty
                    ;;
                n|N) netman_cmd_neigh; pause_if_tty ;;
                l|L) netman_cmd_lan; pause_if_tty ;;
                t|T) network_trace ;;
                m|M) network_mtr ;;
                w|W) network_whois ;;
                a|A) test_connectivity ;;
                b|B) test_network_speed ;;
                c|C) monitor_bandwidth ;;
                d|D) analyze_traffic ;;
                x|X) export_network_config ;;
                h|H)
                    show_header
                    netman_print_quick_help
                    pause_if_tty
                    ;;
                0|q|Q|quit|exit)
                    printf "${GREEN}Au revoir!${RESET}\n"
                    break
                    ;;
                *)
                    printf "${RED}Option invalide${RESET}\n"
                    sleep 1
                    ;;
            esac
        done
        return 0
    fi

    # --- CLI non-interactif -------------------------------------------------
    _nmdf="${DOTFILES_DIR:-$HOME/dotfiles}"
    if [ -f "$_nmdf/scripts/lib/managers_log_posix.sh" ]; then
        # shellcheck source=managers_log_posix.sh
        . "$_nmdf/scripts/lib/managers_log_posix.sh"
        managers_cli_log netman "$@"
    fi
    case "$1" in
        ports)
            if [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help ports
            else
                manage_ports
            fi
            ;;
        connections|conn)
            if [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help connections
            else
                show_connections
            fi
            ;;
        ip|ipinfo)
            if [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help ip
            else
                show_ip_info
            fi
            ;;
        dns)
            if [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help dns
            else
                show_dns_info
            fi
            ;;
        dig|dns-query)
            shift
            netman_cmd_dig "$@"
            ;;
        routing|route)
            if [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help routing
            else
                show_routing
            fi
            ;;
        routeman|routes|route-manager)
            shift
            launch_routeman "$@"
            ;;
        interfaces|iface)
            if [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help interfaces
            else
                show_interfaces
            fi
            ;;
        scan)
            if [ -z "${2:-}" ] || [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help scan
            else
                host=$(netman_normalize_host "$2")
                [ -n "$host" ] || host="$2"
                port="${3:-80}"
                printf "Scan du port %s sur %s...\n" "$port" "$host"
                if timeout 2 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
                    printf "${GREEN}✓ Port %s OUVERT${RESET}\n" "$port"
                else
                    printf "${RED}✗ Port %s FERMÉ${RESET}\n" "$port"
                fi
            fi
            ;;
        kill)
            if [ -z "${2:-}" ] || [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help kill
            else
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
            fi
            ;;
        stats)
            if [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help stats
            else
                show_network_stats
            fi
            ;;
        diagnose|diag|health)
            if [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help diagnose
            else
                network_diagnose
            fi
            ;;
        diagnose-report|diag-report)
            network_diagnose_report "$@"
            ;;
        dns-bench|dnsbench)
            if [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help dns-bench
            else
                dns_benchmark "$2"
            fi
            ;;
        diagnose-deep|diag-deep|health-deep)
            network_diagnose_deep
            ;;
        firewall|fw)
            if [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help firewall
            else
                firewall_status
            fi
            ;;
        lookup|resolve)
            shift
            netman_cmd_lookup "$@"
            ;;
        probe|recon)
            shift
            netman_cmd_probe "$@"
            ;;
        neigh|arp|neighbors)
            shift
            netman_cmd_neigh "$@"
            ;;
        lan|discover|lan-scan)
            shift
            netman_cmd_lan "$@"
            ;;
        trace|traceroute|tracepath)
            if [ -z "${2:-}" ] || [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help trace
            else
                network_trace "$2"
            fi
            ;;
        mtr)
            if [ -z "${2:-}" ] || [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help mtr
            else
                network_mtr "$2"
            fi
            ;;
        whois)
            if [ -z "${2:-}" ] || [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help whois
            else
                network_whois "$2"
            fi
            ;;
        connectivity|ping)
            if [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help connectivity
            else
                test_connectivity "$2"
            fi
            ;;
        speed)
            if [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help speed
            else
                test_network_speed "$2"
            fi
            ;;
        monitor|bandwidth)
            if [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help monitor
            else
                monitor_bandwidth
            fi
            ;;
        analyze|traffic)
            if [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help analyze
            else
                analyze_traffic
            fi
            ;;
        export)
            if [ "${2:-}" = "help" ] || [ "${2:-}" = "-h" ]; then
                netman_print_cmd_help export
            else
                export_network_config
            fi
            ;;
        tor)
            shift
            if [ -f "${DOTFILES_DIR:-$HOME/dotfiles}/core/managers/anonyman/core/anonyman.sh" ]; then
                # shellcheck source=/dev/null
                . "${DOTFILES_DIR:-$HOME/dotfiles}/core/managers/anonyman/core/anonyman.sh"
                anonyman tor "${1:-status}"
            else
                printf "${YELLOW}anonyman introuvable — installman tor${RESET}\n" >&2
                return 1
            fi
            ;;
        i2p|i2pd)
            shift
            if [ -f "${DOTFILES_DIR:-$HOME/dotfiles}/core/managers/anonyman/core/anonyman.sh" ]; then
                # shellcheck source=/dev/null
                . "${DOTFILES_DIR:-$HOME/dotfiles}/core/managers/anonyman/core/anonyman.sh"
                anonyman i2p "${1:-status}"
            else
                printf "${YELLOW}anonyman introuvable — installman i2p · configman i2p${RESET}\n" >&2
                return 1
            fi
            ;;
        *)
            printf "${RED}Commande inconnue: %s${RESET}\n" "$1" >&2
            echo "Utilisez 'netman help' ou 'helpman netman'" >&2
            echo "Aide d'une sous-commande : netman help dig | netman help lookup" >&2
            return 1
            ;;
    esac
    return $?
}
