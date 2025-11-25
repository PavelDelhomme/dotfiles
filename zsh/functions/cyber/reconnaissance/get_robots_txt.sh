# Fonction pour obtenir le contenu robots.txt d'un site
# DESC: Récupère et affiche le fichier robots.txt d'un site web pour découvrir les répertoires cachés ou protégés. Utilise les cibles configurées si aucune n'est fournie.
# USAGE: get_robots_txt [url]
# EXAMPLE: get_robots_txt https://example.com
# EXAMPLE: get_robots_txt  # Utilise les cibles configurées
function get_robots_txt() {
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
                echo "🤖 robots.txt: $target_url"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                curl -s "$target_url/robots.txt" 2>&1 || echo "❌ robots.txt non accessible"
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
    
    echo "🤖 robots.txt pour: $url"
    echo ""
    curl -s "$url/robots.txt" 2>&1 || echo "❌ robots.txt non accessible"
}

