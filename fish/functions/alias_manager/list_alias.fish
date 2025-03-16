function list_aliases -d "Liste tous les alias définis avec leurs descriptions"
    # Usage: list_aliases
    #
    # Exemple:
    #   list_aliases
    #
    # Affiche:
    #   Une liste de tous les alias définis avec leurs descriptions

    if not test -f "$ALIASES_FILE"
        echo "❌ Le fichier $ALIASES_FILE n'existe pas."
        return 1
    end

    awk '/^# DESC:/ {desc=$0; getline; print desc "\n" $0 "\n"}' "$ALIASES_FILE" | \
    sed -E 's/^# DESC: /📝 Description: /; s/^alias/👉 Alias:/'
end

