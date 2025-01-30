# DESC: Copie le contenu d'un fichier dans le presse-papier
# USAGE: copy_file <file_path>
copy_file() {
	if [[ -f "$1" ]]; then
		cat "$1" | xclip -selection clipboard
		echo "📋 Contenu de '$1' copié dans le presse-papier."
	else
		echo "❌ Fichier '$1' introuvable ou vide."
	fi
}
