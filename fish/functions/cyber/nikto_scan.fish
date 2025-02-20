function nikto_scan
    if test (count $argv) -eq 0
        echo "Usage: nikto_scan <target>"
        echo "Effectue un scan de vulnérabilités avec Nikto."
        echo "Exemple: nikto_scan https://example.com"
        return 1
    end
    nikto -h $argv[1]
end

