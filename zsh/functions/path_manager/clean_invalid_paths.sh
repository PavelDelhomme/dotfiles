PATH_BACKUP_FILE="$HOME/dotfiles/.zsh/PATH_SAVE"
PATH_LOG_FILE="$HOME/dotfiles/.zsh/path_log.txt"
DEFAULT="$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

# DESC: Nettoie le PATH des répertoires inexistants
# USAGE: clean_invalid_paths
clean_invalid_paths() {
	local cleaned_path=""
	for dir in $(echo "$PATH" | tr ':' '\n'); do
		if [[ -d "$dir" ]]; then
			cleaned_path="$cleaned_path:$dir"
		else
			echo "Répertoire inexistant supprimé du PATH : $dir"
			add_logs "REMOVE" "Réperoire inexistant supprimé : $dir"
		fi
	done
	export PATH="${cleaned_path#:}"
	add_logs "CLEAN" "PATH nettoyé des répertoires inexistants"
}
