PATH_BACKUP_FILE="$HOME/dotfiles/fish/PATH_SAVE"
PATH_LOG_FILE="$HOME/dotfiles/fish/path_log.txt"
DEFAULT="$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

# DESC: Affiche le contenu du PATH
# USAGE: show_path
function show_path() {
	echo "Liste des répertoires dans le PATH :"
	echo "$PATH" | tr ':' '\n'
	add_logs "SHOW" "Affichage du contenu du PATH"
}
