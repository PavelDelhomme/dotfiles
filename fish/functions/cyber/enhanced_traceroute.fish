function enhanced_traceroute
    if test (count $argv) -eq 0
        echo "Usage: enhanced_traceroute <target>"
        echo "Effectue un traceroute avec des informations détaillées."
        echo "Exemple: enhanced_traceroute example.com"
        return 1
    end
    set target $argv[1]
    echo -e "\e[1;36mPerforming enhanced traceroute to $target\e[0m"
    traceroute -I $target | while read -l line
        set ip (echo $line | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
        if test -n "$ip"
            set whois_info (whois $ip | grep -E "Organization|Country" | sed 's/^/    /')
            echo -e "$line\n$whois_info"
        else
            echo $line
        end
    end
end

