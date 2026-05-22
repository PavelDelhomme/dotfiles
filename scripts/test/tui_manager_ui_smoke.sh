#!/usr/bin/env sh
# Smoke P3b / EXT-002 : banniere adaptative (large et compact)
set -eu

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/scripts/lib/manager_ui.sh"
dotfiles_load_manager_ui

_fail=0
_run() {
    _label="$1"
    shift
    if sh -c ". '$ROOT/scripts/lib/manager_ui.sh'; dotfiles_load_manager_ui; $*" >/dev/null 2>&1; then
        printf 'OK  %s\n' "$_label"
    else
        printf 'FAIL %s\n' "$_label" >&2
        _fail=1
    fi
}

_run "tui_cols" 'tui_cols | grep -E "^[0-9]+$"'
_run "tui_is_compact non-tty" 'tui_is_compact'

printf '%s\n' '--- banner wide ---'
COLUMNS=120 LINES=40 sh -c ". '$ROOT/scripts/lib/manager_ui.sh'; dotfiles_load_manager_ui; manager_ui_print_banner 'SMOKE' 'wide'"

printf '%s\n' '--- banner compact ---'
COLUMNS=60 LINES=24 sh -c ". '$ROOT/scripts/lib/manager_ui.sh'; dotfiles_load_manager_ui; manager_ui_print_banner 'SMOKE' 'compact'"

exit "$_fail"
