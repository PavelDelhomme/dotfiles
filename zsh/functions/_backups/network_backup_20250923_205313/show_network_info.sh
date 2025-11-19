#!/bin/bash

#function show_network_info() {
#    echo -e "\n\e[1;36m=== Informations réseau ===\e[0m\n"
#
#    # Obtenir la liste des interfaces
#    interfaces=$(ip -o link show | awk -F': ' '{print $2}')
#
#    for interface in $interfaces; do
#        echo -e "\e[1;33m=== Interface : $interface ===\e[0m"
#        
#        # Informations générales
#        echo -e "\e[1;32mInformations générales :\e[0m"
#        ip -c -d link show $interface | sed 's/^/  /'
#        
#        # Adresses IP
#        echo -e "\n\e[1;32mAdresses IP :\e[0m"
#        printf "  \e[1;34m%-15s %-20s %-20s %-15s\e[0m\n" "Type" "Adresse" "Broadcast" "Scope"
#        ip -c -d addr show $interface | grep -E "inet|inet6" | while read line; do
#            ip_type=$(echo $line | awk '{print $1}')
#            ip_addr=$(echo $line | awk '{print $2}')
#            broadcast=$(echo $line | grep -oP 'brd \K\S+' || echo "N/A")
#            scope=$(echo $line | grep -oP 'scope \K\S+')
#            printf "  %-15s %-20s %-20s %-15s\n" "$ip_type" "$ip_addr" "$broadcast" "$scope"
#        done
#        
#        # Statistiques
#        echo -e "\n\e[1;32mStatistiques :\e[0m"
#        printf "  \e[1;34m%-20s %-20s\e[0m\n" "RX packets" "TX packets"
#        rx_tx=$(ip -s link show $interface | grep -E "RX|TX" | awk '{print $2}' | paste -sd ' ')
#        printf "  %-20s %-20s\n" $rx_tx
#        
#        echo -e "\n"
#    done
#}

# Fonction pour afficher les informations réseau
function show_network_info() {
    echo -e "\n\e[1;36m=== Informations réseau ===\e[0m\n"

    interfaces=$(ip -o link show | awk -F': ' '{print $2}')

    for interface in $interfaces; do
        echo -e "\e[1;33m=== Interface : $interface ===\e[0m"
        
        echo -e "\n\e[1;32mInformations générales :\e[0m"
        ip -c -d link show $interface | sed 's/^/  /'
        
        echo -e "\n\e[1;32mAdresses IP :\e[0m"
        printf "  \e[1;34m%-15s %-20s %-20s %-15s\e[0m\n" "Type" "Adresse" "Broadcast" "Scope"
        ip -c -d addr show $interface | grep -E "inet|inet6" | while read line; do
            ip_type=$(echo $line | awk '{print $1}')
            ip_addr=$(echo $line | awk '{print $2}')
            broadcast=$(echo $line | grep -oP 'brd \K\S+' || echo "N/A")
            scope=$(echo $line | grep -oP 'scope \K\S+')
            printf "  %-15s %-20s %-20s %-15s\n" "$ip_type" "$ip_addr" "$broadcast" "$scope"
        done
        
        echo -e "\n\e[1;32mStatistiques :\e[0m"
        rx_tx=$(ip -s link show $interface | grep -E "RX|TX" | awk '{print $2}')
        rx=$(echo $rx_tx | awk '{print $1}')
        tx=$(echo $rx_tx | awk '{print $2}')
        printf "  \e[1;34m%-20s %-20s\e[0m\n" "RX packets" "TX packets"
        printf "  %-20s %-20s\n" "$rx" "$tx"
        
        echo -e "\n"
    done
}
