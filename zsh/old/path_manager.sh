
PATH_BACKUP_FILE="$HOME/.zsh/PATH_SAVE"
PATH_LOG_FILE="$HOME/.zsh/path_log.txt"
DEFAULT="$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

# DESC: Crée le fichier de log du PATH si nécessaire
# USAGE: ensure_path_log
ensure_path_log() {
	if [[ ! -f "$PATH_LOG_FILE" ]]; then
		mkdir -p "$(dirname "$PATH_LOG_GILE")"
		touch "$PATH_LOG_FILE"
	fi
}

# DESC: Ajoute une entrée de log pour une action sur le PATH
# USAGE: add_logs <log_type> <message>
add_logs() {
	local log_type="$1"
	local message="$2"
	ensure_path_log
	echo "[$(date)] [$log_type] $message : $PATH" >> "$PATH_LOG_FILE"
}

# DESC: Compresse le fichier de log du PATH
# USAGE: compress_logs
compress_logs() {
	ensure_path_log
	if [[ -f "$PATH_LOG_FILE" ]]; then
		gzip -f "$PATH_LOG_FILE"
		echo "Logs compressés : ${PATH_LOG_FILE}.gz"
	fi
}

# DESC: Sauvegarde le PATH actuel
# USAGE: save_path
save_path() {
	ensure_path_log
	echo "export PATH=\"$PATH\"" > "$PATH_BACKUP_FILE"
	add_logs "SAVE" "PATH sauvegardé"
}

# DESC: Restaure le PATH à partir du fichier de sauvegarde
# USAGE: restore_path
restore_path() {
	ensure_path_log
	if [[ -f "$PATH_BACKUP_FILE" ]]; then
		source "$PATH_BACKUP_FILE"
		add_logs "RESTORE" "PATH restauré depuis la sauvegarde"
		echo "PATH restauré : $PATH"
	else
		add_logs "RESTORE" "Aucune sauvegarde disponible, PATH restauré par défaut"
		eco "Aucune sauvegarde disponible. Restauration par défaut."
		export PATH="$DEFAULT_PATH"
	fi
}

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
    	local critical_paths=("/bin" "/usr/bin" "/usr/local/bin" "/snap/bin" "$HOME/.local/bin" "$HOME/.dotnet/tools")

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

# DESC: Ajoute un répertoire au PATH
# USAGE: add_to_path <directory>
add_to_path() {
	ensure_path_log
	local dir="${1%/}" # Supprime le slash final éventuel
	[[ -z "$dir" ]] && echo "❌ Usage: add_to_path <directory>" && return 1

	# ✅ Vérifie si le répertoire existe
	if [[ ! -d "$dir" ]]; then
		echo "🚫 Le répertoire '$dir' n'existe pas. Non ajouté au PATH."
		add_logs "ERROR" "Tentative d'ajout d'un répertoire inexistant : $dir"
		return 1
	fi

	# ✅ Ajoute uniquement si non présent
	if [[ ":$PATH:" != *":$dir:"* ]]; then
		export PATH="$dir:$PATH"
		echo "✅ Ajouté au PATH : $dir"
	else
		echo "ℹ️ Le répertoire '$dir' est déjà dans le PATH."
	fi
}

# DESC: Supprime un répertoire du PATH
# USAGE: remove_from_path <directory>
remove_from_path() {
	ensure_path_log
	local dir="$1"
	[[ -z "$dir" ]] && echo "Usage: remove_from_path <directory>" && return 1
	if [[ ":$PATH:" == *":$dir:"* ]]; then
		export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "^$dir$" | tr '\n' ':' | sed 's/:$//')
		add_logs "REMOVE" "Suppression du répertoire '$dir' du PATH"
		echo "Supprimé : $dir"
	else
		echo "Le répertoire '$dir' n'est pas dans le PATH."
	fi
}

# DESC: Affiche le contenu du PATH
# USAGE: show_path
show_path() {
	echo "Liste des répertoires dans le PATH :"
	echo "$PATH" | tr ':' '\n'
	add_logs "SHOW" "Affichage du contenu du PATH"
}

# DESC: Nettoie le PATH des répertoires inexistants
# USAGE: clean_invalid_paths
clean_invalid_paths() {
	local cleaned_path=""
	for dir in $(echo "$PATH" | tr ':' '\n'); do
		if [[ -d "$dir" ]]; then
			cleaned_path="$cleaned_path:$dir"
		else
			echo "Répertoire inexistant supprimé du PATH : $dir"
			add_logs "REMOVE" "Réperoire inexistant supprimé : $dir"
		fi
	done
	export PATH="${cleaned_path#:}"
	add_logs "CLEAN" "PATH nettoyé des répertoires inexistants"
}

echo "✔️  ~/.zsh/functions/path_manager.sh chargé avec succès"
