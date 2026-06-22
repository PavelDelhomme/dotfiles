#!/usr/bin/env bash
# Extrait et copie les blocs de commandes de docs/TESTS.md vers le presse-papiers.
#
# Usage :
#   tests_copy.sh <étape>              # copie le bloc bash complet
#   tests_copy.sh <étape> --list       # liste les lignes numérotées
#   tests_copy.sh <étape> --line <n>   # copie la ligne n (1-based)
#   tests_copy.sh <étape> -l <n>       # idem
#   tests_copy.sh --steps                # liste les étapes avec bloc bash
#   tests_copy.sh <étape> --pick         # menu interactif (bloc ou ligne)
#
# Exemples :
#   tests_copy.sh G.0.b
#   tests_copy.sh G.0.d --line 12
#   make tests-copy STEP=G.0.c LINE=3

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
TESTS_MD="${DOTFILES_DIR}/docs/TESTS.md"
CLIP_LIB="${DOTFILES_DIR}/shared/functions/clipboard_copy.sh"

usage() {
    cat <<'EOF'
tests_copy.sh — copier les commandes de docs/TESTS.md

  tests_copy.sh <étape>              bloc bash complet → presse-papiers
  tests_copy.sh <étape> --list       afficher les lignes numérotées
  tests_copy.sh <étape> --line <n>   copier une ligne (1-based)
  tests_copy.sh <étape> -l <n>       idem
  tests_copy.sh <étape> --pick       menu : bloc entier ou une ligne
  tests_copy.sh --steps              lister les étapes détectées

Variables : DOTFILES_DIR (défaut ~/dotfiles)
EOF
}

die() {
    printf 'tests_copy: %s\n' "$*" >&2
    exit 1
}

clipboard_copy() {
    local text="$1"
    if [ -f "$CLIP_LIB" ]; then
        # shellcheck source=/dev/null
        . "$CLIP_LIB"
        if dotfiles_clipboard_copy "$text"; then
            return 0
        fi
    fi
    if command -v wl-copy >/dev/null 2>&1; then
        printf '%s' "$text" | wl-copy
        return 0
    fi
    if command -v xclip >/dev/null 2>&1; then
        printf '%s' "$text" | xclip -selection clipboard
        return 0
    fi
    if command -v xsel >/dev/null 2>&1; then
        printf '%s' "$text" | xsel --clipboard --input
        return 0
    fi
    die "aucun outil presse-papiers (wl-copy, xclip, xsel). Installez-en un ou copiez depuis --list."
}

# Extrait l'ID d'étape depuis une ligne « ### Étape X — »
_parse_step_header() {
    case "$1" in
        "### Étape "*)
            printf '%s' "$1" | sed -n 's/^### Étape \([^—]*\) —.*/\1/p'
            ;;
    esac
}

# Écrit le bloc bash de l'étape dans $2 ; retourne 0 si trouvé.
extract_block_file() {
    local want="$1"
    local out_file="$2"
    local in_step=0
    local in_block=0
    local found=0
  local step_id line

  : >"$out_file"
  while IFS= read -r line || [ -n "$line" ]; do
    step_id="$(_parse_step_header "$line")"
    if [ -n "$step_id" ]; then
      if [ "$step_id" = "$want" ]; then
        in_step=1
        in_block=0
      else
        if [ "$in_step" -eq 1 ] && [ "$found" -eq 1 ]; then
          break
        fi
        in_step=0
        in_block=0
      fi
      continue
    fi
    if [ "$in_step" -eq 1 ]; then
      local trimmed="${line#"${line%%[![:space:]]*}"}"
      case "$trimmed" in
        '```bash'*)
          in_block=1
          continue
          ;;
        '```')
          if [ "$in_block" -eq 1 ]; then
            in_block=0
            found=1
            break
          fi
          ;;
      esac
      if [ "$in_block" -eq 1 ]; then
        printf '%s\n' "$line" >>"$out_file"
      fi
    fi
  done <"$TESTS_MD"

  [ "$found" -eq 1 ]
}

list_steps() {
    local step_id="" current="" in_block=0
    while IFS= read -r line || [ -n "$line" ]; do
        step_id="$(_parse_step_header "$line")"
        if [ -n "$step_id" ]; then
            current="$step_id"
            in_block=0
            continue
        fi
        if [ -n "$current" ]; then
            local trimmed="${line#"${line%%[![:space:]]*}"}"
            case "$trimmed" in
                '```bash'*) in_block=1 ;;
                '```')
                    if [ "$in_block" -eq 1 ]; then
                        printf '%s\n' "$current"
                        in_block=0
                        current=""
                    fi
                    ;;
            esac
        fi
    done <"$TESTS_MD" | sort -u
}

list_lines() {
    local step="$1"
    local tmp
    tmp="$(mktemp)"
    trap 'rm -f "$tmp"' RETURN
    extract_block_file "$step" "$tmp" || die "étape « $step » introuvable ou sans bloc bash dans $TESTS_MD"
    local n=0 line
    while IFS= read -r line || [ -n "$line" ]; do
        n=$((n + 1))
        printf '%4d | %s\n' "$n" "$line"
    done <"$tmp"
}

copy_block() {
    local step="$1"
    local tmp
    tmp="$(mktemp)"
    trap 'rm -f "$tmp"' RETURN
    extract_block_file "$step" "$tmp" || die "étape « $step » introuvable ou sans bloc bash dans $TESTS_MD"
    local content lines
    content="$(cat "$tmp")"
    [ -n "$content" ] || die "bloc vide pour $step"
    clipboard_copy "$content"
    lines="$(wc -l <"$tmp" | tr -d ' ')"
    printf '📋 Étape %s : bloc complet copié (%s ligne(s))\n' "$step" "$lines"
}

copy_line() {
    local step="$1"
    local num="$2"
    local tmp
    tmp="$(mktemp)"
    trap 'rm -f "$tmp"' RETURN
    extract_block_file "$step" "$tmp" || die "étape « $step » introuvable"
    local line max
    max="$(wc -l <"$tmp" | tr -d ' ')"
    line="$(sed -n "${num}p" "$tmp")"
    [ -n "$line" ] || die "ligne $num absente (bloc $max ligne(s) max)"
    clipboard_copy "$line"
    printf '📋 Étape %s ligne %s copiée : %s\n' "$step" "$num" "$line"
}

pick_interactive() {
    local step="$1"
    printf 'Étape %s — choisir :\n  [a] bloc complet\n  [l] une ligne (numéro)\n  [q] annuler\n> ' "$step"
    read -r choice </dev/tty || die "entrée annulée"
    case "$choice" in
        a|A) copy_block "$step" ;;
        l|L)
            list_lines "$step"
            printf 'Numéro de ligne à copier : '
            read -r num </dev/tty || die "entrée annulée"
            copy_line "$step" "$num"
            ;;
        q|Q) exit 0 ;;
        *) die "choix invalide" ;;
    esac
}

main() {
    [ -f "$TESTS_MD" ] || die "fichier introuvable : $TESTS_MD"

    if [ $# -eq 0 ]; then
        usage
        exit 0
    fi

    case "${1:-}" in
        -h|--help|help)
            usage
            exit 0
            ;;
        --steps)
            list_steps
            exit 0
            ;;
    esac

    local step="${1:-}"
    shift

    local mode="block"
    local line_num=""

    while [ $# -gt 0 ]; do
        case "$1" in
            --list) mode="list"; shift ;;
            --line|-l)
                mode="line"
                line_num="${2:-}"
                [ -n "$line_num" ] || die "--line requiert un numéro"
                shift 2
                ;;
            --pick) mode="pick"; shift ;;
            *) die "option inconnue : $1" ;;
        esac
    done

    case "$mode" in
        list) list_lines "$step" ;;
        line) copy_line "$step" "$line_num" ;;
        pick) pick_interactive "$step" ;;
        block) copy_block "$step" ;;
    esac
}

main "$@"
