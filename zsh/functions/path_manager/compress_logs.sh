PATH_BACKUP_FILE="$HOME/dotfiles/.zsh/PATH_SAVE"
PATH_LOG_FILE="$HOME/dotfiles/.zsh/path_log.txt"
DEFAULT="$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

# DESC: Compresse le fichier de log du PATH
# USAGE: compress_logs
compress_logs() {
	ensure_path_log
	if [[ -f "$PATH_LOG_FILE" ]]; then
		gzip -f "$PATH_LOG_FILE"
		echo "Logs compressés : ${PATH_LOG_FILE}.gz"
	fi
}
