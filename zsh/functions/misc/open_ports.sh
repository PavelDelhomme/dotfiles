# DESC: Affiche la liste des ports ouverts
# USAGE: open_ports
open_ports() {
	sudo netstat -tuln | grep LISTEN
}
