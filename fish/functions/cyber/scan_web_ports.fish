function scan_web_ports
    if test (count $argv) -eq 0
        echo "Usage: scan_web_ports <target> [start_port] [end_port]"
        echo "Scanne les ports ouverts d'un site web."
        echo "Exemple: scan_web_ports example.com 1 1000"
        return 1
    end
    set target $argv[1]
    set start_port $argv[2]
    set end_port $argv[3]
    set -q start_port[1]; or set start_port 1
    set -q end_port[1]; or set end_port 1000

    echo "Scanning ports $start_port to $end_port on $target"
    for port in (seq $start_port $end_port)
        if nc -z -w1 $target $port 2>/dev/null
            echo "Port $port is open"
        end
    end
end

