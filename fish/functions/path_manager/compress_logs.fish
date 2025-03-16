set PATH_BACKUP_FILE "$HOME/dotfiles/fish/PATH_SAVE"
set PATH_LOG_FILE "$HOME/dotfiles/fish/path_log.txt"
set DEFAULT "$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

function compress_logs
    ensure_path_log
    if test -f "$PATH_LOG_FILE"
        gzip -f "$PATH_LOG_FILE"
        echo "Logs compressés : $PATH_LOG_FILE.gz"
    end
end

