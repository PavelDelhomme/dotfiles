# DESC: Termine le processus utilisant le port passer en paramètre
# USAGE: kill_port <port> ou bien kill_port <process>
kill_port() {
    local port=$1
    if [ -z "$port" ]; then
        echo "❌ Veuillez spécifier un port à fermer."
        return 1
    fi

    echo "🔍 Recherche des processus utilisant le port $port..."
    PIDS=$(sudo lsof -t -i:$port)

    if [ -z "$PIDS" ]; then
        echo "✅ Aucun processus trouvé sur le port $port."
        return 0
    fi

    echo "⚠️ Les processus suivants utilisent le port $port :"
    echo "$PIDS"

    read -p "❓ Souhaitez-vous tuer ces processus ? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔪 Fermeture des processus sur le port $port..."
        for PID in $PIDS; do
            echo "🛑 Fermeture du PID $PID..."
            sudo kill -9 $PID
        done
        echo "✅ Tous les processus sur le port $port ont été terminés."
    else
        echo "❌ Action annulée."
    fi
}

