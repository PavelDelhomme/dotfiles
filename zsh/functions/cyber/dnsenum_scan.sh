
# Nouvelle fonction pour effectuer une énumération DNS avec DNSenum
function dnsenum_scan() {
    if [ $# -eq 0 ]; then
        echo "Usage: dnsenum_scan <domain>"
        echo "Effectue une énumération DNS avec DNSenum."
        echo "Exemple: dnsenum_scan example.com"
        return 1
    fi
    dnsenum $1
}
