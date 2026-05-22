#!/usr/bin/env sh
# =============================================================================
# TUI CORE - Interface terminal adaptative (POSIX sh)
# =============================================================================
# Utilisable par tout shell (sh, bash, zsh). S'adapte à la taille du terminal.
# Fournit: lignes/colonnes, pagination, menu compact.
# =============================================================================

# Retourne le nombre de lignes du terminal (pour pagination)
tui_lines() {
    if [ -n "$LINES" ] && [ "$LINES" -gt 0 ] 2>/dev/null; then
        echo "$LINES"
        return 0
    fi
    if command -v tput >/dev/null 2>&1; then
        tput lines 2>/dev/null || echo "24"
        return 0
    fi
    echo "24"
}

# Retourne le nombre de colonnes du terminal
tui_cols() {
    if [ -n "$COLUMNS" ] && [ "$COLUMNS" -gt 0 ] 2>/dev/null; then
        echo "$COLUMNS"
        return 0
    fi
    if command -v tput >/dev/null 2>&1; then
        tput cols 2>/dev/null || echo "80"
        return 0
    fi
    echo "80"
}

# Nombre de lignes utilisables pour la liste (après header et prompt)
# Usage: tui_menu_height [lignes_reservees] (défaut 10)
tui_menu_height() {
    local reserve="${1:-10}"
    local lines
    lines=$(tui_lines)
    if [ "$lines" -lt 20 ]; then
        echo "8"
    else
        echo $((lines - reserve))
    fi
}

# Affiche une page d'items (tableau: un item par ligne dans $1, page $2, par_page $3)
# Usage: echo "$items" | tui_show_page page_num per_page
# Ou: tui_show_page "$(printf '%s\n' "${items[@]}")" page_num per_page
tui_show_page() {
    local all_items="$1"
    local page="${2:-0}"
    local per_page="${3:-15}"
    local start end total
    total=$(echo "$all_items" | grep -c . 2>/dev/null || echo "0")
    start=$((page * per_page))
    end=$((start + per_page))
    if [ "$start" -ge "$total" ]; then
        start=0
        page=0
    fi
    echo "$all_items" | sed -n "$((start+1)),$((end))p"
}

# Calcule le nombre de pages
# Usage: tui_page_count num_items per_page
tui_page_count() {
    local num="$1"
    local per="$2"
    if [ "$per" -le 0 ]; then per=15; fi
    echo $(( (num + per - 1) / per ))
}

# Affiche une barre de pagination (texte court)
# Usage: tui_pagination_bar current_page total_pages
tui_pagination_bar() {
    local cur="$1"
    local tot="$2"
    if [ "$tot" -le 1 ]; then return 0; fi
    echo ""
    echo "  --- Page $((cur+1))/$tot (n=suivant p=précédant 0=retour) ---"
}

# Terminal interactif ?
tui_is_tty() {
    [ -t 0 ] && [ -t 1 ]
}

# Colonnes sûres (minimum 20)
tui_cols_safe() {
    _tc=$(tui_cols)
    [ "$_tc" -lt 20 ] && _tc=20
    echo "$_tc"
}

# Mode compact : petit terminal ou non-TTY (aide / CI)
tui_is_compact() {
    if ! tui_is_tty; then
        return 0
    fi
    _tc=$(tui_cols_safe)
    [ "$_tc" -lt 72 ]
}

# Largeur utile pour texte / bordures (évite débordement)
tui_content_width() {
    _tc=$(tui_cols_safe)
    if tui_is_compact; then
        echo $((_tc - 2))
    else
        _w=$((_tc - 4))
        [ "$_w" -gt 76 ] && _w=76
        echo "$_w"
    fi
}

# Répète un caractère N fois (sans seq/bashismes fragiles)
tui_repeat_char() {
    _ch="${1:-─}"
    _n="${2:-40}"
    _i=0
    while [ "$_i" -lt "$_n" ]; do
        printf '%s' "$_ch"
        _i=$((_i + 1))
    done
}

# Ligne horizontale adaptée
tui_hrule() {
    _w=$(tui_content_width)
    if tui_is_compact; then
        tui_repeat_char '-' "$_w"
    else
        tui_repeat_char '═' "$_w"
    fi
    printf '\n'
}

# Tronque une chaîne (suffixe …)
tui_truncate() {
    _text="${1:-}"
    _max="${2:-40}"
    [ "$_max" -lt 4 ] && _max=4
    printf '%s' "$_text" | awk -v m="$_max" '{
        if (length($0) <= m) { print $0; exit }
        print substr($0, 1, m - 1) "…"
    }'
}

# =============================================================================
# PATTERN MENU PAGINÉ (réutilisable par installman, configman, etc.)
# =============================================================================
# 1) Obtenir le nombre d'items par page:
#    per_page=$(tui_menu_height 14)   # 14 = lignes réservées (header + barre + prompt)
#    [ -z "$per_page" ] || [ "$per_page" -lt 5 ] && per_page=15
# 2) Nombre de pages: total_pages=$(( (total_items + per_page - 1) / per_page ))
# 3) Boucle: page=0; while true; do
#      - Afficher header + slice des items: start=$(( page*per_page + 1 )); end=$(( (page+1)*per_page ))
#      - Afficher barre: "Page $((page+1))/$total_pages (n=suivant p=précédant)"
#      - Lire choice
#      - Si choice = "n" et total_pages>1: page=$((page+1)); continue
#      - Si choice = "p" et total_pages>1: page=$((page-1)); continue
#      - Sinon traiter le choix (numéro, lettre, 0=quitter)
# =============================================================================
