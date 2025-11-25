# DESC: Énumération complète des répertoires web d'une URL pour découvrir des fichiers et dossiers non indexés. Utilise les cibles configurées si aucune n'est fournie.
# USAGE: web_dir_enum [url] [wordlist]
# EXAMPLE: web_dir_enum https://example.com
# EXAMPLE: web_dir_enum  # Utilise les cibles configurées
web_dir_enum() {
    # Charger le gestionnaire de cibles
    local CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    
    local url=""
    local wordlist="/usr/share/wordlists/dirb/common.txt"
    
    if [ $# -gt 0 ]; then
        url="$1"
        wordlist=${2:-/usr/share/wordlists/dirb/common.txt}
    elif has_targets; then
        echo "🎯 Utilisation des cibles configurées:"
        show_targets
        echo ""
        printf "Utiliser toutes les cibles? (O/n): "
        read -r use_all
        if [ "$use_all" != "n" ] && [ "$use_all" != "N" ]; then
            # Utiliser toutes les cibles
            for t in "${CYBER_TARGETS[@]}"; do
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "🎯 Énumération: $t"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "🔍 Énumération des répertoires pour $t"
                echo "📚 Utilisation de la wordlist : $wordlist"
                gobuster dir -u "$t" -w "$wordlist" -q -n -e
            done
            return 0
        else
            url=$(prompt_target "🎯 Entrez l'URL cible: ")
            if [ -z "$url" ]; then
                return 1
            fi
        fi
    else
        url=$(prompt_target "🎯 Entrez l'URL cible: ")
        if [ -z "$url" ]; then
            return 1
        fi
    }

    if [ ! -f "$wordlist" ]; then
        echo "❌ Wordlist non trouvée : $wordlist"
        return 1
    fi

    echo "🔍 Énumération des répertoires pour $url"
    echo "📚 Utilisation de la wordlist : $wordlist"
    
    gobuster dir -u "$url" -w "$wordlist" -q -n -e
}

