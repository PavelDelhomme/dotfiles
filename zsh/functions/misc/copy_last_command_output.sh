# DESC: Execute la dernière commande et capture la sortie
# USAGE: copy_last_command_output
copy_last_command_output() {
    local last_command="$(fc -ln -1)"
    
    if [[ -z "$last_command" ]]; then
        echo "❌ Aucune commande trouvée à exécuter."
        return 1
    fi

    eval "$last_command" | xclip -selection clipboard

    if [[ $? -eq 0 ]]; then
        echo "📋 Sortie de la commande '$last_command' copiée dans le presse-papier."
    else
        echo "❌ Échec de l'exécution de la commande : $last_command"
    fi
}

