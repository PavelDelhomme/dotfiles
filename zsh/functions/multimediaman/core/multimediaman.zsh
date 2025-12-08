#!/bin/zsh
# =============================================================================
# MULTIMEDIAMAN - Multimedia Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet pour les opérations multimédias (ripping DVD, encodage, etc.)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoires de base
MULTIMEDIAMAN_DIR="${MULTIMEDIAMAN_DIR:-$HOME/dotfiles/zsh/functions/multimediaman}"
MULTIMEDIAMAN_MODULES_DIR="$MULTIMEDIAMAN_DIR/modules"
MULTIMEDIAMAN_UTILS_DIR="$MULTIMEDIAMAN_DIR/utils"

# Charger les modules
if [ -d "$MULTIMEDIAMAN_MODULES_DIR" ]; then
    # Charger récursivement tous les scripts .sh dans les modules
    for module_file in "$MULTIMEDIAMAN_MODULES_DIR"/**/*.sh(N); do
        [ -f "$module_file" ] && source "$module_file" 2>/dev/null || true
    done
fi

# =============================================================================
# FONCTION PRINCIPALE
# =============================================================================
# DESC: Gestionnaire interactif pour les opérations multimédias
# USAGE: multimediaman [command] [args]
# EXAMPLE: multimediaman
# EXAMPLE: multimediaman rip-dvd "Mon_Film"
multimediaman() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    # Fonction pour afficher le header
    show_header() {
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║              MULTIMEDIAMAN - MULTIMEDIA MANAGER               ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        echo -e "${YELLOW}🎬 OPÉRATIONS MULTIMÉDIA${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        echo -e "${BOLD}1.${RESET} Ripping DVD (copie + encodage MP4)"
        echo -e "${BOLD}2.${RESET} Aide"
        echo -e "${BOLD}0.${RESET} Quitter"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        case "$choice" in
            1|rip|rip-dvd|dvd)
                if [ -n "$1" ]; then
                    rip_dvd "$1"
                else
                    read "?Nom du film (sans espaces, ex: Mon_Film): " title_name
                    if [ -n "$title_name" ]; then
                        rip_dvd "$title_name"
                    else
                        echo -e "${YELLOW}Opération annulée${RESET}"
                    fi
                fi
                ;;
            2|help|h|aide)
                show_help
                ;;
            0|q|quit|exit)
                return 0
                ;;
            *)
                echo -e "${RED}❌ Choix invalide: $choice${RESET}"
                sleep 2
                show_main_menu
                ;;
        esac
    }
    
    # Fonction d'aide
    show_help() {
        show_header
        echo -e "${CYAN}${BOLD}AIDE - MULTIMEDIAMAN${RESET}\n"
        echo -e "${BOLD}Commandes disponibles:${RESET}"
        echo ""
        echo -e "${GREEN}multimediaman${RESET}              - Menu interactif"
        echo -e "${GREEN}multimediaman rip-dvd [nom]${RESET} - Ripping DVD avec encodage MP4"
        echo ""
        echo -e "${BOLD}Exemples:${RESET}"
        echo "  multimediaman"
        echo "  multimediaman rip-dvd Mon_Film"
        echo ""
        echo -e "${BOLD}Pré-requis:${RESET}"
        echo "  - HandBrakeCLI installé (via installman handbrake)"
        echo "  - dvdbackup installé"
        echo "  - libdvdcss installé (pour DVD chiffrés)"
        echo ""
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Si un argument est fourni, lancer directement la commande
    if [ -n "$1" ]; then
        local cmd=$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        
        case "$cmd" in
            rip-dvd|rip|dvd)
                if [ -n "$2" ]; then
                    rip_dvd "$2"
                else
                    read "?Nom du film (sans espaces, ex: Mon_Film): " title_name
                    if [ -n "$title_name" ]; then
                        rip_dvd "$title_name"
                    else
                        echo -e "${YELLOW}Opération annulée${RESET}"
                        return 1
                    fi
                fi
                ;;
            help|h|aide|--help|-h)
                show_help
                ;;
            *)
                echo -e "${RED}❌ Commande inconnue: $1${RESET}"
                echo ""
                echo -e "${YELLOW}Commandes disponibles:${RESET}"
                echo "  rip-dvd [nom]  - Ripping DVD avec encodage MP4"
                echo "  help           - Afficher l'aide"
                echo ""
                return 1
                ;;
        esac
    else
        # Mode interactif
        show_main_menu
    fi
}

# Alias
alias mm='multimediaman'
alias mm-rip='multimediaman rip-dvd'

