function remove_alias
    set name $argv[1]
    if not test -f "$ALIASES_FILE"
        echo "❌ Le fichier $ALIASES_FILE n'existe pas."
        return 1
    end

    if not grep -q "^alias $name " "$ALIASES_FILE"
        echo "⚠ L'alias '$name' n'existe pas."
        return 1
    end

    sed -i "/^alias $name /d" "$ALIASES_FILE"
    functions -e $name 2>/dev/null
    echo "✅ Alias '$name' supprimé."
end

