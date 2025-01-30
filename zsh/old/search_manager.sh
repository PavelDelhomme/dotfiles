# ~/.zsh/functions/search_manager.sh

# DESC: Liste tous les alias et fonctions avec leurs descriptions
# USAGE: list_zsh
list_zsh() {
    echo "🔍 Liste des alias et des fonctions ZSH disponibles"
    echo "---------------------------------------------"

    # === Affichage des Alias ===
    echo "📝 Alias définis dans ~/.zsh/aliases.zsh"
    grep -E '^# DESC:|^alias ' ~/.zsh/aliases.zsh | sed 's/^# DESC:/👉 /'
    echo ""

    # === Affichage des Fonctions ===
    echo "📝 Fonctions définies dans ~/.zsh/functions/"
    for file in ~/.zsh/functions/*.sh; do
        echo "📄 Fichier : $(basename "$file")"
        gawk '
        BEGIN { 
		desc="";
		func="";
	} 
        /^# DESC:/ { 
            desc = substr($0, index($0, "# DESC:") + 7); 
        }
        /^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)\\(\\)/ { 
            func = $0; 
            if (desc != "") {
                printf "📘 Fonction : %s\n👉 Description : %s\n\n", func, desc;
                desc = "";
            } else {
                printf "📘 Fonction : %s\n👉 Description : (Aucune description)\n\n", func;
            }
        }' "$file"
    done
    echo "---------------------------------------------"
    echo "✅ Fin de la liste des alias et fonctions"
}



# DESC: Recherche un alias ou une fonction dans la configuration ZSH
# USAGE: search_zsh <mot_cle>
search_zsh() {
    local keyword="$1"
    if [[ -z "$keyword" ]]; then
        echo "❌ Usage: search_zsh <mot_cle>"
        return 1
    fi

    echo "🔍 Recherche de '$keyword' dans les alias et fonctions"
    echo "---------------------------------------------"

    # Rechercher dans les alias
    echo "📝 Alias définis dans ~/.zsh/aliases.zsh"
    grep -iE "$keyword" ~/.zsh/aliases.zsh | sed 's/^# DESC:/👉 /'
    echo ""

    # Rechercher dans les fonctions
    echo "📝 Fonctions définies dans ~/.zsh/functions/"
    grep -iE "$keyword" ~/.zsh/functions/*.sh | sed 's/^# DESC:/👉 /'
    echo ""
}

