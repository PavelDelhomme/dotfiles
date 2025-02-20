function vuln_scan
    set ip_cible $argv[1]
    sudo nmap -sV --script vuln $ip_cible
end

