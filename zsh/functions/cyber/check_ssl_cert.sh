
# Fonction pour vérifier les certificats SSL d'un domaine
check_ssl_cert() {
    echo | openssl s_client -servername $1 -connect $1:443 2>/dev/null | openssl x509 -noout -dates -subject -issuer
}

