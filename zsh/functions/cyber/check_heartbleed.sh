
# Fonction pour vérifier si un site est vulnérable à Heartbleed
function check_heartbleed() {
    if [ $# -eq 0 ]; then
        echo "Usage: check_heartbleed <target>"
        echo "Vérifie si un site est vulnérable à Heartbleed."
        echo "Exemple: check_heartbleed example.com"
        return 1
    fi
    nmap -p 443 --script ssl-heartbleed $1
}

