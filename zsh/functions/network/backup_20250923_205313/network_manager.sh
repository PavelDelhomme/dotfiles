network_manager() {
  local SELECTED_PORTS=""
  trap 'exit 0' SIGINT
  while true
  do
    clear
    echo "📡 Liste des ports en écoute sur le système..."
    echo "Appuyez sur Ctrl+C pour quitter"
    echo
    # Extraction complète de la ligne via lsof
    PORTS=$(sudo lsof -i -P -n | grep LISTEN | awk '{print $9, $1, $2, $3, $0}' | sed 's/.*://g' | sort -n)
    if [ -z "$PORTS" ]; then
      echo "❌ Aucun port en écoute trouvé."
      read -n 1 -p "Appuyez sur une touche pour réessayer..." && continue
    fi
    # Ajuster la largeur pour voir la commande complète
    printf "%-5s %-10s %-35s %-10s %-10s %-30s %s\n" "N°" "PORT" "CMD" "PID" "USER" "LIGNE_ORIGINE" "STATUS"
    echo "-----------------------------------------------------------------------------------------------------------------------------"
    local port_lines=()
    local i=1
    while IFS= read -r line; do
      port_lines+=("$line")
      PORT=$(echo $line | awk '{print $1}')
      CMD=$(echo $line | awk '{print $2}')
      PID=$(echo $line | awk '{print $3}')
      USER=$(echo $line | awk '{print $4}')
      LINE_ORIGINE=$(echo $line | cut -d' ' -f5-)
      if [[ $SELECTED_PORTS =~ (^|[[:space:]])"$i"($|[[:space:]]) ]]; then
        STATUS="X"
      else
        STATUS="O"
      fi
      printf "%-5d %-10s %-35s %-10s %-10s %-30.30s %s\n" "$i" "$PORT" "$CMD" "$PID" "$USER" "$LINE_ORIGINE" "$STATUS"
      ((i++))
    done <<< "$PORTS"
    echo
    echo "Entrez les numéros pour (dé)sélectionner, 'r' pour rafraîchir, 'k' pour kill, 'q' pour quitter :"
    read input
    if [[ -z "$input" ]]; then
      continue  # refresh si juste entrée
    fi
    case "$input" in
      (q|Q) break ;;
      (r|R) continue ;;
      (k|K)
        for num in $SELECTED_PORTS; do
          line="${port_lines[$((num-1))]}"
          PORT=$(echo "$line" | awk '{print $1}')
          PID=$(echo "$line" | awk '{print $3}')
          echo "Tentative de fermeture du port $PORT (PID: $PID)..."
          kill $PID && echo "✔️  Processus $PID (port $PORT) killé !" || echo "❌ Impossible de kill $PID."
        done
        SELECTED_PORTS=""
        read -n 1 -p "Appuyez sur une touche pour continuer..." ;;
      (*)
        for num in $input; do
          if [[ $SELECTED_PORTS =~ (^|[[:space:]])"$num"($|[[:space:]]) ]]; then
            SELECTED_PORTS="${SELECTED_PORTS// $num/}"
            SELECTED_PORTS="${SELECTED_PORTS//$num/}"
          else
            SELECTED_PORTS+=" $num"
          fi
        done ;;
    esac
  done
  echo "✅ Opération terminée."
}

