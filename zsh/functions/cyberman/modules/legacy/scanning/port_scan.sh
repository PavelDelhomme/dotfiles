# Fonction pour scanner les ports ouverts sur une adresse IP
# DESC: Effectue un scan de ports sur une cible pour découvrir les ports ouverts et les services en cours d'exécution. Utilise les cibles configurées si aucune n'est fournie.
# USAGE: port_scan [target] [start_port] [end_port]
# EXAMPLE: port_scan 192.168.1.1
# EXAMPLE: port_scan  # Utilise les cibles configurées
function port_scan() {
    # Charger le gestionnaire de cibles
    local CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    
    local target=""
    local start_port=1
    local end_port=1000
    
    # Si une cible est fournie en argument
    if [ $# -gt 0 ]; then
        target="$1"
        start_port=${2:-1}
        end_port=${3:-1000}
    # Sinon, utiliser les cibles configurées
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
                echo "🎯 Scan de $t"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo -e "\e[1;36mScanning ports $start_port to $end_port on $t\e[0m"
                for port in $(seq $start_port $end_port); do
                    (echo >/dev/tcp/$t/$port) >/dev/null 2>&1 && echo -e "\e[1;32mPort $port is open\e[0m" &
                done
                wait
            done
            return 0
        else
            # Demander quelle cible utiliser
            target=$(prompt_target)
            if [ -z "$target" ]; then
                return 1
            fi
        fi
    else
        # Demander une cible
        target=$(prompt_target)
        if [ -z "$target" ]; then
            return 1
        fi
    fi
    
    echo -e "\e[1;36mScanning ports $start_port to $end_port on $target\e[0m"
    for port in $(seq $start_port $end_port); do
        (echo >/dev/tcp/$target/$port) >/dev/null 2>&1 && echo -e "\e[1;32mPort $port is open\e[0m" &
    done
    wait
}

