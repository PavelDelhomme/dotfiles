#!/bin/zsh
# =============================================================================
# Fonctions utilitaires pour la gestion des processus
# =============================================================================

# DESC: Tue un processus par nom. Recherche tous les processus correspondant au nom et les arrête proprement.
# USAGE: kill_process <process_name>
# EXAMPLE: kill_process firefox
# EXAMPLE: kill_process "python script.py"
kill_process() {
	local process="$1"
	
	if [[ -z "$process" ]]; then
		echo "❌ Usage: kill_process <process_name>"
		return 1
	fi
	
	local pids=$(pgrep -f "$process")
	
	if [[ -z "$pids" ]]; then
		echo "❌ Processus '$process' non trouvé"
		return 1
	fi
	
	echo "🛑 Arrêt processus: $process"
	echo "$pids" | while read pid; do
		kill "$pid" 2>/dev/null && echo "  ✓ PID $pid arrêté" || echo "  ⚠️  Impossible d'arrêter PID $pid"
	done
}

# DESC: Tue le processus utilisant un port spécifique. Utile pour libérer un port occupé.
# USAGE: kill_port <port>
# EXAMPLE: kill_port 8080
# EXAMPLE: kill_port 3000
kill_port() {
	local port="$1"
	
	if [[ -z "$port" ]]; then
		echo "❌ Usage: kill_port <port>"
		return 1
	fi
	
	local pid=$(lsof -ti:$port 2>/dev/null)
	
	if [[ -z "$pid" ]]; then
		echo "❌ Aucun processus sur le port $port"
		return 1
	fi
	
	echo "🛑 Arrêt processus sur port $port (PID: $pid)"
	kill "$pid" && echo "✅ Processus arrêté" || echo "❌ Échec"
}

# DESC: Affiche les processus utilisant des ports réseau. Sans argument, liste tous les ports en écoute.
# USAGE: port_process [port]
# EXAMPLE: port_process
# EXAMPLE: port_process 8080
port_process() {
	local port="$1"
	
	if [[ -n "$port" ]]; then
		lsof -i:$port 2>/dev/null || echo "❌ Aucun processus sur le port $port"
	else
		echo "🔍 Processus utilisant des ports:"
		lsof -i -P -n | grep LISTEN | awk '{print "  Port " $9 " -> PID " $2 " (" $1 ")"}'
	fi
}

# DESC: Surveille un processus en temps réel avec mise à jour périodique. Affiche les informations du processus à intervalles réguliers.
# USAGE: watch_process <process_name> [interval]
# EXAMPLE: watch_process python
# EXAMPLE: watch_process node 2
watch_process() {
	local process="$1"
	local interval="${2:-1}"
	
	if [[ -z "$process" ]]; then
		echo "❌ Usage: watch_process <process_name> [interval]"
		return 1
	fi
	
	echo "👁️  Surveillance: $process (intervalle: ${interval}s, Ctrl+C pour arrêter)"
	watch -n "$interval" "ps aux | grep -E '$process' | grep -v grep"
}

