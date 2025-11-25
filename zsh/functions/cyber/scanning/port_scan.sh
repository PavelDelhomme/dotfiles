# Fonction pour scanner les ports ouverts sur une adresse IP
# DESC: Effectue un scan de ports sur une cible pour découvrir les ports ouverts et les services en cours d'exécution.
# USAGE: port_scan <target> [ports]
# EXAMPLE: port_scan 192.168.1.1
function port_scan() {
    if [ $# -eq 0 ]; then
        echo "Usage: port_scan <target> [start_port] [end_port]"
        echo "Scanne les ports ouverts sur une adresse IP cible."
        echo "Exemple: port_scan 192.168.1.1 1 1000"
        return 1
    fi
    local target=$1
    local start_port=${2:-1}
    local end_port=${3:-1000}
    
    echo -e "\e[1;36mScanning ports $start_port to $end_port on $target\e[0m"
    for port in $(seq $start_port $end_port); do
        (echo >/dev/tcp/$target/$port) >/dev/null 2>&1 && echo -e "\e[1;32mPort $port is open\e[0m" &
    done
    wait
}

