#!/bin/sh
# =============================================================================
# PROCESSMAN - Process Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire interactif de processus (recherche, signal, restart)
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

# DESC: Gestionnaire de processus (chercher, inspecter, kill, restart, signaux)
# USAGE: processman [command]
# EXAMPLE: processman
# EXAMPLE: processman search nginx
# EXAMPLE: processman restart 1234
processman() {
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

    _pm_header() {
        clear
        printf "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                 PROCESSMAN - Process Manager                  ║"
        echo "║           Recherche, contrôle et restart des process          ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
        echo ""
    }

    _pm_wait() {
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée pour continuer... "
            read dummy
        fi
    }

    _pm_is_pid() {
        case "$1" in
            ''|*[!0-9]*) return 1 ;;
            *) return 0 ;;
        esac
    }

    _pm_list() {
        printf "${YELLOW}📋 Processus actifs (top CPU)${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        printf "%-7s %-7s %-10s %-6s %-6s %-8s %-18s %s\n" "PID" "PPID" "USER" "CPU%" "MEM%" "STATE" "CMD" "ARGS"
        ps -eo pid=,ppid=,user=,%cpu=,%mem=,stat=,comm=,args= --sort=-%cpu 2>/dev/null | head -20
    }

    _pm_search() {
        pattern="$1"
        if [ -z "$pattern" ]; then
            printf "${RED}❌ Pattern requis (ex: processman search nginx)${RESET}\n"
            return 1
        fi
        printf "${YELLOW}🔍 Résultats pour '${pattern}'${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        printf "%-7s %-7s %-10s %-6s %-6s %-8s %-18s %s\n" "PID" "PPID" "USER" "CPU%" "MEM%" "STATE" "CMD" "ARGS"
        ps -eo pid=,ppid=,user=,%cpu=,%mem=,stat=,comm=,args= 2>/dev/null | grep -i -- "$pattern" | grep -v "grep -i -- $pattern" | head -30
    }

    _pm_info() {
        pid="$1"
        if ! _pm_is_pid "$pid"; then
            printf "${RED}❌ PID invalide${RESET}\n"
            return 1
        fi
        if ! ps -p "$pid" >/dev/null 2>&1; then
            printf "${RED}❌ PID %s introuvable${RESET}\n" "$pid"
            return 1
        fi
        printf "${YELLOW}ℹ️  Détails du processus %s${RESET}\n" "$pid"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        ps -p "$pid" -o pid,ppid,user,%cpu,%mem,stat,etime,lstart,comm,args 2>/dev/null
    }

    _pm_signal() {
        signal="$1"
        target="$2"
        if [ -z "$signal" ] || [ -z "$target" ]; then
            printf "${RED}❌ Usage: processman signal <SIGNAL> <PID>${RESET}\n"
            return 1
        fi
        if ! _pm_is_pid "$target"; then
            printf "${RED}❌ PID invalide${RESET}\n"
            return 1
        fi
        if kill "-$signal" "$target" 2>/dev/null; then
            printf "${GREEN}✅ Signal %s envoyé à PID %s${RESET}\n" "$signal" "$target"
        else
            printf "${RED}❌ Échec envoi signal %s à PID %s${RESET}\n" "$signal" "$target"
            return 1
        fi
    }

    _pm_kill() {
        target="$1"
        mode="${2:-TERM}"
        if [ -z "$target" ]; then
            printf "${RED}❌ Usage: processman kill <PID|pattern> [TERM|KILL]${RESET}\n"
            return 1
        fi

        if _pm_is_pid "$target"; then
            if kill "-$mode" "$target" 2>/dev/null; then
                printf "${GREEN}✅ PID %s terminé (%s)${RESET}\n" "$target" "$mode"
            else
                printf "${RED}❌ Impossible de terminer PID %s${RESET}\n" "$target"
                return 1
            fi
            return 0
        fi

        pids=$(ps -eo pid=,args= 2>/dev/null | grep -i -- "$target" | grep -v "grep -i -- $target" | awk '{print $1}')
        if [ -z "$pids" ]; then
            printf "${YELLOW}⚠️ Aucun processus trouvé pour '%s'${RESET}\n" "$target"
            return 1
        fi

        for pid in $pids; do
            kill "-$mode" "$pid" 2>/dev/null && printf "${GREEN}✅ PID %s terminé (%s)${RESET}\n" "$pid" "$mode" || printf "${RED}❌ Échec PID %s${RESET}\n" "$pid"
        done
    }

    _pm_restart_pid() {
        pid="$1"
        if ! _pm_is_pid "$pid"; then
            printf "${RED}❌ PID invalide${RESET}\n"
            return 1
        fi
        cmdline=$(ps -p "$pid" -o args= 2>/dev/null)
        if [ -z "$cmdline" ]; then
            printf "${RED}❌ Impossible de lire la commande du PID %s${RESET}\n" "$pid"
            return 1
        fi

        printf "${YELLOW}Commande capturée:${RESET} %s\n" "$cmdline"
        if ! [ -t 0 ] || ! [ -t 1 ]; then
            printf "${YELLOW}⚠️ Restart interactif indisponible sans TTY${RESET}\n"
            return 1
        fi
        printf "Confirmer restart du PID %s ? [y/N]: " "$pid"
        read confirm
        case "$confirm" in
            [yY]*)
                if kill -TERM "$pid" 2>/dev/null; then
                    sleep 1
                    nohup sh -c "$cmdline" >/dev/null 2>&1 &
                    new_pid=$!
                    printf "${GREEN}✅ Restart lancé (nouveau PID: %s)${RESET}\n" "$new_pid"
                else
                    printf "${RED}❌ Impossible d'arrêter PID %s${RESET}\n" "$pid"
                    return 1
                fi
                ;;
            *)
                printf "${YELLOW}Restart annulé${RESET}\n"
                ;;
        esac
    }

    _pm_restart_pattern() {
        pattern="$1"
        if [ -z "$pattern" ]; then
            printf "${RED}❌ Usage: processman restart <PID|pattern>${RESET}\n"
            return 1
        fi
        pids=$(ps -eo pid=,args= 2>/dev/null | grep -i -- "$pattern" | grep -v "grep -i -- $pattern" | awk '{print $1}')
        if [ -z "$pids" ]; then
            printf "${YELLOW}⚠️ Aucun processus trouvé pour '%s'${RESET}\n" "$pattern"
            return 1
        fi
        for pid in $pids; do
            _pm_restart_pid "$pid"
        done
    }

    _pm_show_help() {
        printf "${CYAN}📚 Aide PROCESSMAN${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "Commandes directes:"
        echo "  processman list                          - Top process par CPU"
        echo "  processman search <pattern>              - Recherche par nom/commande"
        echo "  processman info <pid>                    - Détails d'un PID"
        echo "  processman kill <pid|pattern>            - Arrêt gracieux (TERM)"
        echo "  processman force-kill <pid|pattern>      - Arrêt forcé (KILL)"
        echo "  processman stop <pid>                    - Pause (SIGSTOP)"
        echo "  processman continue <pid>                - Reprise (SIGCONT)"
        echo "  processman signal <SIGNAL> <pid>         - Signal custom"
        echo "  processman restart <pid|pattern>         - Relance process"
        echo "  processman tree                          - Arbre process"
        echo ""
    }

    if [ -n "$1" ]; then
        case "$1" in
            list|ls)
                _pm_list
                ;;
            search|find)
                _pm_search "$2"
                ;;
            info|inspect)
                _pm_info "$2"
                ;;
            kill)
                _pm_kill "$2" "TERM"
                ;;
            force-kill|kill9)
                _pm_kill "$2" "KILL"
                ;;
            stop)
                _pm_signal "STOP" "$2"
                ;;
            continue|cont|resume)
                _pm_signal "CONT" "$2"
                ;;
            signal)
                _pm_signal "$2" "$3"
                ;;
            restart)
                if _pm_is_pid "$2"; then
                    _pm_restart_pid "$2"
                else
                    _pm_restart_pattern "$2"
                fi
                ;;
            tree)
                if command -v pstree >/dev/null 2>&1; then
                    pstree -ap
                else
                    ps -eo pid,ppid,user,comm,args --forest 2>/dev/null
                fi
                ;;
            help|--help|-h)
                _pm_show_help
                ;;
            *)
                printf "${RED}Commande inconnue: %s${RESET}\n" "$1"
                echo "Utilisez 'processman help'."
                return 1
                ;;
        esac
        return
    fi

    while true; do
        _pm_header
        printf "${GREEN}Menu Principal${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "  ${BOLD}1${RESET}  📋 Lister les processus (top CPU)"
        echo "  ${BOLD}2${RESET}  🔍 Rechercher un processus"
        echo "  ${BOLD}3${RESET}  ℹ️  Détails d'un PID"
        echo "  ${BOLD}4${RESET}  🛑 Kill (TERM)"
        echo "  ${BOLD}5${RESET}  💀 Force Kill (KILL)"
        echo "  ${BOLD}6${RESET}  ⏸️  Stop (SIGSTOP)"
        echo "  ${BOLD}7${RESET}  ▶️  Continue (SIGCONT)"
        echo "  ${BOLD}8${RESET}  🔁 Restart"
        echo "  ${BOLD}9${RESET}  🌳 Arbre des processus"
        echo ""
        echo "  ${BOLD}h${RESET}  📚 Aide"
        echo "  ${BOLD}q${RESET}  🚪 Quitter"
        echo ""
        choice=""
        if [ -t 0 ] && [ -t 1 ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
            menu_input_file=$(mktemp)
            cat > "$menu_input_file" <<'EOF'
Lister les processus (top CPU)|1
Rechercher un processus|2
Details d'un PID|3
Kill (TERM)|4
Force Kill (KILL)|5
Stop (SIGSTOP)|6
Continue (SIGCONT)|7
Restart|8
Arbre des processus|9
Aide|h
Quitter|q
EOF
            choice=$(dotfiles_ncmenu_select "PROCESSMAN - Menu principal" < "$menu_input_file" 2>/dev/null || true)
            rm -f "$menu_input_file"
            echo ""
        fi
        if [ -z "$choice" ]; then
            printf "Votre choix: "
            read choice
            echo ""
        fi

        case "$choice" in
            1)
                _pm_header
                _pm_list
                _pm_wait
                ;;
            2)
                printf "Pattern de recherche: "
                read pattern
                _pm_header
                _pm_search "$pattern"
                _pm_wait
                ;;
            3)
                printf "PID: "
                read pid
                _pm_header
                _pm_info "$pid"
                _pm_wait
                ;;
            4)
                printf "PID ou pattern: "
                read target
                _pm_header
                _pm_kill "$target" "TERM"
                _pm_wait
                ;;
            5)
                printf "PID ou pattern: "
                read target
                _pm_header
                _pm_kill "$target" "KILL"
                _pm_wait
                ;;
            6)
                printf "PID: "
                read pid
                _pm_header
                _pm_signal "STOP" "$pid"
                _pm_wait
                ;;
            7)
                printf "PID: "
                read pid
                _pm_header
                _pm_signal "CONT" "$pid"
                _pm_wait
                ;;
            8)
                printf "PID ou pattern: "
                read target
                _pm_header
                if _pm_is_pid "$target"; then
                    _pm_restart_pid "$target"
                else
                    _pm_restart_pattern "$target"
                fi
                _pm_wait
                ;;
            9)
                _pm_header
                if command -v pstree >/dev/null 2>&1; then
                    pstree -ap
                else
                    ps -eo pid,ppid,user,comm,args --forest 2>/dev/null
                fi
                _pm_wait
                ;;
            h|H)
                _pm_header
                _pm_show_help
                _pm_wait
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
}

