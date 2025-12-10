# DESC: Effectue une reconnaissance sur un domaine cible. Utilise les cibles configurées si aucune n'est fournie.
# USAGE: recon_domain [domaine]
# EXAMPLE: recon_domain example.com
# EXAMPLE: recon_domain  # Utilise les cibles configurées
recon_domain() {
    # Vérifier theHarvester
    UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        source "$UTILS_DIR/ensure_tool.sh"
        ensure_tool theHarvester || return 1
    fi
    
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
                echo "🔍 Reconnaissance complète: $domain"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                echo "📋 WHOIS:"
                local UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
                if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
                    source "$UTILS_DIR/ensure_tool.sh" 2>/dev/null
                    if ensure_tool whois; then
                        whois "$domain" 2>/dev/null | head -30
                    fi
                elif command -v whois >/dev/null 2>&1; then
                    whois "$domain" 2>/dev/null | head -30
                fi
                echo ""
                echo "📋 DNS:"
                if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
                    source "$UTILS_DIR/ensure_tool.sh" 2>/dev/null
                    if ensure_tool dig; then
                        dig "$domain" any +multiline +noall +answer 2>/dev/null
                    elif ensure_tool host; then
                        host "$domain" 2>/dev/null
                    fi
                elif command -v dig >/dev/null 2>&1; then
                    dig "$domain" any +multiline +noall +answer 2>/dev/null
                elif command -v host >/dev/null 2>&1; then
                    host "$domain" 2>/dev/null
                fi
                echo ""
                echo "📋 theHarvester:"
                theHarvester -d "$domain" -l 500 -b all 2>/dev/null | head -50
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
    
    echo "🔍 Reconnaissance complète pour: $domain"
    echo ""
    
    echo "📋 WHOIS:"
    local UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        source "$UTILS_DIR/ensure_tool.sh" 2>/dev/null
        if ensure_tool whois; then
            whois "$domain" 2>/dev/null | head -30
        fi
    elif command -v whois >/dev/null 2>&1; then
        whois "$domain" 2>/dev/null | head -30
    fi
    echo ""
    echo "📋 DNS:"
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        source "$UTILS_DIR/ensure_tool.sh" 2>/dev/null
        if ensure_tool dig; then
            dig "$domain" any +multiline +noall +answer 2>/dev/null
        elif ensure_tool host; then
            host "$domain" 2>/dev/null
        fi
    elif command -v dig >/dev/null 2>&1; then
        dig "$domain" any +multiline +noall +answer 2>/dev/null
    elif command -v host >/dev/null 2>&1; then
        host "$domain" 2>/dev/null
    fi
    echo ""
    echo "📋 theHarvester:"
    theHarvester -d "$domain" -l 500 -b all 2>/dev/null | head -50
}
