#!/bin/sh
# Sélecteur centralisé de menus interactifs.
# Entrée attendue sur stdin: "Libellé|valeur" (une ligne par option).
# Priorité: fzf (si dispo) -> ncmenu -> fallback appelant (saisie manuelle).

dotfiles_ncmenu_select() {
    _title="$1"
    _menu_file=$(mktemp)
    cat > "$_menu_file"

    _choice=""

    # 1) fzf en priorité (plus confortable clavier sans souris)
    if [ -t 0 ] && [ -t 1 ] && command -v fzf >/dev/null 2>&1; then
        # Style unifié fzf pour tous les menus *man.
        # Override possible via DOTFILES_FZF_MENU_OPTS.
        _fzf_menu_opts="${DOTFILES_FZF_MENU_OPTS:---height=75% --layout=reverse --border --ansi --cycle --info=inline-right --prompt='> '}"
        _picked_label=$(cut -d'|' -f1 "$_menu_file" | \
            fzf $_fzf_menu_opts --prompt="${_title:-Menu} > " 2>/dev/null || true)
        if [ -n "$_picked_label" ]; then
            _choice=$(awk -F'|' -v lbl="$_picked_label" '$1==lbl { print $2; exit }' "$_menu_file")
        fi
    fi

    # 2) fallback ncmenu (si fzf absent/non sélectionné)
    if [ -z "$_choice" ] && [ -t 0 ] && [ -t 1 ]; then
        if command -v ncmenu >/dev/null 2>&1; then
            _choice=$(ncmenu --title "$_title" < "$_menu_file" 2>/dev/null || true)
        elif [ -x "$HOME/dotfiles/bin/ncmenu" ]; then
            _choice=$("$HOME/dotfiles/bin/ncmenu" --title "$_title" < "$_menu_file" 2>/dev/null || true)
        fi
    fi

    rm -f "$_menu_file"
    [ -n "$_choice" ] || return 127
    printf "%s" "$_choice"
}

