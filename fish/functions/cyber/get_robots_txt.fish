function get_robots_txt
    if test (count $argv) -eq 0
        echo "Usage: get_robots_txt <url>"
        echo "Obtient le contenu robots.txt d'un site."
        echo "Exemple: get_robots_txt https://example.com"
        return 1
    end
    curl -s $argv[1]/robots.txt
end

