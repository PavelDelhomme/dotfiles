function scan_ports
    set target $argv[1]
    set ports $argv[2]
    set -q ports[1]; or set ports 1-65535
    sudo nmap -p $ports $target
end

