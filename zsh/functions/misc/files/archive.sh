#!/bin/zsh
# =============================================================================
# Fonctions utilitaires pour fichiers et archives
# =============================================================================

# DESC: Extrait automatiquement des fichiers d'archive dans le répertoire courant
#       Supporte: tar, tar.gz, tar.bz2, tar.xz, zip, rar, 7z, gz, bz2, xz, deb, rpm, etc.
# USAGE: extract [<file_path>] [--help|-h|help]
# EXAMPLE: extract archive.zip
# EXAMPLE: extract archive.tar.gz
# EXAMPLE: extract  # Affiche l'aide si aucun argument
extract() {
	# Afficher l'aide si demandé ou si aucun argument
	if [[ -z "$1" ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]] || [[ "$1" == "help" ]]; then
		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
		echo "📦 EXTRACT - Extraction automatique d'archives"
		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
		echo ""
		echo "📝 Description:"
		echo "   Extrait automatiquement n'importe quel type d'archive dans le répertoire"
		echo "   courant. La fonction détecte automatiquement le format et utilise l'outil"
		echo "   approprié pour l'extraction."
		echo ""
		echo "💻 Usage:"
		echo "   extract <fichier_archive>"
		echo "   extract                    # Affiche cette aide"
		echo "   extract --help            # Affiche cette aide"
		echo "   extract -h                # Affiche cette aide"
		echo ""
		echo "📚 Formats supportés:"
		echo "   • .tar, .tar.gz, .tar.bz2, .tar.xz, .tgz, .tbz2"
		echo "   • .zip"
		echo "   • .rar"
		echo "   • .7z"
		echo "   • .gz, .bz2, .xz"
		echo "   • .deb (paquets Debian)"
		echo "   • .rpm (paquets Red Hat)"
		echo "   • .cpio"
		echo "   • .lzma"
		echo "   • .Z (compress Unix)"
		echo ""
		echo "📚 Exemples:"
		echo "   extract mon_archive.zip"
		echo "   extract backup.tar.gz"
		echo "   extract fichier.rar"
		echo "   extract package.deb"
		echo ""
		echo "💡 Astuces:"
		echo "   • L'extraction se fait dans le répertoire courant"
		echo "   • Les fichiers sont extraits avec leurs permissions d'origine"
		echo "   • Utilisez 'help extract' pour plus d'informations"
		echo "   • Utilisez 'man extract' pour la documentation complète"
		echo ""
		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
		return 0
	fi
	
	local file="$1"
	
	# Vérifier si le fichier existe
	if [[ ! -f "$file" ]]; then
		echo "❌ Erreur: Fichier '$file' introuvable."
		echo ""
		echo "💡 Utilisez 'extract' sans argument pour voir l'aide"
		echo "💡 Utilisez 'extract --help' pour plus d'informations"
		return 1
	fi
	
	# Vérifier si c'est bien un fichier (pas un répertoire)
	if [[ ! -r "$file" ]]; then
		echo "❌ Erreur: Impossible de lire le fichier '$file'"
		return 1
	fi
	
	local filename=$(basename "$file")
	local dirname=$(dirname "$file")
	
	# Se placer dans le répertoire du fichier si nécessaire
	if [[ "$dirname" != "." ]] && [[ "$dirname" != "$(pwd)" ]]; then
		cd "$dirname" 2>/dev/null || {
			echo "❌ Erreur: Impossible d'accéder au répertoire '$dirname'"
			return 1
		}
		file=$(basename "$file")
	fi
	
	echo "📦 Extraction de: $filename"
	echo ""
	
	# Détection et extraction selon l'extension
	case "$file" in
		*.tar.bz2|*.tbz2)
			echo "🔧 Format détecté: tar.bz2"
			tar xvjf "$file" && echo "✅ Extraction terminée avec succès"
			;;
		*.tar.gz|*.tgz)
			echo "🔧 Format détecté: tar.gz"
			tar xvzf "$file" && echo "✅ Extraction terminée avec succès"
			;;
		*.tar.xz|*.txz)
			echo "🔧 Format détecté: tar.xz"
			tar xvJf "$file" && echo "✅ Extraction terminée avec succès"
			;;
		*.tar)
			echo "🔧 Format détecté: tar"
			tar xvf "$file" && echo "✅ Extraction terminée avec succès"
			;;
		*.zip)
			echo "🔧 Format détecté: zip"
			if command -v unzip >/dev/null 2>&1; then
				unzip "$file" && echo "✅ Extraction terminée avec succès"
			else
				echo "❌ Erreur: 'unzip' n'est pas installé"
				echo "💡 Installez-le avec: sudo pacman -S unzip (Arch) ou sudo apt install unzip (Debian)"
				return 1
			fi
			;;
		*.rar)
			echo "🔧 Format détecté: rar"
			if command -v unrar >/dev/null 2>&1; then
				unrar x "$file" && echo "✅ Extraction terminée avec succès"
			elif command -v rar >/dev/null 2>&1; then
				rar x "$file" && echo "✅ Extraction terminée avec succès"
			else
				echo "❌ Erreur: 'unrar' ou 'rar' n'est pas installé"
				echo "💡 Installez-le avec: sudo pacman -S unrar (Arch) ou sudo apt install unrar (Debian)"
				return 1
			fi
			;;
		*.7z)
			echo "🔧 Format détecté: 7z"
			if command -v 7z >/dev/null 2>&1; then
				7z x "$file" && echo "✅ Extraction terminée avec succès"
			else
				echo "❌ Erreur: '7z' n'est pas installé"
				echo "💡 Installez-le avec: sudo pacman -S p7zip (Arch) ou sudo apt install p7zip-full (Debian)"
				return 1
			fi
			;;
		*.gz)
			echo "🔧 Format détecté: gzip"
			gunzip "$file" && echo "✅ Extraction terminée avec succès"
			;;
		*.bz2)
			echo "🔧 Format détecté: bzip2"
			bunzip2 "$file" && echo "✅ Extraction terminée avec succès"
			;;
		*.xz)
			echo "🔧 Format détecté: xz"
			unxz "$file" && echo "✅ Extraction terminée avec succès"
			;;
		*.lzma)
			echo "🔧 Format détecté: lzma"
			unlzma "$file" && echo "✅ Extraction terminée avec succès"
			;;
		*.Z)
			echo "🔧 Format détecté: compress"
			uncompress "$file" && echo "✅ Extraction terminée avec succès"
			;;
		*.deb)
			echo "🔧 Format détecté: Debian package"
			if command -v ar >/dev/null 2>&1; then
				mkdir -p "${file%.deb}"
				cd "${file%.deb}" 2>/dev/null || return 1
				ar x "../$file" && echo "✅ Extraction terminée avec succès"
				cd .. 2>/dev/null
			else
				echo "❌ Erreur: 'ar' n'est pas installé"
				return 1
			fi
			;;
		*.rpm)
			echo "🔧 Format détecté: RPM package"
			if command -v rpm2cpio >/dev/null 2>&1; then
				rpm2cpio "$file" | cpio -idmv && echo "✅ Extraction terminée avec succès"
			else
				echo "❌ Erreur: 'rpm2cpio' n'est pas installé"
				return 1
			fi
			;;
		*.cpio)
			echo "🔧 Format détecté: cpio"
			cpio -idmv < "$file" && echo "✅ Extraction terminée avec succès"
			;;
		*)
			echo "❌ Format de fichier non pris en charge: '$file'"
			echo ""
			echo "📚 Formats supportés:"
			echo "   tar, tar.gz, tar.bz2, tar.xz, zip, rar, 7z, gz, bz2, xz, deb, rpm, cpio, lzma, Z"
			echo ""
			echo "💡 Utilisez 'extract --help' pour plus d'informations"
			return 1
			;;
	esac
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

