function analyze_headers -d "Analyse les en-têtes HTTP d'un site web"
    # Usage: analyze_headers <url>
    #
    # Arguments:
    #   url     L'URL du site web à analyser
    #
    # Exemple:
    #   analyze_headers https://example.com
    #
    # Retourne:
    #   Les en-têtes HTTP du site web

    if test (count $argv) -eq 0
        echo "Usage: analyze_headers <url>"
        echo "Analyse les en-têtes HTTP d'un site web."
        echo "Exemple: analyze_headers https://example.com"
        return 1
    end
    set url $argv[1]
    echo -e "\e[1;36mAnalyzing headers for $url\e[0m"
    curl -I -L -s $url | sed 's/^/  /'
end

