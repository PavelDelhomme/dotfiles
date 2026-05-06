#!/bin/sh
# Helpers TUI partages pour cyberlearn (migration progressive).

cyberlearn_pick_menu() {
    _title="$1"
    _choice=""
    _menu_file=$(mktemp)
    _dotcli_bin="${DOTFILES_DOTCLI_BIN:-${DOTFILES_DIR:-$HOME/dotfiles}/bin/dotcli}"
    cat > "$_menu_file"

    if [ "${DOTFILES_DOTCLI_ENABLE:-0}" = "1" ] && [ -t 0 ] && [ -t 1 ] && [ -x "$_dotcli_bin" ]; then
        if [ "${DOTFILES_DOTCLI_MENU_NO_TUI:-0}" = "1" ]; then
            _choice=$("$_dotcli_bin" menu --no-tui --prompt "$_title" < "$_menu_file" 2>/dev/null || true)
        else
            _choice=$("$_dotcli_bin" menu --prompt "$_title" < "$_menu_file" 2>/dev/null || true)
        fi
    fi
    if [ -z "$_choice" ] && [ -t 0 ] && [ -t 1 ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
        _choice=$(dotfiles_ncmenu_select "$_title" < "$_menu_file" 2>/dev/null || true)
    fi

    rm -f "$_menu_file"
    if [ -z "$_choice" ] && [ -t 0 ] && [ -t 1 ] && [ -r /dev/tty ]; then
        printf "Choix: " > /dev/tty
        read _choice < /dev/tty || true
    fi
    printf "%s" "$_choice"
}
