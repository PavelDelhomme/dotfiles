
# Fonction pour afficher la table de routage
function show_routing_table() {
    echo -e "\e[1;36mRouting Table:\e[0m"
    ip route | awk '{printf "  \033[1;33m%-20s\033[0m %s\n", $1, $NF}'
}
