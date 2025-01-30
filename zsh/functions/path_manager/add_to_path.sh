PATH_BACKUP_FILE="$HOME/dotfiles/.zsh/PATH_SAVE"
PATH_LOG_FILE="$HOME/dotfiles/.zsh/path_log.txt"
DEFAULT="$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"


# DESC: Ajoute un répertoire au PATH
# USAGE: add_to_path <directory>
add_to_path() {
	ensure_path_log
	local dir="${1%/}" # Supprime le slash final éventuel
	[[ -z "$dir" ]] && echo "❌ Usage: add_to_path <directory>" && return 1

	# ✅ Vérifie si le répertoire existe
	if [[ ! -d "$dir" ]]; then
		echo "🚫 Le répertoire '$dir' n'existe pas. Non ajouté au PATH."
		add_logs "ERROR" "Tentative d'ajout d'un répertoire inexistant : $dir"
		return 1
	fi

	# ✅ Ajoute uniquement si non présent
	if [[ ":$PATH:" != *":$dir:"* ]]; then
		export PATH="$dir:$PATH"
		echo "✅ Ajouté au PATH : $dir"
	else
		echo "ℹ️ Le répertoire '$dir' est déjà dans le PATH."
	fi
}

