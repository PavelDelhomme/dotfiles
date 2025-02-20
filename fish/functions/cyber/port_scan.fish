function port_scan
    if test (count $argv) -eq 0
        echo "Usage: port_scan <target> [start_port] [end_port]"
        echo "Scanne les ports ouverts sur une adresse IP cible."
        echo "Exemple: port_scan 192.168.1.1 1 1000"
        return 1
    end
    set target $argv[1]
    set start_port $argv[2]
    set end_port $argv[3]
    set -q start_port[1]; or set start_port 1
    set -q end_port[1]; or set end_port 1000

    echo -e "\e[1;36mScanning ports $start_port to $end_port on $target\e[0m"
    for port in (seq $start_port $end_port)
        if nc -z -w1 $target $port 2>/dev/null
            echo -e "\e[1;32mPort $port is open\e[0m"
        end
    end
end

