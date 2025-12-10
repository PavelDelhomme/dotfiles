# Fonction pour effectuer un traceroute avec des informations détaillées
# DESC: Effectue un traceroute amélioré vers une cible avec des informations détaillées sur chaque saut réseau. Utilise les cibles configurées si aucune n'est fournie.
# USAGE: enhanced_traceroute [target]
# EXAMPLE: enhanced_traceroute example.com
# EXAMPLE: enhanced_traceroute  # Utilise les cibles configurées
function enhanced_traceroute() {
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
                echo "🛤️  Traceroute: $domain"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo -e "\e[1;36mPerforming enhanced traceroute to $domain\e[0m"
                local UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
                if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
                    source "$UTILS_DIR/ensure_tool.sh" 2>/dev/null
                    if ensure_tool traceroute; then
                        ensure_tool whois 2>/dev/null  # Optionnel pour whois
                        traceroute -I "$domain" 2>/dev/null | while IFS= read -r line; do
                            ip=$(echo "$line" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)
                            if [ -n "$ip" ] && command -v whois >/dev/null 2>&1; then
                                whois_info=$(whois "$ip" 2>/dev/null | grep -E "Organization|Country|OrgName|CountryCode" | head -2 | sed 's/^/    /')
                                echo -e "$line"
                                [ -n "$whois_info" ] && echo "$whois_info"
                            else
                                echo "$line"
                            fi
                        done
                    fi
                elif command -v traceroute >/dev/null 2>&1; then
                    traceroute -I "$domain" 2>/dev/null | while IFS= read -r line; do
                        ip=$(echo "$line" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)
                        if [ -n "$ip" ] && command -v whois >/dev/null 2>&1; then
                            whois_info=$(whois "$ip" 2>/dev/null | grep -E "Organization|Country|OrgName|CountryCode" | head -2 | sed 's/^/    /')
                            echo -e "$line"
                            [ -n "$whois_info" ] && echo "$whois_info"
                        else
                            echo "$line"
                        fi
                    done
                else
                    echo "❌ traceroute non installé"
                    echo "💡 Installez-le: sudo pacman -S traceroute"
                fi
            done
            return 0
        else
            target=$(prompt_target "🎯 Entrez la cible: ")
            if [ -z "$target" ]; then
                return 1
            fi
        fi
    else
        target=$(prompt_target "🎯 Entrez la cible: ")
        if [ -z "$target" ]; then
            return 1
        fi
    fi
    
    # Extraire le domaine si c'est une URL
    local domain="$target"
    if [[ "$target" =~ ^https?:// ]]; then
        domain=$(echo "$target" | sed -E 's|^https?://||' | sed 's|/.*||')
    fi
    
    echo -e "\e[1;36mPerforming enhanced traceroute to $domain\e[0m"
    echo ""
    
    local UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        source "$UTILS_DIR/ensure_tool.sh" 2>/dev/null
        if ensure_tool traceroute; then
            ensure_tool whois 2>/dev/null  # Optionnel pour whois
            traceroute -I "$domain" 2>/dev/null | while IFS= read -r line; do
                ip=$(echo "$line" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)
                if [ -n "$ip" ] && command -v whois >/dev/null 2>&1; then
                    whois_info=$(whois "$ip" 2>/dev/null | grep -E "Organization|Country|OrgName|CountryCode" | head -2 | sed 's/^/    /')
                    echo -e "$line"
                    [ -n "$whois_info" ] && echo "$whois_info"
                else
                    echo "$line"
                fi
            done
            return 0
        else
            return 1
        fi
    elif command -v traceroute >/dev/null 2>&1; then
        traceroute -I "$domain" 2>/dev/null | while IFS= read -r line; do
            ip=$(echo "$line" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)
            if [ -n "$ip" ] && command -v whois >/dev/null 2>&1; then
                whois_info=$(whois "$ip" 2>/dev/null | grep -E "Organization|Country|OrgName|CountryCode" | head -2 | sed 's/^/    /')
                echo -e "$line"
                [ -n "$whois_info" ] && echo "$whois_info"
            else
                echo "$line"
            fi
        done
        return 0
    else
        echo "❌ traceroute non installé"
        echo "💡 Installez-le: sudo pacman -S traceroute"
        return 1
    fi
}

