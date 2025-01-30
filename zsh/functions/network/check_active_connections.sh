# Fonction pour vérifier les connexions actives
function check_active_connections() {
    echo -e "\e[1;36mActive network connections:\e[0m"
    ss -tunapl | grep ESTAB | awk '{print $5, $6}' | 
        awk -F":" '{print $1, $2}' | sort -u |
        awk '{printf "  \033[1;33m%-20s\033[0m %-20s\n", $1, $2}'
}
