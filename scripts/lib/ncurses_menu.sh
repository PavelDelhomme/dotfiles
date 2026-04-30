#!/bin/sh
# Wrapper minimal pour utiliser ncmenu (C + ncurses) si disponible.

dotfiles_ncmenu_select() {
    _title="$1"
    if command -v ncmenu >/dev/null 2>&1; then
        ncmenu --title "$_title"
    elif [ -x "$HOME/dotfiles/bin/ncmenu" ]; then
        "$HOME/dotfiles/bin/ncmenu" --title "$_title"
    else
        return 127
    fi
}

