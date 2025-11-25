# DESC: Scanne les réseaux Wi-Fi à proximité
# USAGE: wifi_scan
# EXAMPLE: wifi_scan
wifi_scan() {
	sudo iwlist wlan0 scan | grep 'ESSID'
}
