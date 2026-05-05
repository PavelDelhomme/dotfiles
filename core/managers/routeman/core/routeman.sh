#!/bin/sh
# =============================================================================
# ROUTEMAN - Route Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire des routes IP (visualiser, ajouter, modifier, supprimer)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_TYPE="fish"
else
    SHELL_TYPE="sh"
fi

# DESC: Gestionnaire de routes IP (ajout, suppression, modification, visualisation)
# USAGE: routeman [show|add|del|replace]
# EXAMPLE: routeman
# EXAMPLE: routeman show
# EXAMPLE: routeman add "10.10.0.0/24" "192.168.1.1" "eth0" 100
routeman() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    if [ -f "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh"
    fi

    _rm_header() {
        clear
        printf "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                     ROUTEMAN - Route Manager                  ║"
        echo "║        Gestion des routes IP (add/del/replace/show)          ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
        echo ""
    }

    _rm_wait() {
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée pour continuer... "
            read dummy
        fi
    }

    _rm_run_ip() {
        if [ "$(id -u)" -eq 0 ]; then
            ip "$@"
        elif command -v sudo >/dev/null 2>&1; then
            sudo ip "$@"
        else
            printf "${RED}❌ sudo requis pour modifier les routes${RESET}\n"
            return 1
        fi
    }

    _rm_show() {
        printf "${YELLOW}📋 Routes IPv4${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        ip -4 route show 2>/dev/null | sed 's/^/  /'
        echo ""
        printf "${YELLOW}📋 Routes IPv6${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        ip -6 route show 2>/dev/null | sed 's/^/  /'
    }

    _rm_add() {
        network="$1"
        gateway="$2"
        dev="$3"
        metric="$4"
        if [ -z "$network" ]; then
            printf "${RED}❌ Usage: routeman add <reseau/cidr> [gateway] [interface] [metric]${RESET}\n"
            return 1
        fi
        cmd="route add $network"
        [ -n "$gateway" ] && cmd="$cmd via $gateway"
        [ -n "$dev" ] && cmd="$cmd dev $dev"
        [ -n "$metric" ] && cmd="$cmd metric $metric"

        if _rm_run_ip $cmd; then
            printf "${GREEN}✅ Route ajoutée: %s${RESET}\n" "$network"
        else
            printf "${RED}❌ Échec ajout route${RESET}\n"
            return 1
        fi
    }

    _rm_del() {
        network="$1"
        if [ -z "$network" ]; then
            printf "${RED}❌ Usage: routeman del <reseau/cidr|default>${RESET}\n"
            return 1
        fi
        if _rm_run_ip route del "$network"; then
            printf "${GREEN}✅ Route supprimée: %s${RESET}\n" "$network"
        else
            printf "${RED}❌ Échec suppression route${RESET}\n"
            return 1
        fi
    }

    _rm_replace() {
        network="$1"
        gateway="$2"
        dev="$3"
        metric="$4"
        if [ -z "$network" ]; then
            printf "${RED}❌ Usage: routeman replace <reseau/cidr> [gateway] [interface] [metric]${RESET}\n"
            return 1
        fi
        cmd="route replace $network"
        [ -n "$gateway" ] && cmd="$cmd via $gateway"
        [ -n "$dev" ] && cmd="$cmd dev $dev"
        [ -n "$metric" ] && cmd="$cmd metric $metric"
        if _rm_run_ip $cmd; then
            printf "${GREEN}✅ Route modifiée: %s${RESET}\n" "$network"
        else
            printf "${RED}❌ Échec modification route${RESET}\n"
            return 1
        fi
    }

    _rm_prompt_add() {
        if ! [ -t 0 ] || ! [ -t 1 ]; then
            printf "${YELLOW}⚠️ Ajout interactif indisponible sans TTY${RESET}\n"
            return 1
        fi
        printf "Réseau/CIDR (ex: 10.10.0.0/24): "
        read network
        printf "Gateway (optionnel): "
        read gateway
        printf "Interface (optionnel): "
        read dev
        printf "Metric (optionnel): "
        read metric
        _rm_add "$network" "$gateway" "$dev" "$metric"
    }

    _rm_prompt_replace() {
        if ! [ -t 0 ] || ! [ -t 1 ]; then
            printf "${YELLOW}⚠️ Modification interactive indisponible sans TTY${RESET}\n"
            return 1
        fi
        printf "Réseau/CIDR à modifier (ex: 10.10.0.0/24): "
        read network
        printf "Nouvelle gateway (optionnel): "
        read gateway
        printf "Nouvelle interface (optionnel): "
        read dev
        printf "Nouvelle metric (optionnel): "
        read metric
        _rm_replace "$network" "$gateway" "$dev" "$metric"
    }

    _rm_prompt_del() {
        if ! [ -t 0 ] || ! [ -t 1 ]; then
            printf "${YELLOW}⚠️ Suppression interactive indisponible sans TTY${RESET}\n"
            return 1
        fi
        printf "Route à supprimer (reseau/cidr ou default): "
        read network
        _rm_del "$network"
    }

    _rm_help() {
        printf "${CYAN}📚 Aide ROUTEMAN${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "Commandes:"
        echo "  routeman show"
        echo "  routeman add <reseau/cidr> [gateway] [interface] [metric]"
        echo "  routeman del <reseau/cidr|default>"
        echo "  routeman replace <reseau/cidr> [gateway] [interface] [metric]"
        echo ""
        echo "Exemples:"
        echo "  routeman add 10.10.0.0/24 192.168.1.1 eth0 100"
        echo "  routeman replace default 192.168.1.254 eth0 50"
        echo "  routeman del 10.10.0.0/24"
        echo ""
        echo "Sans argument ou routeman --help : menu interactif"
    }

    if [ -z "$1" ] || [ "$1" = "--help" ]; then
        :
    elif [ -n "$1" ]; then
        case "$1" in
            show|list)
                _rm_show
                ;;
            add)
                _rm_add "$2" "$3" "$4" "$5"
                ;;
            del|delete|rm)
                _rm_del "$2"
                ;;
            replace|mod|modify|update)
                _rm_replace "$2" "$3" "$4" "$5"
                ;;
            help|-h)
                _rm_help
                ;;
            *)
                printf "${RED}Commande inconnue: %s${RESET}\n" "$1"
                echo "Utilisez 'routeman help'."
                return 1
                ;;
        esac
        return
    fi

    if [ -z "$1" ] || [ "$1" = "--help" ]; then
        if [ "$1" = "--help" ]; then
            routeman help
            if ! { [ -t 0 ] && [ -t 1 ]; }; then
                return 0
            fi
            _rm_wait
        fi
        while true; do
        _rm_header
        echo "  ${BOLD}1${RESET}  📋 Visualiser les routes"
        echo "  ${BOLD}2${RESET}  ➕ Ajouter une route"
        echo "  ${BOLD}3${RESET}  ✏️  Modifier une route"
        echo "  ${BOLD}4${RESET}  ➖ Supprimer une route"
        echo ""
        echo "  ${BOLD}h${RESET}  📚 Aide"
        echo "  ${BOLD}q${RESET}  🚪 Quitter"
        echo ""
        choice=""
        if [ -t 0 ] && [ -t 1 ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
            menu_input_file=$(mktemp)
            cat > "$menu_input_file" <<'EOF'
Visualiser les routes|1
Ajouter une route|2
Modifier une route|3
Supprimer une route|4
Aide|h
Quitter|q
EOF
            choice=$(dotfiles_ncmenu_select "ROUTEMAN - Menu principal" < "$menu_input_file" 2>/dev/null || true)
            rm -f "$menu_input_file"
            echo ""
        fi
        if [ -z "$choice" ]; then
            printf "Votre choix (validez avec Entrée): "
            read choice
            echo ""
        fi
        case "$choice" in
            1) _rm_header; _rm_show; _rm_wait ;;
            2) _rm_header; _rm_prompt_add; _rm_wait ;;
            3) _rm_header; _rm_prompt_replace; _rm_wait ;;
            4) _rm_header; _rm_prompt_del; _rm_wait ;;
            h|H) _rm_header; _rm_help; _rm_wait ;;
            q|Q) printf "${GREEN}Au revoir!${RESET}\n"; break ;;
            *) printf "${RED}Option invalide${RESET}\n"; sleep 1 ;;
        esac
        done
    fi
}

