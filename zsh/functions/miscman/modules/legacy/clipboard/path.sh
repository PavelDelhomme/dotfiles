#!/bin/zsh
# =============================================================================
# Fonctions utilitaires pour copier des chemins
# =============================================================================

# DESC: Copie le chemin absolu d'un fichier ou répertoire dans le presse-papier. Sans argument, copie le répertoire courant.
# USAGE: copy_path [file_or_dir]
# EXAMPLE: copy_path
# EXAMPLE: copy_path ~/Documents/file.txt
copy_path() {
	local target="${1:-$(pwd)}"
	local abs_path=$(realpath "$target" 2>/dev/null || readlink -f "$target" 2>/dev/null || echo "$target")
	
	echo -n "$abs_path" | xclip -selection clipboard 2>/dev/null || \
	echo -n "$abs_path" | wl-copy 2>/dev/null || \
	{ echo "❌ xclip ou wl-copy non disponible"; return 1; }
	
	echo "📋 Chemin copié: $abs_path"
}

# DESC: Copie uniquement le nom du fichier (basename) dans le presse-papier, sans le chemin.
# USAGE: copy_filename [file]
# EXAMPLE: copy_filename /home/user/file.txt
# EXAMPLE: copy_filename
copy_filename() {
	local file="${1:-.}"
	local name=$(basename "$file")
	
	echo -n "$name" | xclip -selection clipboard 2>/dev/null || \
	echo -n "$name" | wl-copy 2>/dev/null || \
	{ echo "❌ xclip ou wl-copy non disponible"; return 1; }
	
	echo "📋 Nom copié: $name"
}

# DESC: Copie le chemin du répertoire parent d'un fichier ou répertoire dans le presse-papier.
# USAGE: copy_parent [file_or_dir]
# EXAMPLE: copy_parent ~/Documents/file.txt
# EXAMPLE: copy_parent
copy_parent() {
	local target="${1:-.}"
	local parent=$(dirname "$(realpath "$target" 2>/dev/null || readlink -f "$target" 2>/dev/null || echo "$target")")
	
	echo -n "$parent" | xclip -selection clipboard 2>/dev/null || \
	echo -n "$parent" | wl-copy 2>/dev/null || \
	{ echo "❌ xclip ou wl-copy non disponible"; return 1; }
	
	echo "📋 Répertoire parent copié: $parent"
}

