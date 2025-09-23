# DESC: Permet de gérer les ports en écoute sur le système, terminer les processus de manière interactive
# USAGE: network_manager
function network_manager() {
    local REFRESH_INTERVAL=5
    local SELECTED_PORTS=""

    trap 'exit 0' SIGINT

    while true; do
        clear
        echo "📡 Liste des ports en écoute sur le système..."
        echo "Appuyez sur Ctrl+C pour quitter"
        echo

        # Récupérer la liste des ports actifs
        PORTS=$(sudo lsof -i -P -n | grep LISTEN | awk '{print $9, $1, $2, $3}' | sed 's/.*://g' | sort -n)

        if [ -z "$PORTS" ]; then
            echo "❌ Aucun port en écoute trouvé."
            sleep $REFRESH_INTERVAL
            continue
        fi

        # Afficher l'en-tête du tableau
        printf "%-5s %-12s %-15s %-10s %-10s %s\n" "N°" "PORT" "CMD" "PID" "USER" "STATUS"
        echo "---------------------------------------------------------------------"

        local i=1
        while IFS= read -r line; do
            PORT=$(echo $line | awk '{print $1}')
            CMD=$(echo $line | awk '{print $2}')
            PID=$(echo $line | awk '{print $3}')
            USER=$(echo $line | awk '{print $4}')
            
            # Vérifier si le port est sélectionné
            if [[ $SELECTED_PORTS == *"$i"* ]]; then
                STATUS="[X]"
            else
                STATUS="[ ]"
            fi
            
            printf "%-5d %-12s %-15s %-10s %-10s %s\n" "$i" "$PORT" "$CMD" "$PID" "$USER" "$STATUS"
            ((i++))
        done <<< "$PORTS"

        echo
        echo "Entrez les numéros des ports à sélectionner/désélectionner (séparés par des espaces)"
        echo "ou appuyez sur Enter pour rafraîchir, ou 'q' pour quitter, ou 'k' pour tuer les processus sélectionnés:"
        read -t $REFRESH_INTERVAL input

        case $input in
            q|Q) break ;;
            k|K) 
                for num in $SELECTED_PORTS; do
                    PORT=$(echo "$PORTS" | sed -n "${num}p" | awk '{print $1}')
                    PID=$(echo "$PORTS" | sed -n "${num}p" | awk '{print $3}')
                    echo "Tentative de fermeture du port $PORT (PID: $PID)"
                    kill_port $PORT
                done
                SELECTED_PORTS=""
                ;;
            *)
                for num in $input; do
                    if [[ $SELECTED_PORTS == *"$num"* ]]; then
                        SELECTED_PORTS=${SELECTED_PORTS//$num/}
                    else
                        SELECTED_PORTS="$SELECTED_PORTS $num"
                    fi
                done
                ;;
        esac
    done

    echo "✅ Opération terminée."
}

