set PATH_BACKUP_FILE "$HOME/dotfiles/fish/PATH_SAVE"
set PATH_LOG_FILE "$HOME/dotfiles/fish/path_log.txt"
set DEFAULT "$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

function add_logs
	set log_type $argv[1]
	set message $argv[2]
	ensure_path_log
	echo "[$(date)] [$log_type] $message : $PATH" >> "$PATH_LOG_FILE"
end
