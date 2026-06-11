#!/bin/sh
# Sélecteur centralisé de menus interactifs.
# Entrée attendue sur stdin: "Libellé|valeur" (une ligne par option).
# Priorité: fzf (si dispo) -> ncmenu -> fallback appelant (saisie manuelle).

dotfiles_ncmenu_select() {
    _df_nc="${DOTFILES_DIR:-$HOME/dotfiles}"
    _title="$1"
    _menu_file=$(mktemp)
    cat > "$_menu_file"

    _choice=""

    # 1) fzf en priorité (plus confortable clavier sans souris)
    if [ -t 0 ] && [ -t 1 ] && command -v fzf >/dev/null 2>&1; then
        # Style unifié fzf pour tous les menus *man.
        # Override possible via DOTFILES_FZF_MENU_OPTS.
        _fzf_menu_opts="${DOTFILES_FZF_MENU_OPTS:---height=75% --layout=reverse --border --ansi --cycle --info=inline-right --prompt='> '}"
        if [ -f "$_df_nc/scripts/lib/tui_core.sh" ]; then
            # shellcheck source=scripts/lib/tui_core.sh
            . "$_df_nc/scripts/lib/tui_core.sh" 2>/dev/null || true
            if command -v tui_lines >/dev/null 2>&1; then
                _nc_lines=$(tui_lines)
                if [ "$_nc_lines" -lt 28 ] 2>/dev/null; then
                    _nc_h=$((_nc_lines - 3))
                    [ "$_nc_h" -lt 6 ] && _nc_h=6
                    _fzf_menu_opts="--height=${_nc_h} --layout=reverse --border --ansi --cycle --info=inline-right --prompt='> '"
                fi
            fi
        fi
        _fzf_out=$(awk -F'|' '{ printf "%s\t%s\n", $2, $1 }' "$_menu_file" | \
            fzf --expect=0,q $_fzf_menu_opts --prompt="${_title:-Menu} > " 2>/dev/null || true)
        _fzf_key=$(printf '%s\n' "$_fzf_out" | sed -n '1p')
        _picked_line=$(printf '%s\n' "$_fzf_out" | sed -n '2p')
        if [ -n "$_fzf_key" ] && awk -F'|' -v v="$_fzf_key" '$2==v { found=1 } END { exit !found }' "$_menu_file"; then
            _choice="$_fzf_key"
        elif [ -n "$_picked_line" ]; then
            _choice=${_picked_line%%	*}
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
    case "$_choice" in
        *"|"*) _choice=${_choice##*|} ;;
    esac
    [ -n "$_choice" ] || return 127
    printf "%s" "$_choice"
}

