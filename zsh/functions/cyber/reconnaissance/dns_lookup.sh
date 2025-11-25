# Fonction pour effectuer une recherche DNS
# DESC: Effectue une recherche DNS pour un domaine ou un sous-domaine. Affiche les enregistrements A, AAAA, MX, NS, etc.
# USAGE: dns_lookup <domain>
# EXAMPLE: dns_lookup example.com
function dns_lookup() {
    if [ $# -eq 0 ]; then
        echo "Usage: dns_lookup <domain>"
        echo "Effectue une recherche DNS."
        echo "Exemple: dns_lookup example.com"
        return 1
    fi
    dig +short $1
}

