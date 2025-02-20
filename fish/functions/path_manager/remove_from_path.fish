set PATH_BACKUP_FILE "$HOME/dotfiles/fish/PATH_SAVE"
set PATH_LOG_FILE "$HOME/dotfiles/fish/path_log.txt"
set DEFAULT "$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

function remove_from_path
    ensure_path_log
    set dir $argv[1]
    if test -z "$dir"
        echo "Usage: remove_from_path <directory>"
        return 1
    end
    if contains $dir $PATH
        set -gx PATH (string match -v $dir $PATH)
        add_logs "REMOVE" "Suppression du répertoire '$dir' du PATH"
        echo "Supprimé : $dir"
    else
        echo "Le répertoire '$dir' n'est pas dans le PATH."
    end
end

