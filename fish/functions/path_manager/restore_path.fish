set PATH_BACKUP_FILE "$HOME/dotfiles/fish/PATH_SAVE"
set PATH_LOG_FILE "$HOME/dotfiles/fish/path_log.txt"
set DEFAULT "$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

function restore_path
    ensure_path_log
    if test -f "$PATH_BACKUP_FILE"
        source "$PATH_BACKUP_FILE"
        add_logs "RESTORE" "PATH restauré depuis la sauvegarde"
        echo "PATH restauré : $PATH"
    else
        add_logs "RESTORE" "Aucune sauvegarde disponible, PATH restauré par défaut"
        echo "Aucune sauvegarde disponible. Restauration par défaut."
        set -gx PATH (string split : "$DEFAULT")
    end
end

