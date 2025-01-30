PATH_BACKUP_FILE="$HOME/dotfiles/zsh/PATH_SAVE"
PATH_LOG_FILE="$HOME/dotfiles/zsh/path_log.txt"
DEFAULT="$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"


# DESC: Nettoie le PATH de tous les doublons
# USAGE: clean_path
clean_path() {
	local old_IFS="$IFS"
	IFS=':'
	local path_array=($PATH)
	IFS="$old_IFS"
	local new_path=""
	local dir
	
    	# Garde les répertoires critiques
    	local critical_paths=(
		"/bin" "/usr/bin" "/usr/local/bin" "/snap/bin" "$HOME/.local/bin" "$HOME/.dotnet/tools"
		"/usr/local/sbin" "/usr/sbin" "/sbin" "/usr/local/games" "/usr/games"
	)

    	for dir in "${path_array[@]}"; do
        	if [[ -d "$dir" && ":$new_path:" != *":$dir:"* ]]; then
           		new_path="$new_path:$dir"
        	fi
	done

    	# Ajoute les chemins critiques s'ils manquent
    	for critical_path in "${critical_paths[@]}"; do
        	if [[ ":$new_path:" != *":$critical_path:"* ]]; then
            		new_path="$new_path:$critical_path"
        	fi
    	done
	
	export PATH="${new_path#:}"
	add_logs "CLEAN" "PATH nettoyé des doublons et des répertoires inexistants"
	echo "PATH nettoyé : $PATH"
}

