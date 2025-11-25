# DESC: Énumère les partages SMB sur une machine cible
# USAGE: enum_shares <ip_cible>
# EXAMPLE: enum_shares 192.168.1.1
enum_shares() {
    local ip_cible="$1"
    smbclient -L "\\\\$ip_cible" -N
}
