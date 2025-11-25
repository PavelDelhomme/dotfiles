#!/bin/zsh
# =============================================================================
# Fonctions utilitaires pour le système (disque, RAM, CPU)
# =============================================================================

# DESC: Affiche un résumé complet des informations système : OS, utilisateur, uptime, espace disque, RAM et CPU.
# USAGE: system_info
# EXAMPLE: system_info
system_info() {
	echo "📊 Informations sur le système :"
	echo "─────────────────────────────────"
	echo "Système d'exploitation : $(uname -a)"
	echo "Utilisateur : $USER"
	echo "Uptime : $(uptime -p 2>/dev/null || uptime)"
	echo ""
	echo "Espace disque :"
	df -h / | tail -1 | awk '{print "  Total: " $2 ", Utilisé: " $3 " (" $5 "), Libre: " $4}'
	echo ""
	echo "Utilisation de la RAM :"
	free -h | grep Mem | awk '{print "  Total: " $2 ", Utilisé: " $3 ", Libre: " $4}'
	echo ""
	echo "CPU :"
	echo "  $(nproc) core(s)"
}

# DESC: Affiche les 10 plus gros répertoires/fichiers dans un répertoire donné, triés par taille. Sans argument, utilise le répertoire courant.
# USAGE: disk_usage [directory]
# EXAMPLE: disk_usage ~
# EXAMPLE: disk_usage /var/log
disk_usage() {
	local dir="${1:-.}"
	echo "💾 Utilisation disque: $dir"
	du -sh "$dir"/* 2>/dev/null | sort -hr | head -10
}

# DESC: Nettoie les caches système (pacman, apt, pip, npm) et les fichiers temporaires. Détecte automatiquement le gestionnaire de paquets utilisé.
# USAGE: system_clean
# EXAMPLE: system_clean
system_clean() {
	echo "🧹 Nettoyage système..."
	
	# Cache pacman (Arch)
	if command -v pacman &> /dev/null; then
		sudo pacman -Sc --noconfirm 2>/dev/null || true
		echo "  ✓ Cache pacman nettoyé"
	fi
	
	# Cache apt (Debian)
	if command -v apt &> /dev/null; then
		sudo apt clean 2>/dev/null || true
		sudo apt autoclean 2>/dev/null || true
		echo "  ✓ Cache apt nettoyé"
	fi
	
	# Cache pip
	if command -v pip &> /dev/null; then
		pip cache purge 2>/dev/null || true
		echo "  ✓ Cache pip nettoyé"
	fi
	
	# Cache npm
	if command -v npm &> /dev/null; then
		npm cache clean --force 2>/dev/null || true
		echo "  ✓ Cache npm nettoyé"
	fi
	
	# Fichiers temporaires
	rm -rf /tmp/* 2>/dev/null || true
	rm -rf "$HOME/.cache"/* 2>/dev/null || true
	
	echo "✅ Nettoyage terminé"
}

# DESC: Affiche les processus les plus gourmands en CPU et RAM. Par défaut affiche les 10 premiers.
# USAGE: top_processes [count]
# EXAMPLE: top_processes
# EXAMPLE: top_processes 20
top_processes() {
	local count="${1:-10}"
	echo "🔝 Top $count processus (CPU):"
	ps aux --sort=-%cpu | head -n $((count + 1)) | awk '{printf "  %6.1f%%  %s\n", $3, $11}'
	echo ""
	echo "🔝 Top $count processus (RAM):"
	ps aux --sort=-%mem | head -n $((count + 1)) | awk '{printf "  %6.1f%%  %s\n", $4, $11}'
}

# DESC: Affiche l'espace disque disponible sur un point de montage. Par défaut affiche l'espace sur la racine (/).
# USAGE: disk_space [mount_point]
# EXAMPLE: disk_space
# EXAMPLE: disk_space /home
disk_space() {
	local mount="${1:-/}"
	echo "💾 Espace disque: $mount"
	df -h "$mount" | tail -1 | awk '{
		printf "  Total: %s\n  Utilisé: %s (%s)\n  Libre: %s\n  Disponible: %s\n",
		$2, $3, $5, $4, $6
	}'
}

# DESC: Surveille en temps réel les modifications de fichiers dans un répertoire (création, suppression, modification, déplacement). Nécessite inotify-tools.
# USAGE: watch_directory <directory>
# EXAMPLE: watch_directory ~/Documents
# EXAMPLE: watch_directory /var/log
watch_directory() {
	local dir="$1"
	
	if [[ ! -d "$dir" ]]; then
		echo "❌ Répertoire non trouvé: $dir"
		return 1
	fi
	
	if ! command -v inotifywait &> /dev/null; then
		echo "❌ inotifywait non installé (paquet: inotify-tools)"
		return 1
	fi
	
	echo "👁️  Surveillance: $dir (Ctrl+C pour arrêter)"
	inotifywait -m -r -e modify,create,delete,move "$dir"
}

