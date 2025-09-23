# DESC: Supprime un alias existant
# USAGE: remove_alias <name>
remove_alias() {
    local name="$1"
    if [[ ! -f "$ALIASES_FILE" ]]; then
    	echo "❌ Le fichier $ALIASES_FILE n'existe pas."
    	return 1
    fi

    if ! grep -q "^alias $name=" "$ALIASES_FILE"; then
        echo "⚠️ L'alias '$name' n'existe pas."
        return 1
    fi

    sed -i "/^alias $name=/d" "$ALIASES_FILE"
    unalias $name 2>/dev/null
    echo "✅ Alias '$name' supprimé."
}
