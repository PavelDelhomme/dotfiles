function delete_alias -d "Supprime un alias existant du fichier d'aliases"
    # Usage: delete_alias <name>
    #
    # Arguments:
    #   name    Le nom de l'alias à supprimer
    #
    # Exemple:
    #   delete_alias ll
    #
    # Retourne:
    #   0 si l'alias a été supprimé avec succès
    #   1 si une erreur s'est produite

    set -l name $argv[1]

    if test -z "$name"
        echo "❌ Usage: delete_alias <name>"
        return 1
    end

    if not test -f "$ALIASES_FILE"
        echo "❌ Le fichier $ALIASES_FILE n'existe pas."
        return 1
    end

    if not grep -q "^alias $name " "$ALIASES_FILE"
        echo "⚠ L'alias '$name' n'existe pas."
        return 1
    end

    sed -i "/^# DESC:.*$name/d" "$ALIASES_FILE"
    sed -i "/^alias $name /d" "$ALIASES_FILE"

    functions -e $name 2>/dev/null
    source "$ALIASES_FILE"
    echo "✅ Alias '$name' supprimé."
end

