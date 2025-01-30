
# Fonction pour scanner les vulnérabilités avec Nikto
function scan_vulns() {
    if [ $# -eq 0 ]; then
        echo "Usage: scan_vulns <url>"
        echo "Scanne un site web pour détecter des vulnérabilités."
        echo "Exemple: scan_vulns http://example.com"
        return 1
    fi

    local url=$1
    nikto -h "$url"
}
