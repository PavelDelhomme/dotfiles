set PATH_BACKUP_FILE "$HOME/dotfiles/fish/PATH_SAVE"
set PATH_LOG_FILE "$HOME/dotfiles/fish/path_log.txt"
set DEFAULT "$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

function save_path
    ensure_path_log
    echo "set -gx PATH $PATH" > "$PATH_BACKUP_FILE"
    add_logs "SAVE" "PATH sauvegardé"
end

