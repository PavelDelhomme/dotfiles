#!/bin/sh
# =============================================================================
# ANONYMAN — Anonymisation & proxies (core POSIX)
# =============================================================================
# Convention G.x : no-args / help / -h / aide / help --interactive / --help
# Alias acceptés : anonymman (même fonction via adapters)
# =============================================================================

anonyman() {
    if [ -t 1 ] && [ -z "${NO_COLOR-}" ]; then
        RED=$(printf '\033[0;31m'); GREEN=$(printf '\033[0;32m')
        YELLOW=$(printf '\033[1;33m'); CYAN=$(printf '\033[0;36m')
        BOLD=$(printf '\033[1m'); RESET=$(printf '\033[0m')
    else
        RED=; GREEN=; YELLOW=; CYAN=; BOLD=; RESET=
    fi

    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    ANONYMAN_DATA="${ANONYMAN_DATA_DIR:-$HOME/.local/share/dotfiles/anonyman}"
    ANONYMAN_PROXY_LIST="$ANONYMAN_DATA/free-proxies.txt"
    ANONYMAN_PROXY_META="$ANONYMAN_DATA/free-proxies.meta"
    # Sources publiques (listes gratuites — fiabilité variable ; usage labo seulement)
    ANONYMAN_PROXY_URLS="${ANONYMAN_PROXY_URLS:-https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/http.txt https://raw.githubusercontent.com/clarketm/proxy-list/master/proxy-list-raw.txt}"

    if [ -f "$DOTFILES_DIR/scripts/lib/manager_ui.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/manager_ui.sh"
        command -v dotfiles_manager_load_ui_libs >/dev/null 2>&1 && dotfiles_manager_load_ui_libs
    fi

    _anonyman_pause() {
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée pour continuer... "
            # shellcheck disable=SC2034
            read _dummy
        fi
    }

    anonyman_print_help() {
        printf "${CYAN}${BOLD}ANONYMAN${RESET} — anonymisation (Tor / I2P / proxies)\n\n"
        printf "Sous-commandes :\n"
        printf "  ${BOLD}anonyman status${RESET}           Tor, I2P, proxychains, IP publique\n"
        printf "  ${BOLD}anonyman check${RESET}            compare IP directe vs Tor (si dispo)\n"
        printf "  ${BOLD}anonyman tor status|start|stop${RESET}\n"
        printf "  ${BOLD}anonyman i2p status|enable|disable|ports${RESET}\n"
        printf "  ${BOLD}anonyman proxy refresh${RESET}    telecharge listes proxies publiques\n"
        printf "  ${BOLD}anonyman proxy list${RESET}       affiche N premieres entrees locales\n"
        printf "  ${BOLD}anonyman proxy count${RESET}      nombre d'entrees\n"
        printf "  ${BOLD}anonyman doctor${RESET}           prerequis (curl, tor, i2pd, proxychains)\n"
        printf "  ${BOLD}anonyman run -- <cmd>${RESET}     execute via proxychains si possible\n\n"
        printf "Alias : ${BOLD}anonymman${RESET} → meme commande.\n"
        printf "Lies : installman tor|i2p · configman i2p · netman tor|i2p · cyberman anon\n\n"
        printf "Interface :\n"
        printf "  anonyman / anonyman help | -h | aide\n"
        printf "  anonyman help --interactive   aide + pause TTY\n"
        printf "  anonyman --help               aide (+ pause TTY si possible)\n"
        printf "\n${YELLOW}Note:${RESET} proxies gratuits = non fiables ; labo / tests seulement.\n"
        printf "      Ne pas exposer Tor/I2P hors LAN sans durcissement.\n"
    }

    _anonyman_public_ip() {
        curl -fsS --max-time 5 https://api.ipify.org 2>/dev/null \
            || curl -fsS --max-time 5 https://ifconfig.me/ip 2>/dev/null \
            || printf 'n/a'
    }

    _anonyman_tor_running() {
        pgrep -x tor >/dev/null 2>&1 && return 0
        command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet tor 2>/dev/null && return 0
        return 1
    }

    _anonyman_i2p_running() {
        pgrep -x i2pd >/dev/null 2>&1 && return 0
        command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet i2pd 2>/dev/null && return 0
        pgrep -f 'i2prouter|java.*i2p' >/dev/null 2>&1 && return 0
        return 1
    }

    anonyman_status() {
        printf "${CYAN}${BOLD}anonyman — statut${RESET}\n\n"
        if _anonyman_tor_running; then
            printf "  Tor     : ${GREEN}actif${RESET}\n"
        else
            printf "  Tor     : ${YELLOW}inactif${RESET}  (installman tor · anonyman tor start)\n"
        fi
        if _anonyman_i2p_running; then
            printf "  I2P     : ${GREEN}actif${RESET}\n"
        else
            printf "  I2P     : ${YELLOW}inactif${RESET}  (installman i2p · anonyman i2p enable)\n"
        fi
        if command -v proxychains >/dev/null 2>&1 || command -v proxychains4 >/dev/null 2>&1; then
            printf "  proxychains : ${GREEN}installe${RESET}\n"
        else
            printf "  proxychains : ${YELLOW}absent${RESET}\n"
        fi
        _n=0
        [ -f "$ANONYMAN_PROXY_LIST" ] && _n=$(grep -cE '^[0-9]' "$ANONYMAN_PROXY_LIST" 2>/dev/null || echo 0)
        printf "  Proxies locaux : %s (%s)\n" "$_n" "$ANONYMAN_PROXY_LIST"
        printf "  IP publique    : %s\n" "$(_anonyman_public_ip)"
        printf "\n"
    }

    anonyman_check() {
        printf "${CYAN}${BOLD}anonyman — check anonymat${RESET}\n\n"
        _direct="$(_anonyman_public_ip)"
        printf "  IP directe : %s\n" "$_direct"
        if ! _anonyman_tor_running; then
            printf "\n${YELLOW}Tor inactif — lance: anonyman tor start${RESET}\n"
            return 1
        fi
        _tor="n/a"
        if command -v curl >/dev/null 2>&1; then
            _tor=$(curl -fsS --max-time 12 --socks5-hostname 127.0.0.1:9050 https://api.ipify.org 2>/dev/null || printf 'n/a')
        fi
        printf "  IP Tor     : %s\n" "$_tor"
        if [ "$_tor" != "n/a" ] && [ "$_tor" != "$_direct" ]; then
            printf "\n${GREEN}OK — IP Tor differente de l'IP directe.${RESET}\n"
            return 0
        fi
        printf "\n${YELLOW}Anonymat Tor non confirme.${RESET}\n"
        return 1
    }

    anonyman_tor() {
        _sub="${1:-status}"
        case "$_sub" in
            status)
                if _anonyman_tor_running; then
                    printf "${GREEN}Tor actif${RESET}\n"
                else
                    printf "${YELLOW}Tor inactif${RESET}\n"
                    return 1
                fi
                ;;
            start|enable)
                if command -v systemctl >/dev/null 2>&1; then
                    sudo systemctl enable --now tor 2>/dev/null || systemctl --user start tor 2>/dev/null || true
                fi
                if command -v start_tor >/dev/null 2>&1; then
                    start_tor
                elif ! _anonyman_tor_running; then
                    printf "${YELLOW}Demarre Tor manuellement (systemctl start tor) ou: installman tor${RESET}\n" >&2
                    return 1
                fi
                anonyman_tor status
                ;;
            stop|disable)
                if command -v systemctl >/dev/null 2>&1; then
                    sudo systemctl stop tor 2>/dev/null || true
                fi
                if command -v stop_tor >/dev/null 2>&1; then
                    stop_tor
                fi
                pkill -x tor 2>/dev/null || true
                printf "${GREEN}Tor arrete (si permissions ok).${RESET}\n"
                ;;
            *)
                printf "${RED}Sous-commande tor inconnue:${RESET} %s\n" "$_sub" >&2
                return 1
                ;;
        esac
    }

    anonyman_i2p() {
        _sub="${1:-status}"
        case "$_sub" in
            status)
                if _anonyman_i2p_running; then
                    printf "${GREEN}I2P actif${RESET}\n"
                else
                    printf "${YELLOW}I2P inactif${RESET}\n"
                    return 1
                fi
                if command -v i2pd >/dev/null 2>&1; then
                    i2pd --version 2>/dev/null | head -n1 || true
                fi
                ;;
            enable|start)
                if command -v systemctl >/dev/null 2>&1; then
                    sudo systemctl enable --now i2pd 2>/dev/null || {
                        printf "${YELLOW}systemctl enable i2pd a echoue — verifie installman i2p${RESET}\n" >&2
                        return 1
                    }
                else
                    printf "${YELLOW}systemctl absent${RESET}\n" >&2
                    return 1
                fi
                anonyman_i2p status
                ;;
            disable|stop)
                if command -v systemctl >/dev/null 2>&1; then
                    sudo systemctl disable --now i2pd 2>/dev/null || sudo systemctl stop i2pd 2>/dev/null || true
                fi
                printf "${GREEN}I2P desactive (si permissions ok).${RESET}\n"
                ;;
            ports)
                printf "HTTP proxy I2P typique : 127.0.0.1:4444\n"
                printf "SOCKS I2P typique     : 127.0.0.1:4447\n"
                printf "Console web i2pd      : 127.0.0.1:7070 (selon i2pd.conf)\n"
                printf "Config : configman i2p · fichiers /etc/i2pd/\n"
                ;;
            *)
                printf "${RED}Sous-commande i2p inconnue:${RESET} %s\n" "$_sub" >&2
                return 1
                ;;
        esac
    }

    anonyman_proxy_refresh() {
        mkdir -p "$ANONYMAN_DATA" || return 1
        _tmp=$(mktemp) || return 1
        _ok=0
        for _url in $ANONYMAN_PROXY_URLS; do
            printf "Telechargement %s ...\n" "$_url"
            if curl -fsSL --max-time 30 "$_url" >>"$_tmp" 2>/dev/null; then
                _ok=1
            fi
        done
        if [ "$_ok" -eq 0 ]; then
            rm -f "$_tmp"
            printf "${RED}Echec telechargement listes proxies.${RESET}\n" >&2
            return 1
        fi
        # Normalise : IP:port uniquement
        grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+' "$_tmp" | sort -u >"$ANONYMAN_PROXY_LIST"
        rm -f "$_tmp"
        printf '%s\n' "updated=$(date -Iseconds 2>/dev/null || date)" >"$ANONYMAN_PROXY_META"
        _n=$(wc -l <"$ANONYMAN_PROXY_LIST" | tr -d ' ')
        printf "${GREEN}OK:${RESET} %s proxies dans %s\n" "$_n" "$ANONYMAN_PROXY_LIST"
        printf "${YELLOW}Rappel:${RESET} listes publiques = non chiffrees / non fiables ; labo seulement.\n"
    }

    anonyman_proxy_list() {
        _lim="${1:-20}"
        if [ ! -f "$ANONYMAN_PROXY_LIST" ]; then
            printf "${YELLOW}Aucune liste — lance: anonyman proxy refresh${RESET}\n" >&2
            return 1
        fi
        head -n "$_lim" "$ANONYMAN_PROXY_LIST"
    }

    anonyman_doctor() {
        printf "${CYAN}${BOLD}anonyman doctor${RESET}\n\n"
        for _bin in curl tor i2pd proxychains proxychains4; do
            if command -v "$_bin" >/dev/null 2>&1; then
                printf "  ${GREEN}✓${RESET} %s\n" "$_bin"
            else
                printf "  ${YELLOW}·${RESET} %s (absent)\n" "$_bin"
            fi
        done
        printf "\nInstall : installman tor | installman i2p | pacman/apt proxychains-ng\n"
        printf "Config  : configman i2p | netman tor | netman i2p\n"
    }

    anonyman_run() {
        shift
        [ "${1:-}" = "--" ] && shift
        if [ $# -eq 0 ]; then
            printf "Usage: anonyman run -- <commande> [args]\n" >&2
            return 1
        fi
        if command -v proxychains4 >/dev/null 2>&1; then
            proxychains4 -q "$@"
        elif command -v proxychains >/dev/null 2>&1; then
            proxychains -q "$@"
        else
            printf "${RED}proxychains introuvable${RESET}\n" >&2
            return 1
        fi
    }

    # --- dispatch -----------------------------------------------------------
    cmd="${1:-help}"
    case "$cmd" in
        help|-h|aide)
            if [ "${2:-}" = "--interactive" ] || [ "${2:-}" = "-i" ]; then
                anonyman_print_help
                _anonyman_pause
            else
                anonyman_print_help
            fi
            ;;
        --help)
            anonyman_print_help
            _anonyman_pause
            ;;
        status|st) anonyman_status ;;
        check|verify) anonyman_check ;;
        tor) shift; anonyman_tor "$@" ;;
        i2p) shift; anonyman_i2p "$@" ;;
        proxy)
            shift
            case "${1:-list}" in
                refresh|update|fetch) anonyman_proxy_refresh ;;
                list|show) shift; anonyman_proxy_list "${1:-20}" ;;
                count)
                    if [ -f "$ANONYMAN_PROXY_LIST" ]; then
                        wc -l <"$ANONYMAN_PROXY_LIST" | tr -d ' '
                    else
                        printf '0\n'
                    fi
                    ;;
                *)
                    printf "${RED}proxy sous-commande inconnue:${RESET} %s\n" "${1:-}" >&2
                    return 1
                    ;;
            esac
            ;;
        doctor|diag) anonyman_doctor ;;
        run) anonyman_run "$@" ;;
        "")
            anonyman_print_help
            ;;
        *)
            printf "${RED}Commande inconnue:${RESET} %s\n\n" "$cmd" >&2
            anonyman_print_help
            return 1
            ;;
    esac
}

# Alias naming (utilisateur peut taper anonymman)
anonymman() { anonyman "$@"; }
