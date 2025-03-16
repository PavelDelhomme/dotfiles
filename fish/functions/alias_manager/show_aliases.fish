function show_aliases -d "Affiche tous les alias définis avec leurs descriptions"
    # Usage: show_aliases
    #
    # Exemple:
    #   show_aliases
    #
    # Affiche:
    #   Une liste détaillée de tous les alias définis avec leurs descriptions

    if not test -f "$ALIASES_FILE"
        echo "❌ Le fichier $ALIASES_FILE n'existe pas."
        return 1
    end

    echo "Liste des aliases définis :"
    echo "=========================="
    awk '/^# DESC:/ {desc=$0; getline; print desc "\n" $0 "\n"}' "$ALIASES_FILE" | \
    sed -E 's/^# DESC: /📝 Description: /; s/^alias/👉 Alias:/'
    echo "=========================="
end

