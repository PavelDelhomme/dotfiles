#!/bin/zsh
# =============================================================================
# Fonctions utilitaires pour la gestion des processus
# =============================================================================

# DESC: Tue un processus par nom
# USAGE: kill_process <process_name>
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

# DESC: Tue un processus par port
# USAGE: kill_port <port>
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

# DESC: Affiche les processus par port
# USAGE: port_process [port]
port_process() {
	local port="$1"
	
	if [[ -n "$port" ]]; then
		lsof -i:$port 2>/dev/null || echo "❌ Aucun processus sur le port $port"
	else
		echo "🔍 Processus utilisant des ports:"
		lsof -i -P -n | grep LISTEN | awk '{print "  Port " $9 " -> PID " $2 " (" $1 ")"}'
	fi
}

# DESC: Surveille un processus
# USAGE: watch_process <process_name> [interval]
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

