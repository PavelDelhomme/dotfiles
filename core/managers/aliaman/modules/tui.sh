#!/bin/sh
# Helpers TUI partages pour aliaman (migration progressive).

aliaman_dotcli_menu_pick() {
    _title="$1"
    _file="$2"
    if command -v manager_ui_select_file >/dev/null 2>&1; then
        manager_ui_select_file "$_title" "$_file"
        return $?
    fi
    return 1
}
