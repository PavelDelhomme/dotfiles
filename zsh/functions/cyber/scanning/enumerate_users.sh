# DESC: Énumère les utilisateurs sur une machine distante
# USAGE: enumerate_users <ip_address>
enumerate_users() {
	local ip="$1"
	enum4linux -a "$ip"
}
