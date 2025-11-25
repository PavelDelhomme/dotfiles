# DESC: Crée une sauvegarde d'un fichier avec un horodatage. Le fichier de sauvegarde est créé dans le même répertoire avec le suffixe _backup_YYYYMMDDHHMMSS.
# USAGE: create_backup <file_path>
# EXAMPLE: create_backup ~/.zshrc
# EXAMPLE: create_backup config.txt
create_backup() {
	local file="$1"
	if [[ -f "$file" ]]; then
		local backup_file="${file}_backup_$(date +%Y%m%d%H%M%S)"
		cp "$file" "$backup_file"
		echo "✅ Sauvegarde créée : $backup_file"
	else
		echo "❌ Fichier '$file' introuvable."
	fi
}

