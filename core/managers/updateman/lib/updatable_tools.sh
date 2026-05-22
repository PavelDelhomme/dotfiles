#!/bin/sh
# Bibliotheque partagee installman/updateman — outils a jour via updateman

updatable_tools_registry() {
    printf '%s\n' "${UPDATABLE_TOOLS_REGISTRY:-${DOTFILES_DIR:-$HOME/dotfiles}/core/managers/updateman/config/updatable-tools.list}"
}

updatable_tools_load_installman_utils() {
    _ut_df="${DOTFILES_DIR:-$HOME/dotfiles}"
    _ut_utils="$_ut_df/zsh/functions/installman/utils"
    [ -f "$_ut_utils/check_installed.sh" ] && . "$_ut_utils/check_installed.sh" 2>/dev/null || true
    [ -f "$_ut_utils/version_utils.sh" ] && . "$_ut_utils/version_utils.sh" 2>/dev/null || true
}

updatable_tools_foreach() {
    _ut_reg="$(updatable_tools_registry)"
    [ -f "$_ut_reg" ] || return 0
    while IFS= read -r _ut_line || [ -n "$_ut_line" ]; do
        case "$_ut_line" in
            ''|'#'*) continue ;;
        esac
        printf '%s\n' "$_ut_line"
    done <"$_ut_reg"
}

updatable_tool_field() {
    _ut_line="$1"
    _ut_n="${2:-1}"
    printf '%s' "$_ut_line" | awk -F'|' -v n="$_ut_n" '{ if (n <= NF) print $n }'
}

updatable_tool_find() {
    _ut_want="$1"
    updatable_tools_foreach | while IFS= read -r _ut_line; do
        _ut_name="$(updatable_tool_field "$_ut_line" 1)"
        [ "$_ut_name" = "$_ut_want" ] && printf '%s\n' "$_ut_line" && break
    done
}

updatable_tool_names() {
    updatable_tools_foreach | while IFS= read -r _ut_line; do
        updatable_tool_field "$_ut_line" 1
    done
}

updatable_tool_is_registered() {
    updatable_tool_find "$1" | grep -q .
}

updatable_tool_check_installed() {
    _ut_line="$(updatable_tool_find "$1")"
    [ -n "$_ut_line" ] || return 1
    _ut_check="$(updatable_tool_field "$_ut_line" 2)"
    [ -n "$_ut_check" ] && command -v "$_ut_check" >/dev/null 2>&1 || return 1
    [ "$($_ut_check 2>/dev/null)" = "installed" ]
}

updatable_tool_timer_state() {
    _ut_line="$(updatable_tool_find "$1")"
    _ut_timer="$(updatable_tool_field "$_ut_line" 3)"
    [ -n "$_ut_timer" ] && [ "$_ut_timer" != "-" ] || { printf '%s\n' "-"; return 0; }
    if command -v systemctl >/dev/null 2>&1; then
        systemctl --user is-active "$_ut_timer" 2>/dev/null || printf '%s\n' "inactive"
    else
        printf '%s\n' "n/a"
    fi
}

updatable_tool_auto_service_enabled() {
    _ut_line="$(updatable_tool_find "$1")"
    [ "$(updatable_tool_field "$_ut_line" 4)" = "1" ]
}
