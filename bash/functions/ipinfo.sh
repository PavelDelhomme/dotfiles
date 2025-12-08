#!/bin/bash
# =============================================================================
# IPINFO - Informations IP et réseau complètes (Bash)
# =============================================================================
# Description: Affiche les informations IP (privée, publique), DNS, passerelle, etc.
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

ipinfo() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    local show_public=true
    local show_private=true
    local show_dns=true
    local show_gateway=true
    local show_all=true
    
    # Parser les arguments
    if [ $# -gt 0 ]; then
        show_all=false
        show_public=false
        show_private=false
        show_dns=false
        show_gateway=false
        
        for arg in "$@"; do
            case "$arg" in
                --public|--pub)
                    show_public=true
                    ;;
                --private|--priv)
                    show_private=true
                    ;;
                --dns)
                    show_dns=true
                    ;;
                --gateway|--gw)
                    show_gateway=true
                    ;;
                --all)
                    show_all=true
                    show_public=true
                    show_private=true
                    show_dns=true
                    show_gateway=true
                    ;;
                --help|-h)
                    echo -e "${CYAN}${BOLD}IPINFO - Informations IP et réseau${RESET}\n"
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
                    ;;
            esac
        done
    fi
    
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║              INFORMATIONS IP ET RÉSEAU                        ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${RESET}\n"
    
    # IP Privée
    if [ "$show_private" = true ] || [ "$show_all" = true ]; then
        echo -e "${YELLOW}${BOLD}📍 IP PRIVÉE (Locale):${RESET}"
        
        if command -v hostname &>/dev/null; then
            local ip_hostname=$(hostname -I 2>/dev/null | awk '{print $1}')
            if [ -n "$ip_hostname" ]; then
                echo -e "  ${GREEN}hostname -I:${RESET} $ip_hostname"
            fi
        fi
        
        if command -v ip &>/dev/null; then
            local ip_addr=$(ip -4 addr show 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
            if [ -n "$ip_addr" ]; then
                echo -e "  ${GREEN}ip addr:${RESET} $ip_addr"
            fi
        fi
        
        if command -v ifconfig &>/dev/null; then
            local ip_ifconfig=$(ifconfig 2>/dev/null | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1)
            if [ -n "$ip_ifconfig" ]; then
                echo -e "  ${GREEN}ifconfig:${RESET} $ip_ifconfig"
            fi
        fi
        echo ""
    fi
    
    # IP Publique
    if [ "$show_public" = true ] || [ "$show_all" = true ]; then
        echo -e "${YELLOW}${BOLD}🌐 IP PUBLIQUE:${RESET}"
        
        local public_ip=""
        
        if command -v curl &>/dev/null; then
            public_ip=$(curl -s --max-time 3 ifconfig.me 2>/dev/null)
            if [ -n "$public_ip" ] && [[ "$public_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                echo -e "  ${GREEN}ifconfig.me:${RESET} $public_ip"
            else
                public_ip=$(curl -s --max-time 3 icanhazip.com 2>/dev/null)
                if [ -n "$public_ip" ] && [[ "$public_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    echo -e "  ${GREEN}icanhazip.com:${RESET} $public_ip"
                else
                    public_ip=$(curl -s --max-time 3 ipinfo.io/ip 2>/dev/null)
                    if [ -n "$public_ip" ] && [[ "$public_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                        echo -e "  ${GREEN}ipinfo.io:${RESET} $public_ip"
                    fi
                fi
            fi
        fi
        
        if [ -z "$public_ip" ]; then
            echo -e "  ${RED}✗ Impossible de récupérer l'IP publique${RESET}"
            echo -e "  ${YELLOW}💡 Vérifiez votre connexion internet${RESET}"
        fi
        echo ""
    fi
    
    # DNS
    if [ "$show_dns" = true ] || [ "$show_all" = true ]; then
        echo -e "${YELLOW}${BOLD}🔍 SERVEURS DNS:${RESET}"
        
        if [ -f /etc/resolv.conf ]; then
            local dns_servers=$(grep -E "^nameserver" /etc/resolv.conf 2>/dev/null | awk '{print $2}' | grep -v "^127\.")
            if [ -n "$dns_servers" ]; then
                echo "$dns_servers" | while read dns; do
                    echo -e "  ${GREEN}/etc/resolv.conf:${RESET} $dns"
                done
            fi
        fi
        
        if command -v systemd-resolve &>/dev/null; then
            local dns_systemd=$(systemd-resolve --status 2>/dev/null | grep "DNS Servers" | awk '{print $3}')
            if [ -n "$dns_systemd" ]; then
                echo "$dns_systemd" | while read dns; do
                    echo -e "  ${GREEN}systemd-resolve:${RESET} $dns"
                done
            fi
        fi
        echo ""
    fi
    
    # Passerelle
    if [ "$show_gateway" = true ] || [ "$show_all" = true ]; then
        echo -e "${YELLOW}${BOLD}🚪 PASSERELLE PAR DÉFAUT:${RESET}"
        
        if command -v ip &>/dev/null; then
            local gateway=$(ip route show default 2>/dev/null | awk '/default/ {print $3}')
            if [ -n "$gateway" ]; then
                echo -e "  ${GREEN}ip route:${RESET} $gateway"
            fi
        fi
        echo ""
    fi
}

# Alias
alias wimip='ipinfo'
alias wsmip='ipinfo'
alias wsip='ipinfo'
alias wiam='ipinfo'

