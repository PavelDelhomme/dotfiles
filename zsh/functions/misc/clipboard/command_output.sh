# DESC: Exécute la dernière commande de l'historique et copie sa sortie dans le presse-papier. Utile pour récupérer rapidement le résultat d'une commande précédente.
# USAGE: copy_last_command_output
# EXAMPLE: copy_last_command_output
copy_last_command_output() {
    local last_command="$(fc -ln -1)"
    
    if [[ -z "$last_command" ]]; then
        echo "❌ Aucune commande trouvée à exécuter."
        return 1
    fi

    # Utilisation de eval avec une redirection pour capturer la sortie
    local output
    output=$(eval "$last_command" 2>&1)
    local exit_code=$?


    if [[ $exit_code -eq 0 ]]; then
	    echo "$output" | xclip -selection clipboard
	    echo "📋 Sortie de la commande '$last_command' copiée dans le presse-papier."
    else
	    echo "❌ Échec de l'exécution de la commande : $last_command"
	    echo "Sortie d'erreur :"
	    echo "$output"
    fi
}

