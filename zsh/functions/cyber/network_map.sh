# DESC: Génère une carte du réseau
# USAGE: network_map <network_range>
network_map() {
	local network_range="$1"
	sudo nmap -sn "$network_range"
}

