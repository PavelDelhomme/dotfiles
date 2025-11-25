# DESC: Énumère les utilisateurs sur une machine distante
# USAGE: enumerate_users <ip_address>
# EXAMPLE: enumerate_users 192.168.1.1
enumerate_users() {
	local ip="$1"
	enum4linux -a "$ip"
}
