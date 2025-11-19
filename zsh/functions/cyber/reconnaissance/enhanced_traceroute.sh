
# Fonction pour effectuer un traceroute avec des informations détaillées
function enhanced_traceroute() {
    if [ $# -eq 0 ]; then
        echo "Usage: enhanced_traceroute <target>"
        echo "Effectue un traceroute avec des informations détaillées."
        echo "Exemple: enhanced_traceroute example.com"
        return 1
    fi
    local target=$1
    echo -e "\e[1;36mPerforming enhanced traceroute to $target\e[0m"
    traceroute -I $target | while read line; do
        ip=$(echo $line | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
        if [ ! -z "$ip" ]; then
            whois_info=$(whois $ip | grep -E "Organization|Country" | sed 's/^/    /')
            echo -e "$line\n$whois_info"
        else
            echo $line
        fi
    done
}

