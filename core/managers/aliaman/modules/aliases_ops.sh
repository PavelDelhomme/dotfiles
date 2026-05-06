#!/bin/sh
# Opérations alias (recherche/liste) extraites du core aliaman.

quick_search() {
    search_term="$1"
    if [ -z "$search_term" ]; then
        printf "${RED}❌ Terme de recherche requis${RESET}\n"
        return 1
    fi

    printf "${CYAN}🔍 Recherche d'alias contenant '$search_term':${RESET}\n"
    results=$(parse_aliases "$search_term")

    if [ -z "$results" ]; then
        printf "${RED}❌ Aucun alias trouvé${RESET}\n"
        return 1
    fi

    echo "$results" | while IFS= read -r line; do
        alias_name=$(echo "$line" | sed -E "s/^alias[[:space:]]+([^=]+)=.*/\\1/")
        alias_command=$(echo "$line" | sed -E "s/^alias[[:space:]]+[^=]+=//")
        alias_command=${alias_command#\"}
        alias_command=${alias_command#\'}
        alias_command=${alias_command%\"}
        alias_command=${alias_command%\'}
        printf "  ${YELLOW}%-20s${RESET} %s\n" "$alias_name" "$alias_command"
    done
}

list_all_aliases() {
    printf "${CYAN}📋 Liste complète des alias:${RESET}\n"
    parse_aliases | while IFS= read -r line; do
        alias_name=$(echo "$line" | sed -E "s/^alias[[:space:]]+([^=]+)=.*/\\1/")
        alias_command=$(echo "$line" | sed -E "s/^alias[[:space:]]+[^=]+=//")
        alias_command=${alias_command#\"}
        alias_command=${alias_command#\'}
        alias_command=${alias_command%\"}
        alias_command=${alias_command%\'}
        printf "  ${YELLOW}%-20s${RESET} %s\n" "$alias_name" "$alias_command"
    done
}

list_aliases_fzf() {
    _rows=$(parse_aliases | while IFS= read -r _line; do
        _name=$(echo "$_line" | sed -E "s/^alias[[:space:]]+([^=]+)=.*/\\1/")
        _cmd=$(echo "$_line" | sed -E "s/^alias[[:space:]]+[^=]+=//")
        _cmd=${_cmd#\"}
        _cmd=${_cmd#\'}
        _cmd=${_cmd%\"}
        _cmd=${_cmd%\'}
        printf "%s\t%s\n" "$_name" "$_cmd"
    done)
    if [ -z "$_rows" ]; then
        printf "${RED}❌ Aucun alias trouvé${RESET}\n"
        return 1
    fi
    _selected=$(printf '%s\n' "$_rows" | \
        fzf --height=85% --layout=reverse --border --ansi \
            --delimiter='\t' --with-nth=1,2 --prompt='Aliaman list > ' \
            --preview='printf "Alias: %s\n\nCommande:\n%s\n" "$(printf "%s" "{}" | cut -f1)" "$(printf "%s" "{}" | cut -f2-)"' \
            --preview-window=right,55%:wrap 2>/dev/null || true)
    [ -n "$_selected" ] || return 0
    _sel_name=$(printf '%s' "$_selected" | cut -f1)
    _sel_cmd=$(printf '%s' "$_selected" | cut -f2-)
    printf "${GREEN}Alias sélectionné:${RESET} ${YELLOW}%s${RESET}\n" "$_sel_name"
    printf "${GREEN}Commande:${RESET} %s\n" "$_sel_cmd"
}
