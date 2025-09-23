# DESC: Affiche l'adresse IP publique
# USAGE: show_ip
show_ip() {
	curl -s https://ipinfo.io/ip
}

