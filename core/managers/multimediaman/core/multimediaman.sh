#!/bin/sh
# =============================================================================
# MULTIMEDIAMAN - Multimedia Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet pour les opérations multimédias (ripping DVD, encodage, etc.)
# Author: Paul Delhomme
# Version: 2.0 - Migration POSIX Complète
# =============================================================================

# Détecter le shell pour adapter certaines syntaxes
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_TYPE="fish"
else
    SHELL_TYPE="sh"
fi

# DESC: Gestionnaire interactif pour les opérations multimédias
# USAGE: multimediaman [command] [args]
# EXAMPLE: multimediaman
# EXAMPLE: multimediaman rip-dvd "Mon_Film"
multimediaman() {
    # Configuration des couleurs
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    MULTIMEDIAMAN_DIR="$DOTFILES_DIR/zsh/functions/multimediaman"
    MULTIMEDIAMAN_MODULES_DIR="$MULTIMEDIAMAN_DIR/modules"
    
    # Charger les modules si disponibles
    if [ -d "$MULTIMEDIAMAN_MODULES_DIR" ]; then
        for module_file in "$MULTIMEDIAMAN_MODULES_DIR"/*/*.sh; do
            if [ -f "$module_file" ]; then
                . "$module_file" 2>/dev/null || true
            fi
        done
    fi
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║              MULTIMEDIAMAN - MULTIMEDIA MANAGER               ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        printf "${YELLOW}🎬 OPÉRATIONS MULTIMÉDIA${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        printf "${BOLD}1.${RESET} Ripping DVD (copie + encodage MP4)\n"
        printf "${BOLD}2.${RESET} Extraire une archive (avec progression)\n"
        printf "${BOLD}3.${RESET} Lister le contenu d'une archive\n"
        printf "${BOLD}4.${RESET} Aide\n"
        printf "${BOLD}0.${RESET} Quitter\n"
        echo ""
        printf "Choix: "
        read choice
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        case "$choice" in
            1|rip|rip-dvd|dvd)
                printf "Nom du film (sans espaces, ex: Mon_Film): "
                read title_name
                if [ -n "$title_name" ]; then
                    if command -v rip_dvd >/dev/null 2>&1; then
                        rip_dvd "$title_name"
                    else
                        printf "${YELLOW}⚠️  Fonction rip_dvd non disponible${RESET}\n"
                        printf "${CYAN}💡 Chargez le module DVD depuis %s${RESET}\n" "$MULTIMEDIAMAN_MODULES_DIR/dvd"
                    fi
                else
                    printf "${YELLOW}Opération annulée${RESET}\n"
                fi
                ;;
            2|extract|ext)
                printf "Chemin de l'archive: "
                read archive_path
                if [ -n "$archive_path" ]; then
                    printf "Destination (défaut: .): "
                    read dest_path
                    dest_path="${dest_path:-.}"
                    if command -v extract_with_progress >/dev/null 2>&1; then
                        extract_with_progress "$archive_path" "$dest_path"
                    else
                        printf "${YELLOW}⚠️  Fonction extract_with_progress non disponible${RESET}\n"
                        printf "${CYAN}💡 Chargez le module extract depuis %s${RESET}\n" "$MULTIMEDIAMAN_MODULES_DIR/extract"
                    fi
                else
                    printf "${YELLOW}Opération annulée${RESET}\n"
                fi
                printf "Appuyez sur Entrée pour continuer... "
                read dummy
                show_main_menu
                ;;
            3|list|ls)
                printf "Chemin de l'archive: "
                read archive_path
                if [ -n "$archive_path" ]; then
                    if command -v list_archive >/dev/null 2>&1; then
                        list_archive "$archive_path"
                    else
                        printf "${YELLOW}⚠️  Fonction list_archive non disponible${RESET}\n"
                        printf "${CYAN}💡 Chargez le module extract depuis %s${RESET}\n" "$MULTIMEDIAMAN_MODULES_DIR/extract"
                    fi
                else
                    printf "${YELLOW}Opération annulée${RESET}\n"
                fi
                printf "Appuyez sur Entrée pour continuer... "
                read dummy
                show_main_menu
                ;;
            4|help|h|aide)
                show_help
                ;;
            0|q|quit|exit)
                return 0
                ;;
            *)
                printf "${RED}❌ Choix invalide: %s${RESET}\n" "$choice"
                sleep 2
                show_main_menu
                ;;
        esac
    }
    
    # Fonction d'aide
    show_help() {
        show_header
        printf "${CYAN}${BOLD}AIDE - MULTIMEDIAMAN${RESET}\n\n"
        printf "${BOLD}Commandes disponibles:${RESET}\n"
        echo ""
        printf "${GREEN}multimediaman${RESET}                    - Menu interactif\n"
        printf "${GREEN}multimediaman rip-dvd [nom]${RESET}       - Ripping DVD avec encodage MP4\n"
        printf "${GREEN}multimediaman extract [archive] [dest]${RESET} - Extraire archive avec progression\n"
        printf "${GREEN}multimediaman list [archive]${RESET}      - Lister contenu d'une archive\n"
        echo ""
        printf "${BOLD}Exemples:${RESET}\n"
        echo "  multimediaman"
        echo "  multimediaman rip-dvd Mon_Film"
        echo "  multimediaman extract archive.zip"
        echo "  multimediaman extract archive.tar.gz /tmp/extract"
        echo "  multimediaman list archive.zip"
        echo ""
        printf "${BOLD}Pré-requis:${RESET}\n"
        echo "  - HandBrakeCLI installé (via installman handbrake)"
        echo "  - dvdbackup installé"
        echo "  - libdvdcss installé (pour DVD chiffrés)"
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Si un argument est fourni, lancer directement la commande
    if [ -n "$1" ]; then
        cmd=$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        
        case "$cmd" in
            rip-dvd|rip|dvd)
                if [ -n "$2" ]; then
                    if command -v rip_dvd >/dev/null 2>&1; then
                        rip_dvd "$2"
                    else
                        printf "${YELLOW}⚠️  Fonction rip_dvd non disponible${RESET}\n"
                        return 1
                    fi
                else
                    printf "Nom du film (sans espaces, ex: Mon_Film): "
                    read title_name
                    if [ -n "$title_name" ]; then
                        if command -v rip_dvd >/dev/null 2>&1; then
                            rip_dvd "$title_name"
                        else
                            printf "${YELLOW}⚠️  Fonction rip_dvd non disponible${RESET}\n"
                            return 1
                        fi
                    else
                        printf "${YELLOW}Opération annulée${RESET}\n"
                        return 1
                    fi
                fi
                ;;
            extract|ext)
                if [ -n "$2" ]; then
                    if command -v extract_with_progress >/dev/null 2>&1; then
                        extract_with_progress "$2" "${3:-.}"
                    else
                        printf "${YELLOW}⚠️  Fonction extract_with_progress non disponible${RESET}\n"
                        return 1
                    fi
                else
                    printf "Chemin de l'archive: "
                    read archive_path
                    if [ -n "$archive_path" ]; then
                        printf "Destination (défaut: .): "
                        read dest_path
                        dest_path="${dest_path:-.}"
                        if command -v extract_with_progress >/dev/null 2>&1; then
                            extract_with_progress "$archive_path" "$dest_path"
                        else
                            printf "${YELLOW}⚠️  Fonction extract_with_progress non disponible${RESET}\n"
                            return 1
                        fi
                    else
                        printf "${YELLOW}Opération annulée${RESET}\n"
                        return 1
                    fi
                fi
                ;;
            list|ls)
                if [ -n "$2" ]; then
                    if command -v list_archive >/dev/null 2>&1; then
                        list_archive "$2"
                    else
                        printf "${YELLOW}⚠️  Fonction list_archive non disponible${RESET}\n"
                        return 1
                    fi
                else
                    printf "Chemin de l'archive: "
                    read archive_path
                    if [ -n "$archive_path" ]; then
                        if command -v list_archive >/dev/null 2>&1; then
                            list_archive "$archive_path"
                        else
                            printf "${YELLOW}⚠️  Fonction list_archive non disponible${RESET}\n"
                            return 1
                        fi
                    else
                        printf "${YELLOW}Opération annulée${RESET}\n"
                        return 1
                    fi
                fi
                ;;
            help|h|aide|--help|-h)
                show_help
                ;;
            *)
                printf "${RED}❌ Commande inconnue: %s${RESET}\n" "$1"
                echo ""
                printf "${YELLOW}Commandes disponibles:${RESET}\n"
                echo "  rip-dvd [nom]     - Ripping DVD avec encodage MP4"
                echo "  extract [arch]    - Extraire archive avec progression"
                echo "  list [arch]       - Lister contenu d'une archive"
                echo "  help             - Afficher l'aide"
                echo ""
                return 1
                ;;
        esac
    else
        # Mode interactif
        show_main_menu
    fi
}
