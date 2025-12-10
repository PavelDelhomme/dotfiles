# Fonction pour effectuer un whois sur un domaine
# DESC: Effectue une recherche WHOIS sur un domaine pour obtenir des informations sur le propriétaire, le registrar, les serveurs DNS, etc. Utilise les cibles configurées si aucune n'est fournie.
# USAGE: domain_whois [domain]
# EXAMPLE: domain_whois example.com
# EXAMPLE: domain_whois  # Utilise les cibles configurées
function domain_whois() {
    # Charger le gestionnaire de cibles et le helper d'enregistrement
    local CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    if [ -f "$CYBER_DIR/helpers/auto_save_helper.sh" ]; then
        source "$CYBER_DIR/helpers/auto_save_helper.sh"
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
                echo "🎯 WHOIS: $domain"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                # Vérifier et installer whois si nécessaire
                local UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
                if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
                    source "$UTILS_DIR/ensure_tool.sh" 2>/dev/null
                    if ensure_tool whois; then
                        whois "$domain"
                    fi
                elif command -v whois >/dev/null 2>&1; then
                    whois "$domain"
                else
                    echo "❌ whois non installé"
                    echo "💡 Installez-le: sudo pacman -S whois"
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
    
    echo "🔍 WHOIS pour: $domain"
    echo ""
    
    # Vérifier et installer whois si nécessaire
    local UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        source "$UTILS_DIR/ensure_tool.sh" 2>/dev/null
        if ! ensure_tool whois; then
            return 1
        fi
    elif ! command -v whois >/dev/null 2>&1; then
        echo "❌ whois non installé"
        echo "💡 Installez-le: sudo pacman -S whois"
        return 1
    fi
    
    # Exécuter whois
    local whois_output=$(whois "$domain" 2>&1)
    echo "$whois_output"
    
    # Enregistrer automatiquement le résultat dans l'environnement actif
    auto_save_recon_result "whois" "WHOIS lookup pour $domain" "$whois_output" "success" 2>/dev/null
    
    return 0
}
