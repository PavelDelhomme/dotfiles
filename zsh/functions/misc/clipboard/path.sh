#!/bin/zsh
# =============================================================================
# Fonctions utilitaires pour copier des chemins
# =============================================================================

# DESC: Copie le chemin absolu du fichier/répertoire actuel dans le presse-papier
# USAGE: copy_path [file_or_dir]
copy_path() {
	local target="${1:-$(pwd)}"
	local abs_path=$(realpath "$target" 2>/dev/null || readlink -f "$target" 2>/dev/null || echo "$target")
	
	echo -n "$abs_path" | xclip -selection clipboard 2>/dev/null || \
	echo -n "$abs_path" | wl-copy 2>/dev/null || \
	{ echo "❌ xclip ou wl-copy non disponible"; return 1; }
	
	echo "📋 Chemin copié: $abs_path"
}

# DESC: Copie juste le nom du fichier
# USAGE: copy_filename [file]
copy_filename() {
	local file="${1:-.}"
	local name=$(basename "$file")
	
	echo -n "$name" | xclip -selection clipboard 2>/dev/null || \
	echo -n "$name" | wl-copy 2>/dev/null || \
	{ echo "❌ xclip ou wl-copy non disponible"; return 1; }
	
	echo "📋 Nom copié: $name"
}

# DESC: Copie le répertoire parent
# USAGE: copy_parent [file_or_dir]
copy_parent() {
	local target="${1:-.}"
	local parent=$(dirname "$(realpath "$target" 2>/dev/null || readlink -f "$target" 2>/dev/null || echo "$target")")
	
	echo -n "$parent" | xclip -selection clipboard 2>/dev/null || \
	echo -n "$parent" | wl-copy 2>/dev/null || \
	{ echo "❌ xclip ou wl-copy non disponible"; return 1; }
	
	echo "📋 Répertoire parent copié: $parent"
}

