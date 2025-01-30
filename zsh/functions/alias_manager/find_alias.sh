# DESC: Recherche un alias existant
# USAGE: find_alias <pattern>
find_alias() {
    local pattern="$1"
    grep --color=always -i "$pattern" "$ALIASES_FILE"
}

