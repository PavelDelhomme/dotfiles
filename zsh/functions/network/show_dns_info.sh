
# Fonction pour afficher les informations DNS
function show_dns_info() {
    echo -e "\e[1;36mDNS Information:\e[0m"
    cat /etc/resolv.conf | grep nameserver | 
        awk '{printf "  \033[1;33m%-15s\033[0m %s\n", "Nameserver:", $2}'
}

