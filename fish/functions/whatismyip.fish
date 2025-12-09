# =============================================================================
# WHATISMYIP - Affiche l'IP publique (Fish)
# =============================================================================
# Description: Commande simple pour connaître l'IP publique du réseau
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

function whatismyip --description "Affiche l'IP publique du réseau"
    set -l RED '\033[0;31m'
    set -l GREEN '\033[0;32m'
    set -l YELLOW '\033[1;33m'
    set -l BLUE '\033[0;34m'
    set -l CYAN '\033[0;36m'
    set -l BOLD '\033[1m'
    set -l RESET '\033[0m'
    
    set -l verbose false
    
    # Parser les arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --verbose -v
                set verbose true
                set i (math $i + 1)
            case --help -h
                echo -e "$CYAN$BOLD""WHATISMYIP - Affiche l'IP publique""$RESET\n"
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
            case '*'
                echo -e "$RED""❌ Option inconnue: $argv[$i]""$RESET"
                return 1
        end
        set i (math $i + 1)
    end
    
    # Vérifier curl
    if not command -v curl >/dev/null 2>&1
        echo -e "$RED""❌ Erreur: 'curl' n'est pas installé""$RESET"
        echo -e "$YELLOW""💡 Installez-le avec:""$RESET"
        echo -e "   ""$CYAN""sudo pacman -S curl""$RESET"" (Arch/Manjaro)"
        echo -e "   ""$CYAN""sudo apt install curl""$RESET"" (Debian/Ubuntu)"
        echo -e "   ""$CYAN""sudo dnf install curl""$RESET"" (Fedora)"
        return 1
    end
    
    if test "$verbose" = "true"
        echo -e "$CYAN$BOLD""🌐 Récupération de l'IP publique...""$RESET\n"
    end
    
    set -l public_ip ""
    set -l service_used ""
    
    # Services à essayer
    set -l services ifconfig.me icanhazip.com ipinfo.io/ip api.ipify.org checkip.amazonaws.com ipecho.net/plain ident.me
    
    # Essayer chaque service
    for service in $services
        if test "$verbose" = "true"
            echo -e "$BLUE""Essai avec: ""$CYAN$service$RESET""..."
        end
        
        set public_ip (curl -s --max-time 3 "$service" 2>/dev/null | tr -d '\n\r ' | grep -oE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$')
        
        if test -n "$public_ip"; and echo "$public_ip" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'
            set service_used "$service"
            break
        end
    end
    
    # Afficher le résultat
    if test -n "$public_ip"
        if test "$verbose" = "true"
            echo ""
            echo -e "$GREEN$BOLD""✅ IP PUBLIQUE TROUVÉE:""$RESET"
            echo -e "$CYAN$BOLD$public_ip$RESET"
            echo ""
            echo -e "$BLUE""Service utilisé:""$RESET"" $CYAN$service_used$RESET"
        else
            echo "$public_ip"
        end
        return 0
    else
        echo -e "$RED""❌ Impossible de récupérer l'IP publique""$RESET"
        echo -e "$YELLOW""💡 Vérifiez votre connexion internet""$RESET"
        return 1
    end
end

# Alias
function myip; whatismyip $argv; end
function mypublicip; whatismyip $argv; end

