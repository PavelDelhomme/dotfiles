set PATH_BACKUP_FILE "$HOME/dotfiles/fish/PATH_SAVE"
set PATH_LOG_FILE "$HOME/dotfiles/fish/path_log.txt"
set DEFAULT "$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

function clean_invalid_paths
    set cleaned_path
    for dir in $PATH
        if test -d "$dir"
            set -a cleaned_path $dir
        else
            echo "Répertoire inexistant supprimé du PATH : $dir"
            add_logs "REMOVE" "Répertoire inexistant supprimé : $dir"
        end
    end
    set -gx PATH $cleaned_path
    add_logs "CLEAN" "PATH nettoyé des répertoires inexistants"
end

