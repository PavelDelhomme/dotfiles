

# Fonction pour vérifier les certificats SSL d'un domaine
function check_ssl() {
    if [ $# -eq 0 ]; then
        echo "Usage: check_ssl <domain>"
        echo "Vérifie les certificats SSL d'un domaine."
        echo "Exemple: check_ssl example.com"
        return 1
    fi
    local domain=$1
    echo -e "\e[1;36mChecking SSL certificate for $domain\e[0m"
    echo | openssl s_client -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -noout -dates -subject -issuer | sed 's/^/  /'
}
