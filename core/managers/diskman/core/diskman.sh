#!/bin/sh
# =============================================================================
# DISKMAN — analyse et nettoyage disque (core POSIX)
# =============================================================================
# Convention : aide / CLI alignée Bloc G de docs/TESTS.md.
# =============================================================================

# DESC: Gestionnaire disque : usage, gros fichiers, inodes, nettoyage prudent.
# USAGE: diskman [commande] [args]
diskman() {
    RED=''; GREEN=''; YELLOW=''; CYAN=''; BOLD=''; RESET=''
    if [ -t 1 ] && [ -z "${NO_COLOR-}" ]; then
        RED=$(printf '\033[0;31m')
        GREEN=$(printf '\033[0;32m')
        YELLOW=$(printf '\033[1;33m')
        CYAN=$(printf '\033[0;36m')
        BOLD=$(printf '\033[1m')
        RESET=$(printf '\033[0m')
    fi

    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

    pause_if_tty() {
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée pour continuer... "
            read -r _diskman_dummy || true
        fi
    }

    diskman_print_help() {
        cat <<'EOF'
DISKMAN — diagnostic et nettoyage disque prudent

Interface :
  diskman                           cette aide (stdout)
  diskman help | -h | aide          idem
  diskman help --interactive        aide + pause (TTY)
  diskman --help                    aide + pause + menu interactif (TTY)

Commandes :
  diskman overview                  vue df/lsblk + /tmp + cache utilisateur
  diskman usage [PATH] [DEPTH]      dossiers lourds (défaut: . depth=1)
  diskman biggest [PATH] [N]        plus gros fichiers (défaut: . N=20)
  diskman inodes [PATH]             consommation d'inodes
  diskman mounts                    systèmes de fichiers montés
  diskman health                    aperçu SMART si smartctl existe
  diskman clean [opts] [target]     nettoyage prudent (dry-run par défaut)
  diskman report [OUT]              rapport texte complet

Targets clean :
  all | pacman | apt | journal | user-cache | trash | tmp | docker

Options clean :
  --dry-run                         montre seulement ce qui serait fait (défaut)
  --apply                           exécute réellement
  --yes                             saute la confirmation TTY

Exemples :
  diskman overview
  diskman usage ~ 2
  diskman biggest /var/log 30
  diskman clean --dry-run all
  diskman clean --apply journal
  diskman report ~/disk-report.txt
EOF
    }

    diskman_header() {
        printf "%s%sDISKMAN%s — %s\n" "$CYAN" "$BOLD" "$RESET" "$1"
        printf "%s\n" "────────────────────────────────────────────────────────────"
    }

    diskman_human_path_size() {
        _dm_path="$1"
        if [ -e "$_dm_path" ]; then
            du -sh "$_dm_path" 2>/dev/null | awk '{print $1}'
        else
            printf "absent"
        fi
    }

    diskman_cmd_overview() {
        diskman_header "vue d'ensemble"
        printf "%sSystèmes de fichiers:%s\n" "$BOLD" "$RESET"
        df -hT 2>/dev/null | awk 'NR==1 || $0 ~ /^\/dev\// {print}'
        printf "\n%sDisques / partitions:%s\n" "$BOLD" "$RESET"
        if command -v lsblk >/dev/null 2>&1; then
            lsblk -o NAME,SIZE,TYPE,FSTYPE,FSUSED,FSAVAIL,FSUSE%,MOUNTPOINTS 2>/dev/null || lsblk
        else
            printf "lsblk indisponible\n"
        fi
        printf "\n%sPoints à surveiller:%s\n" "$BOLD" "$RESET"
        printf "  ~/.cache        %s\n" "$(diskman_human_path_size "$HOME/.cache")"
        printf "  ~/.local/share/Trash %s\n" "$(diskman_human_path_size "$HOME/.local/share/Trash")"
        printf "  /tmp            %s\n" "$(diskman_human_path_size /tmp)"
        if command -v docker >/dev/null 2>&1; then
            printf "\n%sDocker:%s\n" "$BOLD" "$RESET"
            if command -v timeout >/dev/null 2>&1; then
                timeout 3 docker system df 2>/dev/null || printf "  docker non accessible ou trop lent (daemon/permissions)\n"
            else
                docker system df 2>/dev/null || printf "  docker non accessible (daemon/permissions)\n"
            fi
        fi
        return 0
    }

    diskman_cmd_usage() {
        _dm_path="${1:-.}"
        _dm_depth="${2:-1}"
        case "$_dm_depth" in ''|*[!0-9]*) _dm_depth=1 ;; esac
        diskman_header "dossiers lourds: $_dm_path (depth=$_dm_depth)"
        if du -xhd "$_dm_depth" "$_dm_path" >/dev/null 2>&1; then
            du -xhd "$_dm_depth" "$_dm_path" 2>/dev/null | sort -hr | head -40
        else
            du -sh "$_dm_path"/* "$_dm_path"/.[!.]* 2>/dev/null | sort -hr | head -40
        fi
    }

    diskman_cmd_biggest() {
        _dm_path="${1:-.}"
        _dm_n="${2:-20}"
        case "$_dm_n" in ''|*[!0-9]*) _dm_n=20 ;; esac
        diskman_header "plus gros fichiers: $_dm_path (top $_dm_n)"
        if command -v find >/dev/null 2>&1; then
            find "$_dm_path" -xdev -type f -printf '%s\t%p\n' 2>/dev/null \
                | sort -nr | head -n "$_dm_n" \
                | awk '{size=$1; $1=""; cmd="numfmt --to=iec --suffix=B " size; cmd | getline human; close(cmd); sub(/^[ \t]+/,""); printf "%8s  %s\n", human, $0}'
        else
            printf "find indisponible\n" >&2
            return 1
        fi
    }

    diskman_cmd_inodes() {
        _dm_path="${1:-.}"
        diskman_header "inodes"
        df -ih "$_dm_path" 2>/dev/null || df -i "$_dm_path"
        printf "\n%sDossiers avec beaucoup d'entrées (top 30):%s\n" "$BOLD" "$RESET"
        find "$_dm_path" -xdev -type d -printf '%p\n' 2>/dev/null \
            | while IFS= read -r d; do
                c=$(find "$d" -maxdepth 1 -mindepth 1 2>/dev/null | wc -l)
                printf '%s\t%s\n' "$c" "$d"
            done | sort -nr | head -30
    }

    diskman_cmd_mounts() {
        diskman_header "montages"
        findmnt -o TARGET,SOURCE,FSTYPE,SIZE,USED,AVAIL,USE%,OPTIONS 2>/dev/null || mount
    }

    diskman_cmd_health() {
        diskman_header "santé disque"
        if ! command -v smartctl >/dev/null 2>&1; then
            printf "%ssmartctl absent%s (Arch: sudo pacman -S smartmontools ; Debian: sudo apt install smartmontools)\n" "$YELLOW" "$RESET"
            return 0
        fi
        if command -v lsblk >/dev/null 2>&1; then
            for d in $(lsblk -dn -o NAME,TYPE 2>/dev/null | awk '$2=="disk"{print "/dev/"$1}'); do
                printf "\n%s%s%s\n" "$BOLD" "$d" "$RESET"
                sudo smartctl -H "$d" 2>/dev/null || smartctl -H "$d" 2>/dev/null || true
            done
        else
            printf "lsblk indisponible\n"
        fi
    }

    diskman_clean_show() {
        _target="$1"
        case "$_target" in
            pacman)
                printf "pacman cache: %s\n" "$(diskman_human_path_size /var/cache/pacman/pkg)"
                ;;
            apt)
                printf "apt cache: %s\n" "$(diskman_human_path_size /var/cache/apt)"
                ;;
            journal)
                journalctl --disk-usage 2>/dev/null || printf "journalctl indisponible\n"
                ;;
            user-cache)
                printf "\$HOME/.cache: %s\n" "$(diskman_human_path_size "$HOME/.cache")"
                ;;
            trash)
                printf "Trash: %s\n" "$(diskman_human_path_size "$HOME/.local/share/Trash")"
                ;;
            tmp)
                printf "/tmp: %s\n" "$(diskman_human_path_size /tmp)"
                ;;
            docker)
                if command -v timeout >/dev/null 2>&1; then
                    timeout 3 docker system df 2>/dev/null || printf "docker non accessible ou trop lent\n"
                else
                    docker system df 2>/dev/null || printf "docker non accessible\n"
                fi
                ;;
        esac
    }

    diskman_clean_apply_one() {
        _target="$1"
        case "$_target" in
            pacman)
                command -v pacman >/dev/null 2>&1 || { printf "pacman absent\n"; return 0; }
                if command -v paccache >/dev/null 2>&1; then
                    sudo paccache -rk2
                    sudo paccache -ruk0
                else
                    sudo pacman -Sc
                fi
                ;;
            apt)
                command -v apt-get >/dev/null 2>&1 || { printf "apt absent\n"; return 0; }
                sudo apt-get clean
                sudo apt-get autoremove -y
                ;;
            journal)
                sudo journalctl --vacuum-time=14d
                ;;
            user-cache)
                find "$HOME/.cache" -mindepth 1 -maxdepth 1 -mtime +14 -exec rm -rf {} + 2>/dev/null || true
                ;;
            trash)
                rm -rf "$HOME/.local/share/Trash/files"/* "$HOME/.local/share/Trash/info"/* 2>/dev/null || true
                ;;
            tmp)
                sudo find /tmp -mindepth 1 -xdev -mtime +7 -exec rm -rf {} + 2>/dev/null || true
                ;;
            docker)
                command -v docker >/dev/null 2>&1 || { printf "docker absent\n"; return 0; }
                docker system prune -af
                ;;
        esac
    }

    diskman_cmd_clean() {
        _apply=0
        _yes=0
        _target=all
        while [ $# -gt 0 ]; do
            case "$1" in
                --dry-run) _apply=0; shift ;;
                --apply) _apply=1; shift ;;
                --yes|-y) _yes=1; shift ;;
                all|pacman|apt|journal|user-cache|trash|tmp|docker) _target="$1"; shift ;;
                *) printf "%sdiskman clean: option/target inconnu: %s%s\n" "$RED" "$1" "$RESET" >&2; return 2 ;;
            esac
        done
        diskman_header "nettoyage (${_target})"
        _targets="$_target"
        if [ "$_target" = all ]; then
            _targets=$(printf '%s\n' pacman apt journal user-cache trash tmp docker)
        fi
        printf "%sMode:%s %s\n\n" "$BOLD" "$RESET" "$( [ "$_apply" -eq 1 ] && printf apply || printf dry-run )"
        printf '%s\n' "$_targets" | while IFS= read -r t; do
            [ -n "$t" ] || continue
            printf "%s[%s]%s\n" "$CYAN" "$t" "$RESET"
            diskman_clean_show "$t"
        done
        if [ "$_apply" -ne 1 ]; then
            printf "\n%sDry-run uniquement.%s Relancer avec: diskman clean --apply %s\n" "$YELLOW" "$RESET" "$_target"
            return 0
        fi
        if [ "$_yes" -ne 1 ] && [ -t 0 ] && [ -t 1 ]; then
            printf "\n%sConfirmer le nettoyage réel (%s) ? [y/N] %s" "$RED" "$_target" "$RESET"
            read -r ans || ans=n
            case "$ans" in [yY]|[oO]) ;; *) printf "Annulé.\n"; return 0 ;; esac
        elif [ "$_yes" -ne 1 ]; then
            printf "%sRefus non-TTY sans --yes.%s\n" "$RED" "$RESET" >&2
            return 2
        fi
        printf '%s\n' "$_targets" | while IFS= read -r t; do
            [ -n "$t" ] || continue
            printf "\n%s[apply %s]%s\n" "$GREEN" "$t" "$RESET"
            diskman_clean_apply_one "$t"
        done
    }

    diskman_cmd_report() {
        _out="${1:-}"
        _root="${DISKMAN_REPORT_ROOT:-.}"
        _body() {
            date -u '+date_utc=%Y-%m-%dT%H:%M:%SZ'
            printf "\n== overview ==\n"
            diskman_cmd_overview
            printf "\n== usage %s ==\n" "$_root"
            diskman_cmd_usage "$_root" 1
            printf "\n== biggest %s ==\n" "$_root"
            diskman_cmd_biggest "$_root" 20
            printf "\n== clean dry-run ==\n"
            diskman_cmd_clean --dry-run all
        }
        if [ -n "$_out" ]; then
            _body > "$_out"
            printf "%sRapport écrit: %s%s\n" "$GREEN" "$_out" "$RESET"
        else
            _body
        fi
    }

    diskman_menu() {
        while true; do
            diskman_header "menu"
            printf "1) Vue d'ensemble\n"
            printf "2) Dossiers lourds (~)\n"
            printf "3) Plus gros fichiers (~)\n"
            printf "4) Nettoyage dry-run\n"
            printf "5) Santé disque\n"
            printf "0) Quitter\n"
            printf "Choix: "
            read -r choice || return 0
            case "$choice" in
                1) diskman_cmd_overview; pause_if_tty ;;
                2) diskman_cmd_usage "$HOME" 2; pause_if_tty ;;
                3) diskman_cmd_biggest "$HOME" 30; pause_if_tty ;;
                4) diskman_cmd_clean --dry-run all; pause_if_tty ;;
                5) diskman_cmd_health; pause_if_tty ;;
                0|q|quit|exit) return 0 ;;
                *) printf "%sChoix invalide.%s\n" "$RED" "$RESET" ;;
            esac
        done
    }

    if [ -z "${1-}" ]; then
        diskman_print_help
        return 0
    fi
    if [ "$1" = help ] || [ "$1" = "-h" ] || [ "$1" = aide ]; then
        case "${2-}" in
            --interactive|-i)
                diskman_print_help
                pause_if_tty
                return 0
                ;;
            *)
                diskman_print_help
                return 0
                ;;
        esac
    fi
    if [ "$1" = "--help" ]; then
        diskman_print_help
        if [ -t 0 ] && [ -t 1 ]; then
            pause_if_tty
            diskman_menu
        fi
        return 0
    fi

    _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
    if [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ]; then
        . "$_logdf/scripts/lib/managers_log_posix.sh" && managers_cli_log diskman "$@"
    fi

    cmd=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
    shift
    case "$cmd" in
        overview|status|df) diskman_cmd_overview "$@" ;;
        usage|du) diskman_cmd_usage "$@" ;;
        biggest|big|large) diskman_cmd_biggest "$@" ;;
        inodes|inode) diskman_cmd_inodes "$@" ;;
        mounts|mount) diskman_cmd_mounts "$@" ;;
        health|smart) diskman_cmd_health "$@" ;;
        clean|cleanup) diskman_cmd_clean "$@" ;;
        report) diskman_cmd_report "$@" ;;
        *)
            printf "%sdiskman: commande inconnue: %s%s\n" "$RED" "$cmd" "$RESET" >&2
            printf "Voir : diskman help\n" >&2
            return 1
            ;;
    esac
}
