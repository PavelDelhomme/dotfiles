# ~/.zsh/functions/alias_manager/add_alias.sh

ALIASES_FILE="$HOME/dotfiles/zsh/aliases.zsh"

# DESC: Ajoute un nouvel alias au fichier des alias
# USAGE: add_alias <name> <command> [description]
add_alias() {
	local name="$1"
	local command="$2"
	local description="${3:-}" # Decription optionnelle

	if [[ ! -f "$ALIASES_FILE" ]]; then
    		echo "❌ Le fichier $ALIASES_FILE n'existe pas."
    		return 1
	fi


	if grep -q "^alias $name=" "$ALIASES_FILE"; then
		echo " !  L'alias '$name' existe déjà."
		return 1
	fi

	# Ajoute la description si fournie
	if [[ -n "$description" ]]; then
		echo "# DESC: $description" >> "$ALIASES_FILE"
	fi

	echo "alias $name=\"$command\"" >> "$ALIASES_FILE"
	source "$ALIASES_FILE"
	alias $name="$command"
	echo "Alias '$name' ajouté et chargé."
}
