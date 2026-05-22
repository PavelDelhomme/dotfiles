#!/bin/sh
# Smoke EXT-002 : TUI adaptatif + sortie des menus *man (0 / q).
set -eu

DF="${DOTFILES_DIR:-$HOME/dotfiles}"
UI="$DF/scripts/lib/manager_ui.sh"
[ -f "$UI" ] || { echo "FAIL: manager_ui.sh introuvable" >&2; exit 1; }
# shellcheck source=scripts/lib/manager_ui.sh
. "$UI"
dotfiles_load_manager_ui

_fail=0
_ok() { printf 'OK  %s\n' "$1"; }
_fail_msg() { printf 'FAIL %s\n' "$1" >&2; _fail=1; }

# --- Mode compact 60 et 69 colonnes ---
for _cols in 60 69; do
    export COLUMNS="$_cols"
    export LINES=24
    if ! tui_is_compact; then
        _fail_msg "tui_is_compact attendu avec COLUMNS=${_cols}"
    else
        _ok "tui_is_compact COLUMNS=${_cols}"
    fi
    _got=$(tui_cols)
    if [ "$_got" != "$_cols" ]; then
        _fail_msg "tui_cols=${_got} attendu ${_cols}"
    else
        _ok "tui_cols=${_cols}"
    fi
    if ! manager_ui_print_banner "TEST BANNER" "sous-titre" 2>/dev/null | grep -q 'TEST BANNER'; then
        _fail_msg "manager_ui_print_banner COLUMNS=${_cols}"
    else
        _ok "manager_ui_print_banner COLUMNS=${_cols}"
    fi
done

# --- Choix quitter ---
for _c in 0 q Q quit exit quitter; do
    if manager_ui_is_quit_choice "$_c"; then
        _ok "manager_ui_is_quit_choice ${_c}"
    else
        _fail_msg "manager_ui_is_quit_choice ${_c}"
    fi
done
if manager_ui_is_quit_choice "1"; then
    _fail_msg "manager_ui_is_quit_choice 1 (faux positif)"
else
    _ok "manager_ui_is_quit_choice refuse 1"
fi

# --- Boucle menu (pattern show_main_menu || break) ---
_sim_menu() {
    _choice="${1:-0}"
    if command -v manager_ui_is_quit_choice >/dev/null 2>&1 && manager_ui_is_quit_choice "$_choice"; then
        return 1
    fi
    case "$_choice" in
        0|q|Q|quit|exit) return 1 ;;
    esac
    return 0
}
_iterations=0
while true; do
    _iterations=$((_iterations + 1))
    _sim_menu "q" || break
    [ "$_iterations" -gt 3 ] && { _fail_msg "boucle menu ne se termine pas sur q"; break; }
done
if [ "$_iterations" -eq 1 ]; then
    _ok "boucle menu quit sur q"
else
    _fail_msg "iterations boucle=${_iterations} (attendu 1)"
fi

# --- devman --help sans TTY : aide seulement, pas de menu bloquant ---
if [ -f "$DF/core/managers/devman/core/devman.sh" ]; then
    if ( set +u; . "$DF/core/managers/devman/core/devman.sh"; devman --help ) </dev/null >/tmp/devman_help_out 2>/tmp/devman_help_err; then
        _ok "devman --help sans TTY"
    else
        _fail_msg "devman --help sans TTY (voir /tmp/devman_help_err)"
    fi
fi

if [ "$_fail" -ne 0 ]; then
    exit 1
fi
printf 'tui_compact_smoke: tous les checks OK\n'
