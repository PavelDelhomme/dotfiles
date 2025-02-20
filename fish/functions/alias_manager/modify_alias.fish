function modify_alias
    set name $argv[1]
    set new_command $argv[2]
    set new_description $argv[3]

    if not test -f "$ALIASES_FILE"
        echo "❌ Le fichier $ALIASES_FILE n'existe pas."
        return 1
    end

    if not grep -q "^alias $name " "$ALIASES_FILE"
        echo "L'alias '$name' n'existe pas."
        return 1
    end

    sed -i "/# DESC: /{N;d;}" "$ALIASES_FILE"
    sed -i "/^alias $name /d" "$ALIASES_FILE"

    if test -n "$new_description"
        echo "# DESC: $new_description" >> "$ALIASES_FILE"
    end

    echo "alias $name '$new_command'" >> "$ALIASES_FILE"
    source "$ALIASES_FILE"
    echo "Alias '$name' modifié avec succès"
end

