# DESC: Démarre le service Tor
# USAGE: start_tor
start_tor() {
    sudo systemctl start tor
    echo "Service Tor démarré."
}
