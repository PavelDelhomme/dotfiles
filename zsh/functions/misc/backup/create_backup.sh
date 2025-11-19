# DESC: Crée une sauvegarde d'un fichier avec un horodatage
# USAGE: create_backup <file_path>
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

