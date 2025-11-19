# Fonction pour effectuer un whois sur un domaine
function domain_whois() {
    if [ $# -eq 0 ]; then
        echo "Usage: domain_whois <domain>"
        echo "Effectue un whois sur un domaine."
        echo "Exemple: domain_whois example.com"
        return 1
    fi
    whois $1
}
