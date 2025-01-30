PATH_BACKUP_FILE="$HOME/dotfiles/.zsh/PATH_SAVE"
PATH_LOG_FILE="$HOME/dotfiles/.zsh/path_log.txt"
DEFAULT="$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

# DESC: Supprime un répertoire du PATH
# USAGE: remove_from_path <directory>
remove_from_path() {
	ensure_path_log
	local dir="$1"
	[[ -z "$dir" ]] && echo "Usage: remove_from_path <directory>" && return 1
	if [[ ":$PATH:" == *":$dir:"* ]]; then
		export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "^$dir$" | tr '\n' ':' | sed 's/:$//')
		add_logs "REMOVE" "Suppression du répertoire '$dir' du PATH"
		echo "Supprimé : $dir"
	else
		echo "Le répertoire '$dir' n'est pas dans le PATH."
	fi
}
