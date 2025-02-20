function arp_spoof
    set interface $argv[1]
    set ip_cible_1 $argv[2]
    set ip_cible_2 $argv[3]
    sudo arpspoof -i $interface -t $ip_cible_1 $ip_cible_2
end

