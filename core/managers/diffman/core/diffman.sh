#!/bin/sh
# =============================================================================
# DIFFMAN — comparaison de fichiers (couleurs, côte à côte, rapports multi-fichiers)
# =============================================================================
# Convention : Bloc G de docs/TESTS.md (no-args / help / -h / help --interactive /
#              --help, arg inconnu → stderr + rc 1).
# =============================================================================

# DESC: Comparateur de fichiers avec couleurs (unifié ou côte à côte) et rapports.
# USAGE: diffman [commande] [args]
diffman() {
    _dm_RED=''; _dm_GREEN=''; _dm_YELLOW=''; _dm_BLUE=''; _dm_CYAN=''; _dm_BOLD=''; _dm_RESET=''
    _dm_use_color=0
    if [ -z "${NO_COLOR-}" ]; then
        if [ -t 1 ] || [ "${FORCE_COLOR:-0}" = "1" ]; then
            _dm_use_color=1
        fi
    fi
    if [ "$_dm_use_color" = "1" ]; then
        _dm_RED=$(printf '\033[0;31m')
        _dm_GREEN=$(printf '\033[0;32m')
        _dm_YELLOW=$(printf '\033[1;33m')
        _dm_BLUE=$(printf '\033[0;34m')
        _dm_CYAN=$(printf '\033[0;36m')
        _dm_BOLD=$(printf '\033[1m')
        _dm_RESET=$(printf '\033[0m')
    fi

    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

    _dm_pause_if_tty() {
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée pour continuer... "
            read -r _dm_dummy || true
        fi
    }

    _dm_print_help() {
        cat <<'EOF'
DIFFMAN — comparaison lisible de fichiers (couleurs, côte à côte, rapports)

Interface :
  diffman                              cette aide (stdout)
  diffman help | -h | aide             idem
  diffman help --interactive           aide + pause (TTY requis)
  diffman --help                       idem + pause (TTY)

Commandes :
  diffman compare|cmp [opts] A B     diff unifié coloré (défaut). Codes retour :
                                       0 = identiques, 1 = différents, 2 = erreur
    Options compare :
      --side | -s                      vue côte à côte (-y), largeur terminal
      --width N                      force la largeur (mode --side uniquement)
      --no-git                       n'utilise pas « git diff --no-index »
  diffman side [opts] A B            raccourci : compare --side A B
  diffman unified [opts] A B         raccourci : compare unifié explicite
  diffman report [opts] F1 F2 [F3 …] rapport texte (plusieurs paires)
    Options report :
      --out FILE | -o FILE           écrire dans FILE (sinon stdout)
      --all-pairs                    toutes les paires (max 8 fichiers)
      --base REF                     fichier de référence (défaut : 1er argument)
  diffman diff3 A B C                fusion à 3 voies (nécessite diff3 sur le PATH)

Couleurs :
  Vert / rouge : via « git diff --color=always » ou « diff --color=always » (GNU).
  Variables : NO_COLOR (désactive), FORCE_COLOR=1 (colore même si stdout n'est pas un TTY).

Exemples :
  diffman compare .env .env.production.example
  diffman side .env .env.production.example
  diffman report -o /tmp/rapport.txt .env .env.staging .env.production.example
  diffman report --all-pairs --out /tmp/toutes-paires.txt a b c
EOF
    }

    _dm_has_git() {
        command -v git >/dev/null 2>&1
    }

    _dm_gnu_diff_color() {
        diff --help 2>&1 | grep -q -- '--color'
    }

    _dm_cols() {
        _dm_c=""
        if [ -n "${COLUMNS-}" ]; then
            _dm_c="$COLUMNS"
        elif command -v tput >/dev/null 2>&1; then
            _dm_c=$(tput cols 2>/dev/null || true)
        fi
        case "$_dm_c" in ''|0|*[!0-9]*) _dm_c=120 ;; esac
        if [ "$_dm_c" -lt 40 ]; then
            _dm_c=80
        fi
        printf '%s' "$_dm_c"
    }

    _dm_git_unified() {
        _dm_a="$1"
        _dm_b="$2"
        if _dm_has_git && [ "${_dm_NO_GIT-0}" != 1 ]; then
            # shellcheck disable=SC2086
            git --no-pager -c color.ui=always diff --no-index --minimal ${_dm_GIT_EXTRA-} -- "$_dm_a" "$_dm_b"
            _dm_rc=$?
            if [ "$_dm_rc" -eq 0 ] || [ "$_dm_rc" -eq 1 ]; then
                return "$_dm_rc"
            fi
            return 2
        fi
        if _dm_gnu_diff_color && [ -z "${NO_COLOR-}" ]; then
            diff -u --color=always -- "$_dm_a" "$_dm_b"
            return $?
        fi
        diff -u -- "$_dm_a" "$_dm_b"
        return $?
    }

    _dm_side_by_side() {
        _dm_a="$1"
        _dm_b="$2"
        _dm_w="${3:-$(_dm_cols)}"
        if _dm_gnu_diff_color && [ -z "${NO_COLOR-}" ]; then
            diff -y --width="$_dm_w" --color=always -- "$_dm_a" "$_dm_b"
            return $?
        fi
        diff -y --width="$_dm_w" -- "$_dm_a" "$_dm_b"
        return $?
    }

    _dm_require_two_files() {
        if [ ! -f "$1" ] || [ ! -r "$1" ]; then
            printf '%sdiffman: fichier introuvable ou non lisible : %s%s\n' "$_dm_RED" "$1" "$_dm_RESET" >&2
            return 2
        fi
        if [ ! -f "$2" ] || [ ! -r "$2" ]; then
            printf '%sdiffman: fichier introuvable ou non lisible : %s%s\n' "$_dm_RED" "$2" "$_dm_RESET" >&2
            return 2
        fi
        return 0
    }

    diffman_cmd_compare() {
        _dm_side=0
        _dm_w=""
        _dm_NO_GIT=0
        while [ $# -gt 0 ]; do
            case "$1" in
                --side|-s) _dm_side=1; shift ;;
                --width)
                    _dm_w="$2"
                    shift 2
                    ;;
                --no-git) _dm_NO_GIT=1; shift ;;
                --) shift; break ;;
                -*) printf '%sdiffman: option inconnue : %s%s\n' "$_dm_RED" "$1" "$_dm_RESET" >&2; return 2 ;;
                *) break ;;
            esac
        done
        if [ $# -ne 2 ]; then
            printf '%sdiffman compare: deux chemins de fichiers requis.%s\n' "$_dm_RED" "$_dm_RESET" >&2
            printf 'Usage : diffman compare [--side] [--width N] [--no-git] FICHIER_A FICHIER_B\n' >&2
            return 2
        fi
        _dm_require_two_files "$1" "$2" || return 2
        if [ "$_dm_side" -eq 1 ]; then
            _dm_side_by_side "$1" "$2" "${_dm_w:-$(_dm_cols)}"
            return $?
        fi
        _dm_git_unified "$1" "$2"
        return $?
    }

    diffman_cmd_side() {
        diffman_cmd_compare --side "$@"
    }

    diffman_cmd_unified() {
        diffman_cmd_compare "$@"
    }

    diffman_cmd_report() {
        _dm_out=""
        _dm_mode=base
        _dm_base=""
        while [ $# -gt 0 ]; do
            case "$1" in
                --out|-o)
                    _dm_out="$2"
                    shift 2
                    ;;
                --all-pairs)
                    _dm_mode=pairs
                    shift
                    ;;
                --base)
                    _dm_base="$2"
                    shift 2
                    ;;
                --) shift; break ;;
                -*) printf '%sdiffman: option inconnue : %s%s\n' "$_dm_RED" "$1" "$_dm_RESET" >&2; return 2 ;;
                *) break ;;
            esac
        done
        if [ $# -lt 2 ]; then
            printf '%sdiffman report: au moins deux fichiers requis.%s\n' "$_dm_RED" "$_dm_RESET" >&2
            return 2
        fi
        _dm_n=0
        for _dm_f in "$@"; do
            _dm_n=$((_dm_n + 1))
        done
        if [ "$_dm_mode" = pairs ] && [ "$_dm_n" -gt 8 ]; then
            printf '%sdiffman report: --all-pairs limité à 8 fichiers (%s fournis).%s\n' "$_dm_RED" "$_dm_n" "$_dm_RESET" >&2
            return 2
        fi

        _dm_write_block() {
            _dm_x="$1"
            _dm_y="$2"
            printf '%s\n' "========== $_dm_x vs $_dm_y =========="
            if [ ! -f "$_dm_x" ] || [ ! -r "$_dm_x" ] || [ ! -f "$_dm_y" ] || [ ! -r "$_dm_y" ]; then
                printf '%s(diffman: fichier manquant ou non lisible — paire ignorée)%s\n' "$_dm_YELLOW" "$_dm_RESET"
                return 0
            fi
            _dm_git_unified "$_dm_x" "$_dm_y" || true
            printf '\n'
        }

        _dm_body() {
            printf '%sdiffman rapport multi-fichiers%s\n' "$_dm_CYAN" "$_dm_RESET"
            date -u +'date_utc=%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date +'date=%Y-%m-%d %H:%M:%S'
            printf '\n'
            if [ "$_dm_mode" = pairs ]; then
                _dm_i=1
                for _dm_fa in "$@"; do
                    _dm_j=1
                    for _dm_fb in "$@"; do
                        if [ "$_dm_j" -le "$_dm_i" ]; then
                            _dm_j=$((_dm_j + 1))
                            continue
                        fi
                        _dm_write_block "$_dm_fa" "$_dm_fb"
                        _dm_j=$((_dm_j + 1))
                    done
                    _dm_i=$((_dm_i + 1))
                done
            else
                _dm_ref="${_dm_base:-$1}"
                for _dm_other in "$@"; do
                    if [ "$_dm_other" = "$_dm_ref" ]; then
                        continue
                    fi
                    _dm_write_block "$_dm_ref" "$_dm_other"
                done
            fi
        }

        if [ -n "$_dm_out" ]; then
            _dm_body "$@" >"$_dm_out" || return 2
            printf '%sRapport écrit : %s%s\n' "$_dm_GREEN" "$_dm_out" "$_dm_RESET"
        else
            _dm_body "$@"
        fi
        return 0
    }

    diffman_cmd_diff3() {
        if [ $# -ne 3 ]; then
            printf '%sdiffman diff3: exactement trois fichiers requis (ancêtre, mon, ta — voir diff3(1)).%s\n' "$_dm_RED" "$_dm_RESET" >&2
            return 2
        fi
        if ! command -v diff3 >/dev/null 2>&1; then
            printf '%sdiffman: diff3 introuvable (paquet diffutils).%s\n' "$_dm_YELLOW" "$_dm_RESET" >&2
            return 2
        fi
        for _dm_f in "$@"; do
            if [ ! -f "$_dm_f" ] || [ ! -r "$_dm_f" ]; then
                printf '%sdiffman: fichier introuvable : %s%s\n' "$_dm_RED" "$_dm_f" "$_dm_RESET" >&2
                return 2
            fi
        done
        diff3 "$1" "$2" "$3"
        return $?
    }

    # --- Dispatch : aide / menu léger ----------------------------------------
    if [ -z "${1-}" ]; then
        _dm_print_help
        return 0
    fi
    if [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "aide" ]; then
        case "${2-}" in
            --interactive|-i)
                if [ -t 0 ] && [ -t 1 ]; then
                    _dm_print_help
                    _dm_pause_if_tty
                else
                    printf '%s\n' "diffman: help --interactive nécessite un TTY." >&2
                    _dm_print_help
                fi
                return 0
                ;;
            *)
                _dm_print_help
                return 0
                ;;
        esac
    fi
    if [ "$1" = "--help" ]; then
        _dm_print_help
        return 0
    fi

    _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
    if [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ]; then
        # shellcheck source=/dev/null
        . "$_logdf/scripts/lib/managers_log_posix.sh" && managers_cli_log diffman "$@"
    fi

    _dm_cmd=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
    shift

    case "$_dm_cmd" in
        compare|cmp|diff) diffman_cmd_compare "$@" ;;
        side|y|columns) diffman_cmd_side "$@" ;;
        unified|u) diffman_cmd_unified "$@" ;;
        report|r|multi) diffman_cmd_report "$@" ;;
        diff3|three|3way) diffman_cmd_diff3 "$@" ;;
        *)
            printf '%sdiffman: commande inconnue : %s%s\n' "$_dm_RED" "$_dm_cmd" "$_dm_RESET" >&2
            printf 'Voir : diffman help\n' >&2
            return 1
            ;;
    esac
}
