
# Nouvelle fonction pour effectuer une énumération DNS avec DNSenum
# DESC: Effectue une énumération DNS complète d'un domaine en utilisant dnsenum pour découvrir les sous-domaines et informations DNS.
# USAGE: dnsenum_scan <domain>
# EXAMPLE: dnsenum_scan example.com
function dnsenum_scan() {
    if [ $# -eq 0 ]; then
        echo "Usage: dnsenum_scan <domain>"
        echo "Effectue une énumération DNS avec DNSenum."
        echo "Exemple: dnsenum_scan example.com"
        return 1
    fi
    dnsenum $1
}
