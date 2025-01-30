# ~/.zsh/functions/alias_manager.sh

ALIASES_FILE="$HOME/.zsh/aliases.zsh"


# DESC: Ajoute un nouvel alias au fichier des alias
# USAGE: add_alias <name> <command> [description]
add_alias() {
    local name="$1"
    local command="$2"
    local description="${3:-}"  # Description optionnelle
    
    if grep -q "^alias $name=" "$ALIASES_FILE"; then
        echo "⚠️ L'alias '$name' existe déjà."
        return 1
    fi
    
    # Ajoute la description si elle est fournie
    if [[ -n "$description" ]]; then
	    echo "# DESC: $description" >> "$ALIASES_FILE"
    fi

    echo "alias $name=\"$command\"" >> "$ALIASES_FILE"
    source "$ALIASES_FILE"  # Recharge les alias
    alias $name="$command"
    echo "✅ Alias '$name' ajouté et chargé."
}


# DESC: Modifie un alias existant
# USAGE: modify_alias <name> <new_command> [new_description]
modify_alias() {
    local name="$1"
    local new_command="$2"
    local new_description="${3:-}" # Description optionnelle

    if ! grep -q "^alias $name=" "$ALIASES_FILE"; then
        echo "⚠️ L'alias '$name' n'existe pas."
        return 1
    fi

    # Supprime l'ancienne description et l'alias
    sed -i "/# DESC: /{N;d;}" "$ALIASES_FILE"
    sed -i "/^alias $name=/d" "$ALIASES_FILE"

    # Ajoute la nouvelle description si elle est fournie
    if [[ -n "$new_description" ]]; then
        echo "# DESC: $new_description" >> "$ALIASES_FILE"
    fi

    # Ajoute le nouvel alias
    echo "alias $name=\"$new_command\"" >> "$ALIASES_FILE"
    alias $name="$new_command"
    echo "✅ Alias '$name' modifié avec succès."
}

# DESC: Supprime un alias existant
# USAGE: remove_alias <name>
remove_alias() {
    local name="$1"

    if ! grep -q "^alias $name=" "$ALIASES_FILE"; then
        echo "⚠️ L'alias '$name' n'existe pas."
        return 1
    fi

    sed -i "/^alias $name=/d" "$ALIASES_FILE"
    unalias $name 2>/dev/null
    echo "✅ Alias '$name' supprimé."
}

# DESC: Recherche un alias existant
# USAGE: find_alias <pattern>
find_alias() {
    local pattern="$1"
    grep --color=always -i "$pattern" "$ALIASES_FILE"
}

# DESC: Liste tous les alias existants
# USAGE: list_aliases
list_aliases() {
    cat "$ALIASES_FILE"
}

# DESC: Recharge tous les alias du fichier
# USAGE: reload_aliases
reload_aliases() {
    source "$ALIASES_FILE"
}

