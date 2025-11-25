# DESC: Arrête le service Tor
# USAGE: stop_tor
# EXAMPLE: stop_tor
stop_tor() {
    sudo systemctl stop tor
    echo "Service Tor arrêté."
}
