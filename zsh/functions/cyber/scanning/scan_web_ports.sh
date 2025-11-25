# Fonction pour scanner les ports ouverts d'un site web
# DESC: Scanne les ports web courants (80, 443, 8080, etc.) sur une cible pour identifier les services web.
# USAGE: scan_web_ports <target>
# EXAMPLE: scan_web_ports example.com
function scan_web_ports() {
    if [ $# -eq 0 ]; then
        echo "Usage: scan_web_ports <target> [start_port] [end_port]"
        echo "Scanne les ports ouverts d'un site web."
        echo "Exemple: scan_web_ports example.com 1 1000"
        return 1
    fi
    local target=$1
    local start_port=${2:-1}
    local end_port=${3:-1000}
    
    echo "Scanning ports $start_port to $end_port on $target"
    for port in $(seq $start_port $end_port); do
        (echo >/dev/tcp/$target/$port) >/dev/null 2>&1 && echo "Port $port is open"
    done
}
