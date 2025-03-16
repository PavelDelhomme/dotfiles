set ALIASES_FILE "$HOME/dotfiles/fish/aliases.fish"

function add_alias -d "Ajoute un nouvel alias au fichier d'aliases"
	# Usage : add_alias <name> <command> [description]
	#
	# Arguments:
	# 	name		Le nom de l'alias à ajouter
	# 	command		La commande à exécuter lorsque l'alias est appelé
	# 	description	(optionnel) Une brève description de l'alias
	#
	# Exemple :
	# 	add_alias ll 'ls -la' "Liste détaillée des fichiers, y compris les fichiers cachés"
	#
	# Retourne :
	# 	0 si l'alias a été ajouté avec succès
	# 	1 si une erreur s'est produite
	 
	set name $argv[1]
    	set command $argv[2]
    	set description $argv[3]
	
    	if test (count $argv) -lt 2
        	echo "❌ Usage: add_alias <name> <command> [description]"
        	return 1
	end

    	if not test -f "$ALIASES_FILE"
        	echo "❌ Le fichier $ALIASES_FILE n'existe pas."
        	return 1
    	end
	
    	if grep -q "^alias $name " "$ALIASES_FILE"
        	echo "⚠ L'alias '$name' existe déjà. Utilisez 'modify_alias' pour le modifier."
        	return 1
    	end
	
    	if test -n "$description"
        	echo "# DESC: $description" >> "$ALIASES_FILE"
    	end
	
    	echo "alias $name '$command'" >> "$ALIASES_FILE"
    	source "$ALIASES_FILE"
    	echo "✅ Alias '$name' ajouté et chargé."
end

