# DESC: Copie le contenu complet d'un fichier dans le presse-papier système. Supporte xclip (X11) et wl-copy (Wayland).
# USAGE: copy_file <file_path>
# EXAMPLE: copy_file ~/.zshrc
# EXAMPLE: copy_file config.txt
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
