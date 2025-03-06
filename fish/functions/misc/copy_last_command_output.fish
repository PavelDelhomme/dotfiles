function copy_last_command_output
    set -l last_command (history | head -n1)
    if test -z "$last_command"
        echo "❌ Aucune commande trouvée à exécuter."
        return 1
    end

    set -l output (eval $last_command 2>&1)
    set -l exit_code $status

    if test $exit_code -eq 0
        echo "$output" | xclip -selection clipboard
        echo "📋 Sortie de la commande '$last_command' copiée dans le presse-papier."
    else
        echo "❌ Échec de l'exécution de la commande : $last_command"
        echo "Sortie d'erreur :"
        echo "$output"
    end
end

