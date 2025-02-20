function nmap_vuln_scan
    if test (count $argv) -eq 0
        echo "Usage: nmap_vuln_scan <target>"
        echo "Effectue un scan de vulnérabilités avec Nmap."
        echo "Exemple: nmap_vuln_scan example.com"
        return 1
    end
    nmap -sV --script vuln $argv[1]
end

