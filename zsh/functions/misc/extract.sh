# DESC: Extrait automatiquement des fichiers d'archive (tar, zip, rar, etc.)
# USAGE: extract <file_path>
extract() {
	if [[ -f "$1" ]]; then
		case "$1" in
			*.tar.bz2) tar xvjf "$1" ;;
			*.tar.gz) tar xvzf "$1" ;;
			*.tar.xz) tar xvJf "$1" ;;
			*.tar) tar xvf "$1" ;;
			*.gz) gunzip "$1" ;;
			*.bz2) bunzip2 "$1" ;;
			*.xz) unxz "$1" ;;
			*.zip) unzip "$1" ;;
			*.rar) unrar x "$1" ;;
			*.7z) 7z x "$1" ;;
			*) echo "❌ Format de fichier non pris en charge: '$1'" ;;
		esac
	else
		echo "❌ Fichier '$1' introuvable."
	fi
}


