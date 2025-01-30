
# Nouvelle fonction pour effectuer un scan de vulnérabilités avec Nikto
function nikto_scan() {
    if [ $# -eq 0 ]; then
        echo "Usage: nikto_scan <target>"
        echo "Effectue un scan de vulnérabilités avec Nikto."
        echo "Exemple: nikto_scan https://example.com"
        return 1
    fi
    nikto -h $1
}
