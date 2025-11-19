#!/bin/zsh
# =============================================================================
# Fonctions utilitaires pour fichiers et archives
# =============================================================================

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

# DESC: Crée une archive compressée
# USAGE: archive <file_or_dir> [format: tar.gz|tar.bz2|zip|7z]
archive() {
	local source="$1"
	local format="${2:-tar.gz}"
	local name=$(basename "$source")
	
	if [[ ! -e "$source" ]]; then
		echo "❌ Fichier/répertoire non trouvé: $source"
		return 1
	fi
	
	echo "📦 Création archive: $name.$format"
	
	case "$format" in
		tar.gz|tgz)
			tar czf "${name}.tar.gz" "$source" && echo "✅ Archive créée: ${name}.tar.gz"
			;;
		tar.bz2)
			tar cjf "${name}.tar.bz2" "$source" && echo "✅ Archive créée: ${name}.tar.bz2"
			;;
		tar.xz)
			tar cJf "${name}.tar.xz" "$source" && echo "✅ Archive créée: ${name}.tar.xz"
			;;
		zip)
			zip -r "${name}.zip" "$source" && echo "✅ Archive créée: ${name}.zip"
			;;
		7z)
			7z a "${name}.7z" "$source" && echo "✅ Archive créée: ${name}.7z"
			;;
		*)
			echo "❌ Format non supporté: $format (tar.gz, tar.bz2, tar.xz, zip, 7z)"
			return 1
			;;
	esac
}

# DESC: Affiche la taille d'un fichier ou répertoire
# USAGE: file_size <file_or_dir>
file_size() {
	local target="$1"
	
	if [[ ! -e "$target" ]]; then
		echo "❌ Fichier/répertoire non trouvé: $target"
		return 1
	fi
	
	if [[ -d "$target" ]]; then
		du -sh "$target" | awk '{print $1}'
	else
		ls -lh "$target" | awk '{print $5}'
	fi
}

# DESC: Trouve les fichiers les plus volumineux
# USAGE: find_large_files [directory] [size]
find_large_files() {
	local dir="${1:-.}"
	local size="${2:-100M}"
	
	echo "🔍 Recherche fichiers > $size dans: $dir"
	find "$dir" -type f -size +"$size" -exec ls -lh {} \; 2>/dev/null | awk '{print $5, $9}' | sort -hr
}

# DESC: Trouve les fichiers dupliqués
# USAGE: find_duplicates [directory]
find_duplicates() {
	local dir="${1:-.}"
	
	echo "🔍 Recherche fichiers dupliqués dans: $dir"
	find "$dir" -type f -exec md5sum {} \; 2>/dev/null | \
		sort | uniq -d -w 32 | \
		awk '{print $2}' | \
		xargs -I {} md5sum {} 2>/dev/null | \
		sort
}

