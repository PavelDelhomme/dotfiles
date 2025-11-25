# DESC: Recherche les sous-domaines d'un domaine. Utilise les cibles configurées si aucune n'est fournie.
# USAGE: find_subdomains [domain]
# EXAMPLE: find_subdomains example.com
# EXAMPLE: find_subdomains  # Utilise les cibles configurées
find_subdomains() {
    # Charger le gestionnaire de cibles
    local CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    
    local target=""
    
    if [ $# -gt 0 ]; then
        target="$1"
    elif has_targets; then
        echo "🎯 Utilisation des cibles configurées:"
        show_targets
        echo ""
        printf "Utiliser toutes les cibles? (O/n): "
        read -r use_all
        if [ "$use_all" != "n" ] && [ "$use_all" != "N" ]; then
            # Utiliser toutes les cibles
            for t in "${CYBER_TARGETS[@]}"; do
                local domain="$t"
                if [[ "$t" =~ ^https?:// ]]; then
                    domain=$(echo "$t" | sed -E 's|^https?://||' | sed 's|/.*||')
                fi
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "🔍 Recherche sous-domaines: $domain"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                if command -v subfinder >/dev/null 2>&1; then
                    subfinder -d "$domain"
                else
                    echo "❌ subfinder non installé"
                    echo "💡 Installez-le: go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
                fi
            done
            return 0
        else
            target=$(prompt_target "🎯 Entrez le domaine: ")
            if [ -z "$target" ]; then
                return 1
            fi
        fi
    else
        target=$(prompt_target "🎯 Entrez le domaine: ")
        if [ -z "$target" ]; then
            return 1
        fi
    fi
    
    # Extraire le domaine si c'est une URL
    local domain="$target"
    if [[ "$target" =~ ^https?:// ]]; then
        domain=$(echo "$target" | sed -E 's|^https?://||' | sed 's|/.*||')
    fi
    
    echo "🔍 Recherche des sous-domaines pour: $domain"
    echo ""
    
    if command -v subfinder >/dev/null 2>&1; then
        subfinder -d "$domain"
    else
        echo "❌ subfinder non installé"
        echo "💡 Installez-le: go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
        return 1
    fi
}
