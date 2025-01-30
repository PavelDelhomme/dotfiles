
# Nouvelle fonction pour effectuer un scan de vulnérabilités avec Nmap
function nmap_vuln_scan() {
    if [ $# -eq 0 ]; then
        echo "Usage: nmap_vuln_scan <target>"
        echo "Effectue un scan de vulnérabilités avec Nmap."
        echo "Exemple: nmap_vuln_scan example.com"
        return 1
    fi
    nmap -sV --script vuln $1
}
