#!/bin/zsh
# =============================================================================
# Fonctions utilitaires pour copier du texte
# =============================================================================

# DESC: Copie du texte directement dans le presse-papier système. Supporte xclip (X11) et wl-copy (Wayland).
# USAGE: copy_text <text>
# EXAMPLE: copy_text "Hello World"
# EXAMPLE: copy_text $(date)
copy_text() {
	local text="$*"
	
	if [[ -z "$text" ]]; then
		echo "❌ Usage: copy_text <text>"
		return 1
	fi
	
	echo -n "$text" | xclip -selection clipboard 2>/dev/null || \
	echo -n "$text" | wl-copy 2>/dev/null || \
	{ echo "❌ xclip ou wl-copy non disponible"; return 1; }
	
	echo "📋 Texte copié: ${text:0:50}..."
}

# DESC: Copie le chemin absolu du répertoire de travail actuel dans le presse-papier.
# USAGE: copy_pwd
# EXAMPLE: copy_pwd
copy_pwd() {
	local pwd=$(pwd)
	echo -n "$pwd" | xclip -selection clipboard 2>/dev/null || \
	echo -n "$pwd" | wl-copy 2>/dev/null || \
	{ echo "❌ xclip ou wl-copy non disponible"; return 1; }
	
	echo "📋 Chemin copié: $pwd"
}

# DESC: Exécute une commande et copie sa sortie dans le presse-papier. Utile pour capturer rapidement des résultats.
# USAGE: copy_cmd <command>
# EXAMPLE: copy_cmd "ls -la"
# EXAMPLE: copy_cmd "git log --oneline -5"
copy_cmd() {
	if [[ -z "$*" ]]; then
		echo "❌ Usage: copy_cmd <command>"
		return 1
	fi
	
	local output=$(eval "$*" 2>&1)
	
	if [[ $? -eq 0 ]]; then
		echo -n "$output" | xclip -selection clipboard 2>/dev/null || \
		echo -n "$output" | wl-copy 2>/dev/null || \
		{ echo "❌ xclip ou wl-copy non disponible"; return 1; }
		
		echo "📋 Sortie copiée: ${output:0:50}..."
	else
		echo "❌ Commande échouée"
		return 1
	fi
}

