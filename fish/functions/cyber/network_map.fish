function network_map
    set network_range $argv[1]
    sudo nmap -sn $network_range
end

