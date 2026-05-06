#!/bin/sh
# Helpers TUI partages pour aliaman (migration progressive).

aliaman_dotcli_menu_pick() {
    _title="$1"
    _file="$2"
    _dotcli_bin="${DOTFILES_DOTCLI_BIN:-${DOTFILES_DIR:-$HOME/dotfiles}/bin/dotcli}"
    if [ "${DOTFILES_DOTCLI_ENABLE:-0}" = "1" ] && [ -t 0 ] && [ -t 1 ] && [ -x "$_dotcli_bin" ]; then
        if [ "${DOTFILES_DOTCLI_MENU_NO_TUI:-0}" = "1" ]; then
            "$_dotcli_bin" menu --no-tui --prompt "$_title" < "$_file" 2>/dev/null || return 1
        else
            "$_dotcli_bin" menu --prompt "$_title" < "$_file" 2>/dev/null || return 1
        fi
        return 0
    fi
    return 1
}
