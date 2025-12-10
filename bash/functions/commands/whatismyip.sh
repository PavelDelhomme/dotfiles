#!/bin/bash
# =============================================================================
# WHATISMYIP - Affiche l'IP publique (Bash)
# =============================================================================
# Description: Commande simple pour connaître l'IP publique du réseau
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

whatismyip() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    local verbose=false
    
    # Parser les arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --verbose|-v)
                verbose=true
                shift
                ;;
            --help|-h)
                echo -e "${CYAN}${BOLD}WHATISMYIP - Affiche l'IP publique${RESET}\n"
                echo "Usage: whatismyip [options]"
                echo ""
                echo "Options:"
                echo "  --verbose, -v    Afficher les détails (services utilisés)"
                echo "  --help, -h       Afficher cette aide"
                echo ""
                echo "Exemples:"
                echo "  whatismyip              # Affiche l'IP publique"
                echo "  whatismyip --verbose     # Affiche l'IP avec détails"
                return 0
                ;;
            *)
                echo -e "${RED}❌ Option inconnue: $1${RESET}"
                return 1
                ;;
        esac
    done
    
    # Vérifier si curl est disponible
    if ! command -v curl &>/dev/null; then
        echo -e "${RED}❌ Erreur: 'curl' n'est pas installé${RESET}"
        echo -e "${YELLOW}💡 Installez-le avec:${RESET}"
        echo -e "   ${CYAN}sudo pacman -S curl${RESET} (Arch/Manjaro)"
        echo -e "   ${CYAN}sudo apt install curl${RESET} (Debian/Ubuntu)"
        echo -e "   ${CYAN}sudo dnf install curl${RESET} (Fedora)"
        return 1
    fi
    
    if [ "$verbose" = true ]; then
        echo -e "${CYAN}${BOLD}🌐 Récupération de l'IP publique...${RESET}\n"
    fi
    
    local public_ip=""
    local service_used=""
    
    # Liste des services à essayer (par ordre de préférence)
    local services=(
        "ifconfig.me"
        "icanhazip.com"
        "ipinfo.io/ip"
        "api.ipify.org"
        "checkip.amazonaws.com"
        "ipecho.net/plain"
        "ident.me"
    )
    
    # Essayer chaque service
    for service in "${services[@]}"; do
        if [ "$verbose" = true ]; then
            echo -e "${BLUE}Essai avec: ${CYAN}$service${RESET}..."
        fi
        
        # Récupérer l'IP (timeout de 3 secondes)
        public_ip=$(curl -s --max-time 3 "$service" 2>/dev/null | tr -d '\n\r ' | grep -oE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$')
        
        # Vérifier que c'est une IP valide
        if [ -n "$public_ip" ] && [[ "$public_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            service_used="$service"
            break
        fi
    done
    
    # Afficher le résultat
    if [ -n "$public_ip" ]; then
        if [ "$verbose" = true ]; then
            echo ""
            echo -e "${GREEN}${BOLD}✅ IP PUBLIQUE TROUVÉE:${RESET}"
            echo -e "${CYAN}${BOLD}$public_ip${RESET}"
            echo ""
            echo -e "${BLUE}Service utilisé:${RESET} ${CYAN}$service_used${RESET}"
        else
            # Mode simple: juste l'IP
            echo "$public_ip"
        fi
        return 0
    else
        echo -e "${RED}❌ Impossible de récupérer l'IP publique${RESET}"
        echo -e "${YELLOW}💡 Vérifiez votre connexion internet${RESET}"
        return 1
    fi
}

# Alias
alias myip='whatismyip'
alias mypublicip='whatismyip'

