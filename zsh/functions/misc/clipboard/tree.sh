# DESC: Copie l'arborescence d'un répertoire
# USAGE: copy_tree <directory_path>
copy_tree() {
	local dir="${1:-.}"  # Par défaut, le répertoire actuel
	if [[ ! -d "$dir" ]]; then
		echo "❌ Le répertoire '$dir' n'existe pas."
		return 1
	fi
	local tree_output
	# Exclure les fichiers cachés (.git, .DS_Store, etc.) et mettre le résultat dans une variable
	tree_output=$(tree -a -I '.*' "$dir" 2>/dev/null)
	if [ -n "$tree_output" ]; then
		echo "$tree_output" | xclip -selection clipboard
		echo "📋 Sortie de 'tree' du répertoire '$dir' copiée dans le presse-papier."
	else
		echo "❌ Impossible de générer le 'tree' du répertoire '$dir'."
	fi
}


