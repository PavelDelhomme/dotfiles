# DESC: Capture le trafic réseau sur une interface spécifiée
# USAGE: sniff_traffic <interface>
sniff_traffic() {
    # Vérifier et installer tcpdump si nécessaire
    UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        source "$UTILS_DIR/ensure_tool.sh"
        ensure_tool tcpdump || return 1
    fi
    
    local interface="$1"
    
    if [ -z "$interface" ]; then
        echo "Usage: sniff_traffic <interface>"
        return 1
    fi
    
    sudo tcpdump -i "$interface" -w capture.pcap
}
