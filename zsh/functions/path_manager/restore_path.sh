PATH_BACKUP_FILE="$HOME/dotfiles/zsh/PATH_SAVE"
PATH_LOG_FILE="$HOME/dotfiles/zsh/path_log.txt"
DEFAULT="$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

# DESC: Restaure le PATH à partir du fichier de sauvegarde
# USAGE: restore_path
restore_path() {
	ensure_path_log
	if [[ -f "$PATH_BACKUP_FILE" ]]; then
		source "$PATH_BACKUP_FILE"
		add_logs "RESTORE" "PATH restauré depuis la sauvegarde"
		echo "PATH restauré : $PATH"
	else
		add_logs "RESTORE" "Aucune sauvegarde disponible, PATH restauré par défaut"
		eco "Aucune sauvegarde disponible. Restauration par défaut."
		export PATH="$DEFAULT_PATH"
	fi
}
