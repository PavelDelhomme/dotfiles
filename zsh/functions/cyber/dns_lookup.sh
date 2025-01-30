# Fonction pour effectuer une recherche DNS
function dns_lookup() {
    if [ $# -eq 0 ]; then
        echo "Usage: dns_lookup <domain>"
        echo "Effectue une recherche DNS."
        echo "Exemple: dns_lookup example.com"
        return 1
    fi
    dig +short $1
}

