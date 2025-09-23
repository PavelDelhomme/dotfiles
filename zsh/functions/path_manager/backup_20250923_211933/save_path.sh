PATH_BACKUP_FILE="$HOME/dotfiles/zsh/PATH_SAVE"
PATH_LOG_FILE="$HOME/dotfiles/zsh/path_log.txt"
DEFAULT="$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

# DESC: Sauvegarde le PATH actuel
# USAGE: save_path
save_path() {
	ensure_path_log
	echo "export PATH=\"$PATH\"" > "$PATH_BACKUP_FILE"
	add_logs "SAVE" "PATH sauvegardé"
}

