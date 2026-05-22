#!/usr/bin/env sh
# =============================================================================
# MANAGER UI - Bannieres et regles adaptatives pour les *man (POSIX sh)
# =============================================================================
# S'appuie sur scripts/lib/tui_core.sh. A sourcer depuis core/managers/*/core/*.sh
# ou via dotfiles_manager_load_ui_libs.
# =============================================================================

# Charge tui_core une seule fois
dotfiles_load_tui_core() {
    if [ -n "${_TUI_CORE_LOADED:-}" ]; then
        return 0
    fi
    _df="${DOTFILES_DIR:-$HOME/dotfiles}"
    _tui="${_df}/scripts/lib/tui_core.sh"
    if [ ! -f "$_tui" ]; then
        return 1
    fi
    # shellcheck source=scripts/lib/tui_core.sh
    . "$_tui"
    _TUI_CORE_LOADED=1
    return 0
}

dotfiles_load_manager_ui() {
    dotfiles_load_tui_core
    _MANAGER_UI_LOADED=1
    return 0
}

# ncurses_menu + tui_core (convention P1 / P3b pour managers POSIX interactifs)
dotfiles_manager_load_ui_libs() {
    _df="${DOTFILES_DIR:-$HOME/dotfiles}"
    if [ -f "${_df}/scripts/lib/ncurses_menu.sh" ]; then
        # shellcheck source=scripts/lib/ncurses_menu.sh
        . "${_df}/scripts/lib/ncurses_menu.sh"
    fi
    dotfiles_load_manager_ui
}

# Banniere titre (+ sous-titres optionnels). Le caller gere clear et les couleurs.
# Usage: manager_ui_print_banner "TITRE" ["sous-titre"] ["sous-titre2"]
manager_ui_print_banner() {
    _mui_title="${1:-}"
    _mui_sub1="${2:-}"
    _mui_sub2="${3:-}"
    dotfiles_load_tui_core || {
        printf '%s\n' "$_mui_title"
        [ -n "$_mui_sub1" ] && printf '%s\n' "$_mui_sub1"
        [ -n "$_mui_sub2" ] && printf '%s\n' "$_mui_sub2"
        return 0
    }
    if tui_is_compact; then
        printf '%s\n' "$_mui_title"
        [ -n "$_mui_sub1" ] && printf '%s\n' "$_mui_sub1"
        [ -n "$_mui_sub2" ] && printf '%s\n' "$_mui_sub2"
        tui_hrule
        return 0
    fi
    _mui_w=64
    if command -v tui_content_width >/dev/null 2>&1; then
        _mui_w=$(tui_content_width)
    fi
    if command -v tui_repeat_char >/dev/null 2>&1; then
        printf '╔'
        tui_repeat_char '═' "$_mui_w"
        printf '╗\n'
        printf '║ %-*s ║\n' "$_mui_w" "$_mui_title"
        [ -n "$_mui_sub1" ] && printf '║ %-*s ║\n' "$_mui_w" "$_mui_sub1"
        [ -n "$_mui_sub2" ] && printf '║ %-*s ║\n' "$_mui_w" "$_mui_sub2"
        printf '╚'
        tui_repeat_char '═' "$_mui_w"
        printf '╝\n'
    else
        echo "╔════════════════════════════════════════════════════════════════╗"
        printf '║ %-*s ║\n' 62 "$_mui_title"
        [ -n "$_mui_sub1" ] && printf '║ %-*s ║\n' 62 "$_mui_sub1"
        [ -n "$_mui_sub2" ] && printf '║ %-*s ║\n' 62 "$_mui_sub2"
        echo "╚════════════════════════════════════════════════════════════════╝"
    fi
}

# Regle de section (remplace les lignes ═══... fixes). Couleurs : caller avant/apres.
manager_ui_section_rule() {
    dotfiles_load_tui_core && command -v tui_hrule >/dev/null 2>&1 && tui_hrule && return 0
    echo "=================================================================="
}

# Retourne 0 si le choix demande de quitter le menu (0, q, quit, exit, …).
manager_ui_is_quit_choice() {
    case "$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')" in
        0|q|quit|exit|quitter|x) return 0 ;;
    esac
    return 1
}

# Fin de menu racine : return 1 pour « while true; do show_main_menu || break; done ».
manager_ui_leave_main_menu() {
    return 1
}

# Ligne de section avec couleurs du manager (remplace printf "${BLUE}═══...${RESET}\n").
# Usage: manager_ui_section_line "${BLUE}" "${RESET}\n"   ou  ... "${RESET}\n\n"
manager_ui_section_line() {
    _mui_c1="${1:-}"
    _mui_c2="${2:-}"
    [ -n "$_mui_c1" ] && printf '%s' "$_mui_c1"
    manager_ui_section_rule
    if [ -n "$_mui_c2" ]; then
        printf '%s' "$_mui_c2"
    else
        printf '\n'
    fi
}

# Selection de menu commune pour les managers.
# Entree fichier: lignes "Label|valeur". Retourne la valeur choisie sur stdout.
# Priorite: dotcli si active, puis dotfiles_ncmenu_select, puis fallback appelant.
manager_ui_select_file() {
    _mui_title="${1:-Menu}"
    _mui_file="${2:-}"
    [ -n "$_mui_file" ] && [ -f "$_mui_file" ] || return 1

    if [ "${DOTFILES_DOTCLI_ENABLE:-0}" = "1" ] && [ -t 0 ] && [ -t 1 ]; then
        _mui_dotcli="${DOTFILES_DOTCLI_BIN:-${DOTFILES_DIR:-$HOME/dotfiles}/bin/dotcli}"
        if [ -x "$_mui_dotcli" ]; then
            if [ "${DOTFILES_DOTCLI_MENU_NO_TUI:-0}" = "1" ]; then
                "$_mui_dotcli" menu --no-tui --prompt "$_mui_title" < "$_mui_file" 2>/dev/null && return 0
            else
                "$_mui_dotcli" menu --prompt "$_mui_title" < "$_mui_file" 2>/dev/null && return 0
            fi
        fi
    fi

    if [ -t 0 ] && [ -t 1 ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
        dotfiles_ncmenu_select "$_mui_title" < "$_mui_file" 2>/dev/null && return 0
    fi

    return 127
}

# Variante stdin: printf 'Label|valeur\n' | manager_ui_select "Titre"
manager_ui_select() {
    _mui_title="${1:-Menu}"
    _mui_tmp=$(mktemp) || return 1
    cat > "$_mui_tmp"
    _mui_choice=$(manager_ui_select_file "$_mui_title" "$_mui_tmp" 2>/dev/null || true)
    rm -f "$_mui_tmp"
    [ -n "$_mui_choice" ] || return 127
    printf '%s' "$_mui_choice"
}
