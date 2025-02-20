function check_heartbleed
    if test (count $argv) -eq 0
        echo "Usage: check_heartbleed <target>"
        echo "Vérifie si un site est vulnérable à Heartbleed."
        echo "Exemple: check_heartbleed example.com"
        return 1
    end
    nmap -p 443 --script ssl-heartbleed $argv[1]
end

