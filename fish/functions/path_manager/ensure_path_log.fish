set PATH_BACKUP_FILE "$HOME/dotfiles/fish/PATH_SAVE"
set PATH_LOG_FILE "$HOME/dotfiles/fish/path_log.txt"
set DEFAULT "$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

function ensure_path_log
    if not test -f "$PATH_LOG_FILE"
        mkdir -p (dirname "$PATH_LOG_FILE")
        touch "$PATH_LOG_FILE"
    end
end

