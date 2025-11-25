# DESC: Affiche des informations de base sur le système : OS, utilisateur, uptime, espace disque et RAM.
# USAGE: system_info
# EXAMPLE: system_info
system_info() {
	echo "📊 Informations sur le système :"
	echo "-------------------------------"
	echo "Système d'exploitation : $(uname -a)"
	echo "Utilisateur : $USER"
	echo "Uptime : $(uptime -p)"
	echo "Espace disque :"
	df -h /
	echo "Utilisation de la RAM :"
	free -h
}
