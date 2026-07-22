#!/bin/sh
# =============================================================================
# SHELLMAN — bascule et configuration des shells (core POSIX)
# =============================================================================
# Scopes:
#   --session / --once  : ce terminal seulement (exec)
#   --user              : shell de login utilisateur (chsh)
#   --system            : defaut comptes futurs (doc + /etc/default/useradd si root)
# Convention G.x : help / -h / aide / --help / arg inconnu -> stderr + rc1
# =============================================================================

shellman() {
    if [ -t 1 ] && [ -z "${NO_COLOR-}" ]; then
        RED=$(printf '\033[0;31m'); GREEN=$(printf '\033[0;32m')
        YELLOW=$(printf '\033[1;33m'); CYAN=$(printf '\033[0;36m')
        BOLD=$(printf '\033[1m'); RESET=$(printf '\033[0m')
    else
        RED=; GREEN=; YELLOW=; CYAN=; BOLD=; RESET=
    fi

    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

    if [ -f "$DOTFILES_DIR/scripts/lib/manager_ui.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/manager_ui.sh"
        command -v dotfiles_manager_load_ui_libs >/dev/null 2>&1 && dotfiles_manager_load_ui_libs
    fi

    _shellman_pause() {
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée pour continuer... "
            # shellcheck disable=SC2034
            read _dummy
        fi
    }

    shellman_print_help() {
        printf "${CYAN}${BOLD}SHELLMAN${RESET} — bascule et configuration des shells\n\n"
        printf "Sous-commandes :\n"
        printf "  ${BOLD}shellman status${RESET}              shell courant, login, disponibles\n"
        printf "  ${BOLD}shellman list${RESET}                shells dans /etc/shells (+ present?)\n"
        printf "  ${BOLD}shellman doctor${RESET}              prerequis chsh, /etc/shells, adapters\n"
        printf "  ${BOLD}shellman use <shell> [scope]${RESET}\n"
        printf "      scopes :\n"
        printf "        ${BOLD}--session${RESET} | ${BOLD}--once${RESET}   ce terminal seulement (exec)\n"
        printf "        ${BOLD}--user${RESET}                 shell login utilisateur (chsh)\n"
        printf "        ${BOLD}--system${RESET}               defaut systeme (root ; prudent)\n"
        printf "  ${BOLD}shellman current${RESET}             alias de status (court)\n\n"
        printf "Exemples :\n"
        printf "  shellman use fish --session     # ouvre fish dans ce terminal\n"
        printf "  shellman use zsh --user         # chsh -s $(command -v zsh)\n"
        printf "  shellman use bash --once        # idem session\n\n"
        printf "Lies : configman apply shell · pathman · anonyman (hors scope)\n"
        printf "Tests : make tests-smoke-manager MANAGER=shellman (Docker)\n\n"
        printf "Interface : shellman | help | -h | aide | --help\n"
    }

    _shellman_basename() {
        _b="$1"
        _b="${_b##*/}"
        printf '%s' "$_b"
    }

    _shellman_resolve() {
        _want="$1"
        case "$_want" in
            zsh|bash|fish|sh|dash|ksh|tcsh|csh) ;;
            *)
                if [ -x "$_want" ]; then
                    printf '%s' "$_want"
                    return 0
                fi
                return 1
                ;;
        esac
        if command -v "$_want" >/dev/null 2>&1; then
            command -v "$_want"
            return 0
        fi
        for _p in "/bin/$_want" "/usr/bin/$_want" "/usr/local/bin/$_want"; do
            if [ -x "$_p" ]; then
                printf '%s' "$_p"
                return 0
            fi
        done
        return 1
    }

    _shellman_in_etc_shells() {
        _path="$1"
        [ -f /etc/shells ] || return 1
        grep -qxF "$_path" /etc/shells 2>/dev/null
    }

    _shellman_login_shell() {
        if command -v getent >/dev/null 2>&1; then
            getent passwd "$(id -un)" 2>/dev/null | awk -F: '{print $NF}'
            return 0
        fi
        printf '%s' "${SHELL:-unknown}"
    }

    shellman_list() {
        printf "${CYAN}${BOLD}shellman — shells disponibles${RESET}\n\n"
        printf "  %-10s %-28s %s\n" "nom" "chemin" "etat"
        for _n in zsh bash fish sh dash; do
            _p="$(_shellman_resolve "$_n" 2>/dev/null)" || _p="-"
            if [ "$_p" != "-" ] && [ -x "$_p" ]; then
                _st="${GREEN}present${RESET}"
                _shellman_in_etc_shells "$_p" || _st="${YELLOW}present (hors /etc/shells)${RESET}"
            else
                _st="${YELLOW}absent${RESET}"
                _p="-"
            fi
            printf "  %-10s %-28s " "$_n" "$_p"
            printf "%b\n" "$_st"
        done
        if [ -f /etc/shells ]; then
            printf "\n${BOLD}/etc/shells${RESET} :\n"
            grep -v '^#' /etc/shells 2>/dev/null | sed 's/^/  /'
        fi
    }

    shellman_status() {
        _cur_bn="$(_shellman_basename "${0:-sh}")"
        # Prefer parent process name when available
        if command -v ps >/dev/null 2>&1; then
            _pp=$(ps -p $$ -o comm= 2>/dev/null | tr -d ' ')
            [ -n "$_pp" ] && _cur_bn="$(_shellman_basename "$_pp")"
        fi
        case "${ZSH_VERSION:+zsh}${BASH_VERSION:+bash}${FISH_VERSION:+fish}" in
            zsh) _cur_bn=zsh ;;
            bash) _cur_bn=bash ;;
            fish) _cur_bn=fish ;;
        esac
        _login="$(_shellman_login_shell)"
        _env_shell="${SHELL:-}"
        printf "${CYAN}${BOLD}shellman — statut${RESET}\n\n"
        printf "  Shell de cette session : %s\n" "$_cur_bn"
        printf "  \$SHELL                 : %s\n" "${_env_shell:-n/a}"
        printf "  Shell login (passwd)   : %s\n" "$_login"
        printf "  Utilisateur            : %s\n" "$(id -un 2>/dev/null || echo '?')"
        printf "  DOTFILES_DIR           : %s\n" "$DOTFILES_DIR"
        printf "\nAdapters :\n"
        for _sh in zsh bash fish; do
            case "$_sh" in
                zsh) _ad="$DOTFILES_DIR/shells/zsh/adapters" ;;
                bash) _ad="$DOTFILES_DIR/shells/bash/adapters" ;;
                fish) _ad="$DOTFILES_DIR/shells/fish/adapters" ;;
            esac
            if [ -d "$_ad" ]; then
                printf "  ${GREEN}OK${RESET}  %s\n" "$_ad"
            else
                printf "  ${YELLOW}--${RESET}  %s\n" "$_ad"
            fi
        done
        printf "\n"
    }

    shellman_doctor() {
        printf "${CYAN}${BOLD}shellman doctor${RESET}\n\n"
        for _b in chsh getent grep; do
            if command -v "$_b" >/dev/null 2>&1; then
                printf "  ${GREEN}OK${RESET}  %s\n" "$_b"
            else
                printf "  ${YELLOW}--${RESET}  %s\n" "$_b"
            fi
        done
        [ -f /etc/shells ] && printf "  ${GREEN}OK${RESET}  /etc/shells\n" || printf "  ${YELLOW}--${RESET}  /etc/shells\n"
        for _n in zsh bash fish; do
            if _shellman_resolve "$_n" >/dev/null 2>&1; then
                printf "  ${GREEN}OK${RESET}  %s -> %s\n" "$_n" "$(_shellman_resolve "$_n")"
            else
                printf "  ${YELLOW}--${RESET}  %s non installe\n" "$_n"
            fi
        done
        printf "\nAstuce : shellman use fish --session  (test sans chsh)\n"
        printf "         shellman use zsh --user     (permanent pour ton compte)\n"
    }

    shellman_use() {
        _target="${1:-}"
        _scope="${2:---session}"
        if [ -z "$_target" ]; then
            printf "${RED}Usage:${RESET} shellman use <zsh|bash|fish|sh> [--session|--once|--user|--system]\n" >&2
            return 1
        fi
        shift
        while [ $# -gt 0 ]; do
            case "$1" in
                --session|--once|--user|--system) _scope="$1" ;;
                -s) _scope="--session" ;;
                -u) _scope="--user" ;;
                -g|--global) _scope="--system" ;;
            esac
            shift
        done

        _path="$(_shellman_resolve "$_target")" || {
            printf "${RED}Shell introuvable:${RESET} %s\n" "$_target" >&2
            printf "Installe-le puis reessaie (ex. pacman -S fish / apt install fish).\n" >&2
            return 1
        }

        case "$_scope" in
            --session|--once)
                printf "${GREEN}Session:${RESET} exec %s (ce terminal seulement)\n" "$_path"
                if [ ! -t 0 ] || [ ! -t 1 ]; then
                    printf "${YELLOW}Pas de TTY — simule seulement : exec %s${RESET}\n" "$_path"
                    return 0
                fi
                exec "$_path"
                ;;
            --user)
                if ! command -v chsh >/dev/null 2>&1; then
                    printf "${RED}chsh introuvable${RESET}\n" >&2
                    return 1
                fi
                if ! _shellman_in_etc_shells "$_path"; then
                    printf "${YELLOW}%s n'est pas dans /etc/shells${RESET}\n" "$_path" >&2
                    printf "Ajoute-le (root) : echo '%s' | sudo tee -a /etc/shells\n" "$_path" >&2
                    return 1
                fi
                printf "Changement shell login -> %s ...\n" "$_path"
                if chsh -s "$_path"; then
                    printf "${GREEN}OK:${RESET} shell login = %s (nouvelle connexion requise)\n" "$_path"
                else
                    printf "${RED}Echec chsh${RESET} — essaye: chsh -s %s\n" "$_path" >&2
                    return 1
                fi
                ;;
            --system)
                if [ "$(id -u)" -ne 0 ]; then
                    printf "${YELLOW}--system requiert root${RESET}\n" >&2
                    printf "Exemple : sudo shellman use zsh --system\n" >&2
                    printf "Ou edite /etc/default/useradd (DSHELL=...) selon ta distro.\n" >&2
                    return 1
                fi
                if [ -f /etc/default/useradd ]; then
                    if grep -q '^DSHELL=' /etc/default/useradd 2>/dev/null; then
                        sed -i "s|^DSHELL=.*|DSHELL=$_path|" /etc/default/useradd
                    else
                        printf 'DSHELL=%s\n' "$_path" >>/etc/default/useradd
                    fi
                    printf "${GREEN}OK:${RESET} DSHELL=%s dans /etc/default/useradd\n" "$_path"
                else
                    printf "${YELLOW}Pas de /etc/default/useradd${RESET} — documente le defaut de ta distro.\n" >&2
                    printf "Chemin resolu : %s\n" "$_path"
                    return 1
                fi
                ;;
            *)
                printf "${RED}Scope inconnu:${RESET} %s\n" "$_scope" >&2
                return 1
                ;;
        esac
    }

    cmd="${1:-help}"
    case "$cmd" in
        help|-h|aide)
            if [ "${2:-}" = "--interactive" ] || [ "${2:-}" = "-i" ]; then
                shellman_print_help
                _shellman_pause
            else
                shellman_print_help
            fi
            ;;
        --help)
            shellman_print_help
            _shellman_pause
            ;;
        status|current|st) shellman_status ;;
        list|ls) shellman_list ;;
        doctor|diag) shellman_doctor ;;
        use|switch|set)
            shift
            shellman_use "$@"
            ;;
        "")
            shellman_print_help
            ;;
        *)
            printf "${RED}Commande inconnue:${RESET} %s\n\n" "$cmd" >&2
            shellman_print_help
            return 1
            ;;
    esac
}
