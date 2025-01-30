# DESC: Capture le trafic réseau sur une interface spécifiée
# USAGE: sniff_traffic <interface>
sniff_traffic() {
    local interface="$1"
    sudo tcpdump -i "$interface" -w capture.pcap
}
