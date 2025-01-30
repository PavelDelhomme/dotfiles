# DESC: Scan les ports ouverts sur une cible
# USAGE: scan_ports <target> [ports]
scan_ports() {
	local target="$1"
	local ports="${2:-1-65535}"
	sudo nmap -p "$ports" "$target"
}

