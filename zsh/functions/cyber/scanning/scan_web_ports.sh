# Fonction pour scanner les ports ouverts d'un site web
# DESC: Scanne les ports web courants (80, 443, 8080, etc.) sur une cible pour identifier les services web. Utilise les cibles configurées si aucune n'est fournie.
# USAGE: scan_web_ports [target] [start_port] [end_port]
# EXAMPLE: scan_web_ports example.com
# EXAMPLE: scan_web_ports  # Utilise les cibles configurées
function scan_web_ports() {
    # Charger le gestionnaire de cibles
    local CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    
    local target=""
    local start_port=1
    local end_port=1000
    
    if [ $# -gt 0 ]; then
        target="$1"
        start_port=${2:-1}
        end_port=${3:-1000}
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
                echo "🔍 Scan ports web: $domain"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "Scanning ports $start_port to $end_port on $domain"
                for port in $(seq $start_port $end_port); do
                    (timeout 1 bash -c "echo >/dev/tcp/$domain/$port" 2>/dev/null) && echo "Port $port is open"
                done
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
    
    echo "Scanning ports $start_port to $end_port on $domain"
    for port in $(seq $start_port $end_port); do
        (timeout 1 bash -c "echo >/dev/tcp/$domain/$port" 2>/dev/null) && echo "Port $port is open"
    done
}
