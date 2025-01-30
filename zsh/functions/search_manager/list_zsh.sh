# DESC: Liste tous les alias et fonctions avec leurs descriptions
# USAGE: list_zsh
list_zsh() {
    echo "🔍 Liste des alias et des fonctions ZSH disponibles"
    echo "---------------------------------------------"

    # === Affichage des Alias ===
    echo "📝 Alias définis dans ~/dotfiles/zsh/aliases.zsh"
    grep -E '^# DESC:|^alias ' ~/dotfiles/zsh/aliases.zsh | sed 's/^# DESC:/👉 /'
    echo ""

    # === Affichage des Fonctions ===
    echo "📝 Fonctions définies dans ~/dotfiles/zsh/functions/"
    find ~/dotfiles/zsh/functions/ -type f -name '*.sh' | while read -r file; do
        echo "📄 Fichier : $(basename "$file")"
        awk '
	BEGIN {
		desc = ""
	}
	/^# DESC:/ {
		desc = substr($0, 9)
	}
	/^[[:space:]]*(function[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)[[:space:]]*{/ {
		if (desc != "") {
			printf "📘 Function : %s\n👉 Description : %s\n\n", $0, desc
			desc = ""
		} else {
			printf "📘 Function : %s\n👉 Desciption : (Aucune description)\n\n", $0
		}
	}
	' "$file"

    done
    echo "---------------------------------------------"
    echo "✅ Fin de la liste des alias et fonctions"
}

