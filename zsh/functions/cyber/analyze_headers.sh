# Fonction pour analyser les en-têtes HTTP d'un site web
function analyze_headers() {
    if [ $# -eq 0 ]; then
        echo "Usage: analyze_headers <url>"
        echo "Analyse les en-têtes HTTP d'un site web."
        echo "Exemple: analyze_headers https://example.com"
        return 1
    fi
    local url=$1
    echo -e "\e[1;36mAnalyzing headers for $url\e[0m"
    curl -I -L -s $url | sed 's/^/  /'
}
