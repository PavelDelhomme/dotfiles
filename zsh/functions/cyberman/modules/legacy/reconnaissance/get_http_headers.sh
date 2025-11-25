# Fonction pour obtenir les en-têtes HTTP d'un site web
# DESC: Récupère et affiche les en-têtes HTTP d'une URL pour analyser la configuration du serveur web. Utilise les cibles configurées si aucune n'est fournie.
# USAGE: get_http_headers [url]
# EXAMPLE: get_http_headers https://example.com
# EXAMPLE: get_http_headers  # Utilise les cibles configurées
function get_http_headers() {
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
                # Ajouter http:// si pas de schéma
                local target_url="$t"
                if [[ ! "$t" =~ ^https?:// ]]; then
                    target_url="http://$t"
                fi
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "🎯 En-têtes HTTP: $target_url"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                curl -I -L -s "$target_url" 2>&1 | head -30
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
    
    echo "🔍 En-têtes HTTP pour: $url"
    echo ""
    curl -I -L -s "$url" 2>&1
}
