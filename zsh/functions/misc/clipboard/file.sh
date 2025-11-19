# DESC: Copie le contenu d'un fichier dans le presse-papier
# USAGE: copy_file <file_path>
copy_file() {
	local file="$1"
	if [[ -f "$file" ]]; then
		cat "$file" | xclip -selection clipboard 2>/dev/null || \
		cat "$file" | wl-copy 2>/dev/null || \
		{ echo "❌ xclip ou wl-copy non disponible"; return 1; }
		echo "📋 Contenu de '$file' copié dans le presse-papier."
	else
		echo "❌ Fichier '$file' introuvable ou vide."
		return 1
	fi
}
