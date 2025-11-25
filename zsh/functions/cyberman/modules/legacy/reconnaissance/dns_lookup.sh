# Fonction pour effectuer une recherche DNS
# DESC: Effectue une recherche DNS pour un domaine ou un sous-domaine. Affiche les enregistrements A, AAAA, MX, NS, etc. Utilise les cibles configurées si aucune n'est fournie.
# USAGE: dns_lookup [domain]
# EXAMPLE: dns_lookup example.com
# EXAMPLE: dns_lookup  # Utilise les cibles configurées
function dns_lookup() {
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
                # Extraire le domaine si c'est une URL
                local domain="$t"
                if [[ "$t" =~ ^https?:// ]]; then
                    domain=$(echo "$t" | sed -E 's|^https?://||' | sed 's|/.*||')
                fi
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "🎯 DNS Lookup: $domain"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                if command -v dig >/dev/null 2>&1; then
                    dig +short "$domain" ANY
                    dig "$domain" +noall +answer
                elif command -v host >/dev/null 2>&1; then
                    host "$domain"
                elif command -v nslookup >/dev/null 2>&1; then
                    nslookup "$domain"
                else
                    echo "❌ Aucun outil DNS disponible (dig, host, nslookup)"
                    echo "💡 Installez bind-utils: sudo pacman -S bind"
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
    
    echo "🔍 Recherche DNS pour: $domain"
    echo ""
    
    if command -v dig >/dev/null 2>&1; then
        echo "📋 Enregistrements DNS:"
        dig +short "$domain" ANY
        echo ""
        echo "📋 Détails complets:"
        dig "$domain" +noall +answer
    elif command -v host >/dev/null 2>&1; then
        host "$domain"
    elif command -v nslookup >/dev/null 2>&1; then
        nslookup "$domain"
    else
        echo "❌ Aucun outil DNS disponible (dig, host, nslookup)"
        echo "💡 Installez bind-utils: sudo pacman -S bind"
        return 1
    fi
}

