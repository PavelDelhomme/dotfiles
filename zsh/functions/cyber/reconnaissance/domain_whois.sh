# Fonction pour effectuer un whois sur un domaine
# DESC: Effectue une recherche WHOIS sur un domaine pour obtenir des informations sur le propriétaire, le registrar, les serveurs DNS, etc. Utilise les cibles configurées si aucune n'est fournie.
# USAGE: domain_whois [domain]
# EXAMPLE: domain_whois example.com
# EXAMPLE: domain_whois  # Utilise les cibles configurées
function domain_whois() {
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
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "🎯 WHOIS: $t"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                whois "$t"
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
    
    whois "$target"
}
