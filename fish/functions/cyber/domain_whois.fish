function domain_whois
    if test (count $argv) -eq 0
        echo "Usage: domain_whois <domain>"
        echo "Effectue un whois sur un domaine."
        echo "Exemple: domain_whois example.com"
        return 1
    end
    whois $argv[1]
end

