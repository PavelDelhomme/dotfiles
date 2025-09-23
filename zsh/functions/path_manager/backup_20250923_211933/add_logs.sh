PATH_BACKUP_FILE="$HOME/dotfiles/zsh/PATH_SAVE"
PATH_LOG_FILE="$HOME/dotfiles/zsh/path_log.txt"
DEFAULT="$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

# DESC: Ajoute une entrée de log pour une action sur le PATH
# USAGE: add_logs <log_type> <message>
add_logs() {
	local log_type="$1"
	local message="$2"
	ensure_path_log
	echo "[$(date)] [$log_type] $message : $PATH" >> "$PATH_LOG_FILE"
}

