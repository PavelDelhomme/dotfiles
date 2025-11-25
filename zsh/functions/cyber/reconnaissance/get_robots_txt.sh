
# Fonction pour obtenir le contenu robots.txt d'un site
# DESC: Récupère et affiche le fichier robots.txt d'un site web pour découvrir les répertoires cachés ou protégés.
# USAGE: get_robots_txt <url>
# EXAMPLE: get_robots_txt https://example.com
function get_robots_txt() {
    if [ $# -eq 0 ]; then
        echo "Usage: get_robots_txt <url>"
        echo "Obtient le contenu robots.txt d'un site."
        echo "Exemple: get_robots_txt https://example.com"
        return 1
    fi
    curl -s $1/robots.txt
}

