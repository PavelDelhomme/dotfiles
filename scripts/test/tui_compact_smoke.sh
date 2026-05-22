#!/bin/sh
# Smoke EXT-002 : bannieres et regles de section en terminal etroit (COLUMNS=60).
set -eu

DF="${DOTFILES_DIR:-$HOME/dotfiles}"
UI="$DF/scripts/lib/manager_ui.sh"
[ -f "$UI" ] || { echo "FAIL: manager_ui.sh introuvable" >&2; exit 1; }
# shellcheck source=scripts/lib/manager_ui.sh
. "$UI"
dotfiles_load_manager_ui

export COLUMNS=60
export LINES=24

_fail=0

if ! tui_is_compact; then
    printf 'FAIL tui_is_compact (attendu mode compact avec COLUMNS=60)\n' >&2
    _fail=1
else
    printf 'OK  tui_is_compact\n'
fi

_cols=$(tui_cols)
if [ "$_cols" != 60 ]; then
    printf 'FAIL tui_cols (got %s, want 60)\n' "$_cols" >&2
    _fail=1
else
    printf 'OK  tui_cols\n'
fi

if manager_ui_print_banner "TEST" "sous-titre" 2>/dev/null | grep -q 'TEST'; then
    printf 'OK  manager_ui_print_banner\n'
else
    printf 'FAIL manager_ui_print_banner\n' >&2
    _fail=1
fi

if manager_ui_section_line 2>/dev/null | grep -qE '.|-'; then
    printf 'OK  manager_ui_section_line\n'
else
    printf 'FAIL manager_ui_section_line\n' >&2
    _fail=1
fi

if [ "$_fail" -ne 0 ]; then
    exit 1
fi
printf 'tui_compact_smoke: tous les checks OK (COLUMNS=%s)\n' "$COLUMNS"
