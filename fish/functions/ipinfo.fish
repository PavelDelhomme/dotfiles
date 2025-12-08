# =============================================================================
# IPINFO - Informations IP et réseau complètes (Fish)
# =============================================================================
# Description: Affiche les informations IP (privée, publique), DNS, passerelle, etc.
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

function ipinfo --description "Affiche toutes les informations IP et réseau"
    set -l RED '\033[0;31m'
    set -l GREEN '\033[0;32m'
    set -l YELLOW '\033[1;33m'
    set -l BLUE '\033[0;34m'
    set -l CYAN '\033[0;36m'
    set -l BOLD '\033[1m'
    set -l RESET '\033[0m'
    
    set -l show_public true
    set -l show_private true
    set -l show_dns true
    set -l show_gateway true
    set -l show_all true
    
    # Parser les arguments
    if test (count $argv) -gt 0
        set show_all false
        set show_public false
        set show_private false
        set show_dns false
        set show_gateway false
        
        for arg in $argv
            switch $arg
                case --public --pub
                    set show_public true
                case --private --priv
                    set show_private true
                case --dns
                    set show_dns true
                case --gateway --gw
                    set show_gateway true
                case --all
                    set show_all true
                    set show_public true
                    set show_private true
                    set show_dns true
                    set show_gateway true
                case --help -h
                    echo -e "$CYAN$BOLD""IPINFO - Informations IP et réseau""$RESET\n"
                    echo "Usage: ipinfo [options]"
                    echo ""
                    echo "Options:"
                    echo "  --public, --pub    Afficher uniquement l'IP publique"
                    echo "  --private, --priv  Afficher uniquement l'IP privée"
                    echo "  --dns              Afficher uniquement les DNS"
                    echo "  --gateway, --gw    Afficher uniquement la passerelle"
                    echo "  --all              Afficher toutes les informations (défaut)"
                    echo "  --help, -h         Afficher cette aide"
                    echo ""
                    echo "Alias: wimip, wsmip, wsip, wiam"
                    return 0
            end
        end
    end
    
    echo -e "$CYAN$BOLD""╔════════════════════════════════════════════════════════════════╗""$RESET"
    echo -e "$CYAN$BOLD""║              INFORMATIONS IP ET RÉSEAU                        ║""$RESET"
    echo -e "$CYAN$BOLD""╚════════════════════════════════════════════════════════════════╝""\n"
    
    # IP Privée
    if test "$show_private" = "true"; or test "$show_all" = "true"
        echo -e "$YELLOW$BOLD""📍 IP PRIVÉE (Locale):""$RESET"
        
        if command -v hostname >/dev/null 2>&1
            set -l ip_hostname (hostname -I 2>/dev/null | awk '{print $1}')
            if test -n "$ip_hostname"
                echo -e "  ""$GREEN""hostname -I:""$RESET"" $ip_hostname"
            end
        end
        
        if command -v ip >/dev/null 2>&1
            set -l ip_addr (ip -4 addr show 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
            if test -n "$ip_addr"
                echo -e "  ""$GREEN""ip addr:""$RESET"" $ip_addr"
            end
        end
        
        if command -v ifconfig >/dev/null 2>&1
            set -l ip_ifconfig (ifconfig 2>/dev/null | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1)
            if test -n "$ip_ifconfig"
                echo -e "  ""$GREEN""ifconfig:""$RESET"" $ip_ifconfig"
            end
        end
        echo ""
    end
    
    # IP Publique
    if test "$show_public" = "true"; or test "$show_all" = "true"
        echo -e "$YELLOW$BOLD""🌐 IP PUBLIQUE:""$RESET"
        
        set -l public_ip ""
        
        if command -v curl >/dev/null 2>&1
            set public_ip (curl -s --max-time 3 ifconfig.me 2>/dev/null)
            if test -n "$public_ip"; and echo "$public_ip" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
                echo -e "  ""$GREEN""ifconfig.me:""$RESET"" $public_ip"
            else
                set public_ip (curl -s --max-time 3 icanhazip.com 2>/dev/null)
                if test -n "$public_ip"; and echo "$public_ip" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
                    echo -e "  ""$GREEN""icanhazip.com:""$RESET"" $public_ip"
                else
                    set public_ip (curl -s --max-time 3 ipinfo.io/ip 2>/dev/null)
                    if test -n "$public_ip"; and echo "$public_ip" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
                        echo -e "  ""$GREEN""ipinfo.io:""$RESET"" $public_ip"
                    end
                end
            end
        end
        
        if test -z "$public_ip"
            echo -e "  ""$RED""✗ Impossible de récupérer l'IP publique""$RESET"
            echo -e "  ""$YELLOW""💡 Vérifiez votre connexion internet""$RESET"
        end
        echo ""
    end
    
    # DNS
    if test "$show_dns" = "true"; or test "$show_all" = "true"
        echo -e "$YELLOW$BOLD""🔍 SERVEURS DNS:""$RESET"
        
        if test -f /etc/resolv.conf
            set -l dns_servers (grep -E "^nameserver" /etc/resolv.conf 2>/dev/null | awk '{print $2}' | grep -v "^127\.")
            if test -n "$dns_servers"
                for dns in $dns_servers
                    echo -e "  ""$GREEN""/etc/resolv.conf:""$RESET"" $dns"
                end
            end
        end
        
        if command -v systemd-resolve >/dev/null 2>&1
            set -l dns_systemd (systemd-resolve --status 2>/dev/null | grep "DNS Servers" | awk '{print $3}')
            if test -n "$dns_systemd"
                for dns in $dns_systemd
                    echo -e "  ""$GREEN""systemd-resolve:""$RESET"" $dns"
                end
            end
        end
        echo ""
    end
    
    # Passerelle
    if test "$show_gateway" = "true"; or test "$show_all" = "true"
        echo -e "$YELLOW$BOLD""🚪 PASSERELLE PAR DÉFAUT:""$RESET"
        
        if command -v ip >/dev/null 2>&1
            set -l gateway (ip route show default 2>/dev/null | awk '/default/ {print $3}')
            if test -n "$gateway"
                echo -e "  ""$GREEN""ip route:""$RESET"" $gateway"
            end
        end
        echo ""
    end
end

# Alias
function wimip; ipinfo $argv; end
function wsmip; ipinfo $argv; end
function wsip; ipinfo $argv; end
function wiam; ipinfo $argv; end

