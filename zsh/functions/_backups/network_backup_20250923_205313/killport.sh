killport() {
  if [[ -z "$1" ]]; then
    echo "Usage: killport <port_number>"
    echo "Exemple: killport 5433"
    return 1
  fi
  
  local port=$1
  local pids=$(sudo lsof -ti :$port)
  
  if [[ -z "$pids" ]]; then
    echo "❌ Aucun processus trouvé sur le port $port"
    return 1
  fi
  
  echo "🔍 Processus trouvés sur le port $port :"
  sudo lsof -i :$port
  echo
  echo "🚫 Kill des PID: $pids"
  
  for pid in $pids; do
    kill $pid && echo "✔️ PID $pid killé" || echo "❌ Impossible de kill PID $pid"
  done
}

