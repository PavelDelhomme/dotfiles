# Fonction pour énumérer les répertoires avec Gobuster
# DESC: Énumère les répertoires et fichiers d'un site web en utilisant des wordlists pour découvrir du contenu caché. Utilise les cibles configurées si aucune n'est fournie.
# USAGE: enum_dirs [url] [wordlist]
# EXAMPLE: enum_dirs https://example.com
# EXAMPLE: enum_dirs  # Utilise les cibles configurées
function enum_dirs() {
    # Vérifier gobuster
    UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        source "$UTILS_DIR/ensure_tool.sh"
        ensure_tool gobuster || return 1
    fi
    
    # Charger le gestionnaire de cibles
    local CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    
    local url=""
    local wordlist="${2:-/usr/share/wordlists/dirb/common.txt}"
    
    if [ $# -gt 0 ]; then
        url="$1"
        [ -n "$2" ] && wordlist="$2"
    elif has_targets; then
        echo "🎯 Utilisation des cibles configurées:"
        show_targets
        echo ""
        printf "Utiliser toutes les cibles? (O/n): "
        read -r use_all
        if [ "$use_all" != "n" ] && [ "$use_all" != "N" ]; then
            # Utiliser toutes les cibles
            for t in "${CYBER_TARGETS[@]}"; do
                local target_url="$t"
                if [[ ! "$t" =~ ^https?:// ]]; then
                    target_url="http://$t"
                fi
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "🔍 Énumération répertoires: $target_url"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                if [ -f "$wordlist" ]; then
                    gobuster dir -u "$target_url" -w "$wordlist" -q
                else
                    echo "⚠️  Wordlist non trouvée: $wordlist"
                    gobuster dir -u "$target_url" -w /usr/share/wordlists/dirb/common.txt -q 2>/dev/null || echo "❌ Aucune wordlist disponible"
                fi
            done
            return 0
        else
            url=$(prompt_target "🎯 Entrez l'URL: ")
            if [ -z "$url" ]; then
                return 1
            fi
        fi
    else
        url=$(prompt_target "🎯 Entrez l'URL: ")
        if [ -z "$url" ]; then
            return 1
        fi
    fi
    
    # Ajouter http:// si pas de schéma
    if [[ ! "$url" =~ ^https?:// ]]; then
        url="http://$url"
    fi
    
    if [ ! -f "$wordlist" ]; then
        wordlist="/usr/share/wordlists/dirb/common.txt"
    fi
    
    echo "🔍 Énumération des répertoires pour: $url"
    echo "📚 Wordlist: $wordlist"
    echo ""
    
    if [ -f "$wordlist" ]; then
        gobuster dir -u "$url" -w "$wordlist"
    else
        echo "❌ Wordlist non trouvée: $wordlist"
        return 1
    fi
}
