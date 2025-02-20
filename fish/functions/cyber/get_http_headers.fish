function get_http_headers
    if test (count $argv) -eq 0
        echo "Usage: get_http_headers <url>"
        echo "Obtient les en-têtes HTTP d'un site web."
        echo "Exemple: get_http_headers https://example.com"
        return 1
    end
    set url $argv[1]
    curl -I -L $url
end

