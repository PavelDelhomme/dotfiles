# Fonction pour obtenir les en-têtes HTTP d'un site web
function get_http_headers() {
    if [ $# -eq 0 ]; then
        echo "Usage: get_http_headers <url>"
        echo "Obtient les en-têtes HTTP d'un site web."
        echo "Exemple: get_http_headers https://example.com"
        return 1
    fi
    local url=$1
    curl -I -L $url
}
