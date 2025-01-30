# DESC: Modifie un alias existant
# USAGE: modify_alias <name> <new_command> <new_description>
modify_alias() {
	local name="$1"
	local new_command="$2"
	local new_description="${3:-}"

	if [[ ! -f "$ALIASES_FILE" ]]; then
    		echo "❌ Le fichier $ALIASES_FILE n'existe pas."
    		return 1
	fi


	if ! grep -q "^alias $name=" "$HOME/dotfiles/zsh/aliases.zsh"; then
		echo "L'alias $name' n'existe pas."
		return 1
	fi

	# Supprime l'ancienne description et alias
	sed -i "/# DESC: /{N;d;}" "$HOME/dotfiles/zsh/aliases.zsh"
	sed -i "/^alias $name=/d" "$HOME/dotfiles/zsh/aliases.zsh"

	# Ajoute la nouvele description si elle est fournie
	if [[ -n "$new_description" ]]; then
		echo "# DESC: $new_description" >> "$HOME/dotfiles/zsh/aliases.zsh"
	fi

	# Ajoute le nouvel alias
	echo "alias $name=\"$new_command\"" >> "$HOME/dotfiles/zsh/aliases.zsh"
	alias $name="$new_command"
	echo "Alias '$name' modifié avec succès"
}
