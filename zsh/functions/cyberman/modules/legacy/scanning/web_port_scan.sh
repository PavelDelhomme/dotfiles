# DESC: Exécute un scan de ports avancé sur une URL cible. Utilise les cibles configurées si aucune n'est fournie.
# USAGE: web_port_scan [url] [options]
# EXAMPLE: web_port_scan example.com
# EXAMPLE: web_port_scan  # Utilise les cibles configurées
web_port_scan() {
    # Vérifier nmap
    UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        source "$UTILS_DIR/ensure_tool.sh"
        ensure_tool nmap || return 1
    fi
    
    # Charger le gestionnaire de cibles
    local CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    
    local target=""
    local option=""
    
    if [ $# -gt 0 ]; then
        target="$1"
        shift
        option="$1"
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
                echo "🔍 Scan de ports web: $domain"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                nmap -Pn "$domain"
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
    
    if [[ -z "$target" ]]; then
        echo "❌ Usage: web_port_scan [url] [options]"
        echo "Options:"
        echo "  -f, --full       Scan complet de tous les ports"
        echo "  -q, --quick      Scan rapide des ports les plus courants"
        echo "  -s, --service    Détection des services"
        return 1
    fi

    case "$option" in
        -f|--full)
            echo "🔍 Exécution d'un scan complet des ports sur $domain"
            nmap -p- -Pn "$domain"
            ;;
        -q|--quick)
            echo "🚀 Exécution d'un scan rapide des ports courants sur $domain"
            nmap -F -Pn "$domain"
            ;;
        -s|--service)
            echo "🔍 Exécution d'un scan avec détection de services sur $domain"
            nmap -sV -Pn "$domain"
            ;;
        *)
            echo "🔍 Exécution d'un scan de ports standard sur $domain"
            nmap -Pn "$domain"
            ;;
    esac
}

