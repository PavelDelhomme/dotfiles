function modify_alias -d "Modifie un alias existant dans le fichier d'aliases"
    # Usage: modify_alias <name> <new_command> [new_description]
    #
    # Arguments:
    #   name            Le nom de l'alias à modifier
    #   new_command     La nouvelle commande à associer à l'alias
    #   new_description (optionnel) Une nouvelle description pour l'alias
    #
    # Exemple:
    #   modify_alias ll 'ls -lah' "Liste détaillée de tous les fichiers, y compris les fichiers cachés"
    #
    # Retourne:
    #   0 si l'alias a été modifié avec succès
    #   1 si une erreur s'est produite

    set -l name $argv[1]
    set -l new_command $argv[2]
    set -l new_description $argv[3]

    if test (count $argv) -lt 2
        echo "❌ Usage: modify_alias <name> <new_command> [new_description]"
        return 1
    end

    if not test -f "$ALIASES_FILE"
        echo "❌ Le fichier $ALIASES_FILE n'existe pas."
        return 1
    end

    if not grep -q "^alias $name " "$ALIASES_FILE"
        echo "⚠ L'alias '$name' n'existe pas. Utilisez 'add_alias' pour le créer."
        return 1
    end

    sed -i "/^# DESC:.*$name/d" "$ALIASES_FILE"
    sed -i "/^alias $name /d" "$ALIASES_FILE"

    if test -n "$new_description"
        echo "# DESC: $new_description" >> "$ALIASES_FILE"
    end

    echo "alias $name '$new_command'" >> "$ALIASES_FILE"
    source "$ALIASES_FILE"
    echo "✅ Alias '$name' modifié avec succès."
end

