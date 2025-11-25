# Fonction pour analyser les en-têtes HTTP d'un site web
# DESC: Analyse les en-têtes HTTP d'une URL et identifie les problèmes de sécurité potentiels (CORS, CSP, etc.). Utilise les cibles configurées si aucune n'est fournie.
# USAGE: analyze_headers [url]
# EXAMPLE: analyze_headers https://example.com
# EXAMPLE: analyze_headers  # Utilise les cibles configurées
function analyze_headers() {
    # Charger le gestionnaire de cibles
    local CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    
    local url=""
    
    if [ $# -gt 0 ]; then
        url="$1"
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
                echo "🔍 Analyse des en-têtes: $target_url"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo -e "\e[1;36mAnalyzing headers for $target_url\e[0m"
                curl -I -L -s "$target_url" 2>&1 | sed 's/^/  /'
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
    
    echo -e "\e[1;36mAnalyzing headers for $url\e[0m"
    echo ""
    curl -I -L -s "$url" 2>&1 | sed 's/^/  /'
}
