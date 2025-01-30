# DESC: Scanne une cible à la recherche de vulnérabilités connues
# USAGE: vuln_scan <ip_cible>
vuln_scan() {
    local ip_cible="$1"
    sudo nmap -sV --script vuln "$ip_cible"
}
