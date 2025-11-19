# Fonction pour effectuer un traceroute vers un site
function web_traceroute() {
    if [ $# -eq 0 ]; then
        echo "Usage: web_traceroute <target>"
        echo "Effectue un traceroute vers un site."
        echo "Exemple: web_traceroute example.com"
        return 1
    fi
    traceroute $1
}
