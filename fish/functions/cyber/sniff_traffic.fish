function sniff_traffic
    set interface $argv[1]
    sudo tcpdump -i $interface -w capture.pcap
end

