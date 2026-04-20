#!/bin/sh
# =============================================================================
# FILEMAN - File Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des opérations sur fichiers et répertoires
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

# DESC: Gestionnaire interactif complet pour les opérations sur fichiers
# USAGE: fileman [category]
# EXAMPLE: fileman
# EXAMPLE: fileman archive
# EXAMPLE: fileman backup
fileman() {
    # Configuration des couleurs
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    FILEMAN_DIR="$DOTFILES_DIR/zsh/functions/fileman"
    FILEMAN_MODULES_DIR="$FILEMAN_DIR/modules"
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                  FILEMAN - FILE MANAGER                        ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        printf "${YELLOW}📁 GESTION DES FICHIERS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        echo "1.  📦 Archive (créer/extraire archives)"
        echo "2.  💾 Backup (créer/sauvegarder)"
        echo "3.  🔍 Recherche (trouver fichiers)"
        echo "4.  🔐 Permissions (gérer permissions)"
        echo "5.  📋 Opérations fichiers (copier/déplacer/supprimer)"
        echo ""
        echo "0.  Quitter"
        echo ""
        printf "Choix: "
        read choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                if [ -f "$FILEMAN_MODULES_DIR/archive/archive_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/archive/archive_manager.sh"
                else
                    printf "${RED}❌ Module Archive non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            2)
                if [ -f "$FILEMAN_MODULES_DIR/backup/backup_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/backup/backup_manager.sh"
                else
                    printf "${RED}❌ Module Backup non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            3)
                if [ -f "$FILEMAN_MODULES_DIR/search/search_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/search/search_manager.sh"
                else
                    printf "${RED}❌ Module Recherche non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            4)
                if [ -f "$FILEMAN_MODULES_DIR/permissions/permissions_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/permissions/permissions_manager.sh"
                else
                    printf "${RED}❌ Module Permissions non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            5)
                if [ -f "$FILEMAN_MODULES_DIR/files/files_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/files/files_manager.sh"
                else
                    printf "${RED}❌ Module Fichiers non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            0)
                return 0
                ;;
            *)
                printf "${RED}Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
        
        # Retourner au menu après action
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
        fileman
    }
    
    # Si un argument est fourni, lancer directement le module
    if [ -n "$1" ]; then
        _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
        [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ] && . "$_logdf/scripts/lib/managers_log_posix.sh" && managers_cli_log fileman "$@"
        case "$1" in
            archive|arch)
                if [ -f "$FILEMAN_MODULES_DIR/archive/archive_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/archive/archive_manager.sh"
                fi
                ;;
            backup|back)
                if [ -f "$FILEMAN_MODULES_DIR/backup/backup_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/backup/backup_manager.sh"
                fi
                ;;
            search|find|recherche)
                if [ -f "$FILEMAN_MODULES_DIR/search/search_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/search/search_manager.sh"
                fi
                ;;
            permissions|perms|chmod)
                if [ -f "$FILEMAN_MODULES_DIR/permissions/permissions_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/permissions/permissions_manager.sh"
                fi
                ;;
            files|file|ops)
                if [ -f "$FILEMAN_MODULES_DIR/files/files_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/files/files_manager.sh"
                fi
                ;;
            *)
                printf "${RED}Module inconnu: $1${RESET}\n"
                echo ""
                echo "Modules disponibles:"
                echo "  - archive"
                echo "  - backup"
                echo "  - search"
                echo "  - permissions"
                echo "  - files"
                return 1
                ;;
        esac
    else
        # Mode interactif
        while true; do
            show_main_menu
        done
    fi
}
