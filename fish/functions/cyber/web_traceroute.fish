function web_traceroute
    if test (count $argv) -eq 0
        echo "Usage: web_traceroute <target>"
        echo "Effectue un traceroute vers un site."
        echo "Exemple: web_traceroute example.com"
        return 1
    end
    traceroute $argv[1]
end

