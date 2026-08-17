#!/bin/sh
# =============================================================================
# MANMAN - Manager of Managers (Code Commun POSIX)
# =============================================================================
# Ordre logique : aide → diagnostic → config/shell → install/update → outils
# Icônes ASCII toujours lisibles (+ emoji optionnel si DOTFILES_MANMAN_EMOJI=1)
# Pagination TUI : n/p, 0=quitter
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

manman() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    DIM='\033[2m'

    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    DOTFILES_FUNCTIONS_DIR="$DOTFILES_DIR/zsh/functions"
    MANMAN_EMOJI="${DOTFILES_MANMAN_EMOJI:-0}"
    MANMAN_PER_PAGE="${DOTFILES_MANMAN_PER_PAGE:-0}"

    if [ -f "$DOTFILES_DIR/scripts/lib/managers_log_posix.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/managers_log_posix.sh"
        managers_log_line "manman" "invoke" "menu" "info" "session interactive" 2>/dev/null || true
    fi
    if [ -f "$DOTFILES_DIR/scripts/lib/manager_ui.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/manager_ui.sh"
        command -v dotfiles_manager_load_ui_libs >/dev/null 2>&1 && dotfiles_manager_load_ui_libs
    elif [ -f "$DOTFILES_DIR/scripts/lib/tui_core.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/tui_core.sh"
    fi
    if [ -f "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh"
    fi

    manman_print_help() {
        printf "${CYAN}${BOLD}MANMAN${RESET} — catalogue des gestionnaires (*man)\n\n"
        printf "  manman                 menu pagine (TTY)\n"
        printf "  manman list            liste stdout (non interactif)\n"
        printf "  manman help | -h       cette aide\n"
        printf "  manman --help          aide (+ pause TTY)\n\n"
        printf "Legende statut : ${GREEN}[OK]${RESET} charge  ${YELLOW}[--]${RESET} absent  ${CYAN}[^]${RESET} dans registre updateman\n"
        printf "Icones ASCII toujours affichees ; emoji si DOTFILES_MANMAN_EMOJI=1\n"
        printf "Pagination : n=suivant p=precedent 0=quitter\n"
    }

    # Catalogue ordonne : ascii|emoji|name|desc|cmd
    # Ordre : aide → diag → config/shell → install → domaine → tests
    _manman_catalog() {
        cat <<'EOF'
[?]|📚|helpman|Aide / documentation|helpman
[!]|🩺|doctorman|Diagnostic dotfiles / dev|doctorman
[=]|⚙️|configman|Configuration systeme|configman
[$]|🐚|shellman|Bascule shells (session/user/system)|shellman
[P]|📁|pathman|Gestionnaire PATH|pathman
[+]|📦|installman|Installation d outils|installman
[^]|⬆️|updateman|Mises a jour locales / systeme|updateman
[#]|⚙️|moduleman|Modules dotfiles|moduleman
[@]|📝|aliaman|Alias|aliaman
[G]|🔧|gitman|Git|gitman
[F]|📁|fileman|Fichiers / archives|fileman
[/]|🔍|searchman|Recherche executables|searchman
[N]|🌐|netman|Reseau|netman
[R]|🧭|routeman|Routes IP|routeman
[S]|🔐|sshman|SSH|sshman
[*]|⚙️|processman|Processus|processman
[C]|🛡️|cyberman|Cybersecurite|cyberman
[A]|🕵️|anonyman|Anonymisation Tor/I2P/proxies|anonyman
[L]|📖|cyberlearn|Apprentissage cyber|cyberlearn
[D]|💻|devman|Developpement|devman
[V]|🖥️|virtman|Virtualisation|virtman
[O]|🐳|dockerman|Docker (ps/images/compose/cheat)|dockerman
[E]|🖥|displayman|Ecran / luminosite DDC|displayman
[K]|💽|diskman|Disque / nettoyage|diskman
[X]|📑|diffman|Comparaison de fichiers|diffman
[M]|🎬|multimediaman|Multimedia|multimediaman
[~]|🔧|miscman|Outils divers|miscman
[T]|🧪|testman|Tests applications|testman
[Z]|🧪|testzshman|Tests ZSH / dotfiles|testzshman
EOF
    }

    _manman_icon() {
        _ascii="$1"
        _emoji="$2"
        if [ "$MANMAN_EMOJI" = "1" ] && [ -n "$_emoji" ]; then
            printf '%s' "$_emoji"
        else
            printf '%s' "$_ascii"
        fi
    }

    _manman_status() {
        _name="$1"
        _cmd="$2"
        _st="--"
        _core="$DOTFILES_DIR/core/managers/$_name/core/${_name}.sh"
        _zshf="$DOTFILES_FUNCTIONS_DIR/${_name}.zsh"
        if command -v "$_cmd" >/dev/null 2>&1 || [ -f "$_core" ] || [ -f "$_zshf" ]; then
            _st="OK"
        fi
        _reg="$DOTFILES_DIR/core/managers/updateman/config/updatable-tools.list"
        if [ -f "$_reg" ] && grep -qE "^${_name}\\|" "$_reg" 2>/dev/null; then
            if [ "$_st" = "OK" ]; then
                _st="OK^"
            fi
        fi
        printf '%s' "$_st"
    }

    _manman_build_list() {
        _out="$1"
        : >"$_out"
        _idx=1
        while IFS='|' read -r _ascii _emoji _name _desc _cmd; do
            [ -z "$_name" ] && continue
            case "$_name" in \#*) continue ;; esac
            _st="$(_manman_status "$_name" "$_cmd")"
            _ic="$(_manman_icon "$_ascii" "$_emoji")"
            printf '%s|%s|%s|%s|%s|%s\n' "$_idx" "$_ic" "$_name" "$_desc" "$_cmd" "$_st" >>"$_out"
            _idx=$((_idx + 1))
        done <<EOF
$(_manman_catalog)
EOF
    }

    _manman_print_rows() {
        _file="$1"
        _start="$2"
        _end="$3"
        _n=0
        while IFS='|' read -r num ic name desc cmd st; do
            _n=$((_n + 1))
            [ "$_n" -lt "$_start" ] && continue
            [ "$_n" -gt "$_end" ] && break
            case "$st" in
                OK)   _sc="${GREEN}[OK]${RESET}" ;;
                OK^)  _sc="${CYAN}[OK^]${RESET}" ;;
                *)    _sc="${YELLOW}[--]${RESET}" ;;
            esac
            printf "  ${BOLD}%2s${RESET} %s  %-14s %-36s %b\n" "$num" "$ic" "$name" "$desc" "$_sc"
        done <"$_file"
    }

    manman_list() {
        _mf=$(mktemp)
        _manman_build_list "$_mf"
        printf "${CYAN}${BOLD}MANMAN — catalogue${RESET}\n\n"
        printf "  ${BOLD}##${RESET} ic  %-14s %-36s statut\n" "nom" "description"
        _manman_print_rows "$_mf" 1 999
        printf "\n${DIM}[OK]=disponible  [OK^]=aussi registre updateman  [--]=core/commande absents${RESET}\n"
        rm -f "$_mf"
    }

    if [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "aide" ]; then
        manman_print_help
        return 0
    fi
    if [ "$1" = "--help" ]; then
        manman_print_help
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée... "
            read -r _ || true
        fi
        return 0
    fi
    if [ "$1" = "list" ] || [ "$1" = "ls" ]; then
        manman_list
        return 0
    fi

    # Non-TTY : liste seulement
    if ! { [ -t 0 ] && [ -t 1 ]; }; then
        manman_list
        return 0
    fi

    managers_file=$(mktemp)
    _manman_build_list "$managers_file"
    manager_count=$(wc -l <"$managers_file" | tr -d ' ')
    if [ "${manager_count:-0}" -eq 0 ]; then
        printf "${RED}Aucun gestionnaire dans le catalogue${RESET}\n" >&2
        rm -f "$managers_file"
        return 1
    fi

    per_page="$MANMAN_PER_PAGE"
    if [ "$per_page" = "0" ] || [ -z "$per_page" ]; then
        if command -v tui_menu_height >/dev/null 2>&1; then
            per_page=$(tui_menu_height 12 2>/dev/null || echo 12)
        else
            per_page=12
        fi
    fi
    [ "$per_page" -lt 5 ] && per_page=5
    total_pages=$(( (manager_count + per_page - 1) / per_page ))
    [ "$total_pages" -lt 1 ] && total_pages=1
    page=0

    while true; do
        clear 2>/dev/null || true
        printf "${CYAN}${BOLD}"
        if command -v manager_ui_print_banner >/dev/null 2>&1; then
            manager_ui_print_banner "MANMAN" "Manager of Managers"
        else
            echo "MANMAN — Manager of Managers"
            echo "----------------------------"
        fi
        printf "${RESET}\n"
        printf "${YELLOW}Gestionnaires${RESET}  page $((page + 1))/${total_pages}  (${manager_count} total)\n"
        printf "${DIM}statut: [OK] dispo  [OK^] updateman  [--] absent | n/p pages | 0 quitter${RESET}\n\n"

        start=$((page * per_page + 1))
        end=$(( (page + 1) * per_page ))
        [ "$end" -gt "$manager_count" ] && end=$manager_count
        _manman_print_rows "$managers_file" "$start" "$end"

        printf "\n"
        if command -v tui_hrule >/dev/null 2>&1; then
            tui_hrule
        fi
        printf "  ${BOLD}n${RESET}) page suivante   ${BOLD}p${RESET}) precedente   ${BOLD}0${RESET}) quitter\n"
        printf "${YELLOW}Choisir [numero|n|p|0]: ${RESET}"
        read -r choice || choice=0

        case "$choice" in
            0|q|Q|"")
                rm -f "$managers_file"
                return 0
                ;;
            n|N)
                if [ "$page" -lt $((total_pages - 1)) ]; then
                    page=$((page + 1))
                fi
                continue
                ;;
            p|P)
                if [ "$page" -gt 0 ]; then
                    page=$((page - 1))
                fi
                continue
                ;;
        esac

        selected_line=$(awk -F'|' -v c="$choice" '$1 == c {print; exit}' "$managers_file")
        if [ -z "$selected_line" ]; then
            printf "${RED}Choix invalide${RESET}\n"
            sleep 1
            continue
        fi

        IFS='|' read -r num ic name description command st <<EOF
$selected_line
EOF
        rm -f "$managers_file"

        printf "${GREEN}Lancement %s %s...${RESET}\n" "$ic" "$name"
        sleep 0.3

        # Charger core POSIX si besoin
        _core="$DOTFILES_DIR/core/managers/${name}/core/${name}.sh"
        if [ -f "$_core" ]; then
            # shellcheck source=/dev/null
            . "$_core" 2>/dev/null || true
        fi
        _zshf="$DOTFILES_FUNCTIONS_DIR/${name}.zsh"
        if [ -f "$_zshf" ]; then
            # shellcheck source=/dev/null
            . "$_zshf" 2>/dev/null || true
        fi

        if command -v "$command" >/dev/null 2>&1; then
            "$command"
        else
            printf "${RED}Impossible de lancer %s (commande absente)${RESET}\n" "$name"
            printf "Installe/charge le manager, puis reessaie.\n"
            sleep 2
        fi

        printf "\nAppuyez sur Entrée pour retourner a manman...\n"
        read -r _ || true
        manman
        return $?
    done
}
