PATH_BACKUP_FILE="$HOME/dotfiles/.zsh/PATH_SAVE"
PATH_LOG_FILE="$HOME/dotfiles/.zsh/path_log.txt"
DEFAULT="$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

# DESC: Crée le fichier de log du PATH si nécessaire
# USAGE: ensure_path_log
ensure_path_log() {
	if [[ ! -f "$PATH_LOG_FILE" ]]; then
		mkdir -p "$(dirname "$PATH_LOG_GILE")"
		touch "$PATH_LOG_FILE"
	fi
}
