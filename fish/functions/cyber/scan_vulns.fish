function scan_vulns
    if test (count $argv) -eq 0
        echo "Usage: scan_vulns <url>"
        echo "Scanne un site web pour détecter des vulnérabilités."
        echo "Exemple: scan_vulns http://example.com"
        return 1
    end

    set url $argv[1]
    nikto -h $url
end

