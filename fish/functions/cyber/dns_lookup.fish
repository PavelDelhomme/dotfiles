function dns_lookup
    if test (count $argv) -eq 0
        echo "Usage: dns_lookup <domain>"
        echo "Effectue une recherche DNS."
        echo "Exemple: dns_lookup example.com"
        return 1
    end
    dig +short $argv[1]
end

