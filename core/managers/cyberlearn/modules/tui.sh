#!/bin/sh
# Helpers TUI partages pour cyberlearn (migration progressive).

cyberlearn_pick_menu() {
    _title="$1"
    _choice=""
    _menu_file=$(mktemp)
    cat > "$_menu_file"

    if command -v manager_ui_select_file >/dev/null 2>&1; then
        _choice=$(manager_ui_select_file "$_title" "$_menu_file" 2>/dev/null || true)
    elif [ -t 0 ] && [ -t 1 ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
        _choice=$(dotfiles_ncmenu_select "$_title" < "$_menu_file" 2>/dev/null || true)
    fi

    rm -f "$_menu_file"
    if [ -z "$_choice" ] && [ -t 0 ] && [ -t 1 ] && [ -r /dev/tty ]; then
        printf "Choix: " > /dev/tty
        read _choice < /dev/tty || true
    fi
    printf "%s" "$_choice"
}
