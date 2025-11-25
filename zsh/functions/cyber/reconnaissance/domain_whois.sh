# Fonction pour effectuer un whois sur un domaine
# DESC: Effectue une recherche WHOIS sur un domaine pour obtenir des informations sur le propriétaire, le registrar, les serveurs DNS, etc.
# USAGE: domain_whois <domain>
# EXAMPLE: domain_whois example.com
function domain_whois() {
    if [ $# -eq 0 ]; then
        echo "Usage: domain_whois <domain>"
        echo "Effectue un whois sur un domaine."
        echo "Exemple: domain_whois example.com"
        return 1
    fi
    whois $1
}
