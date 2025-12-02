#!/bin/zsh
# =============================================================================
# FILEMAN - File Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet des opérations sur fichiers et répertoires
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoires de base
FILEMAN_DIR="${FILEMAN_DIR:-$HOME/dotfiles/zsh/functions/fileman}"
FILEMAN_MODULES_DIR="$FILEMAN_DIR/modules"

# Charger les utilitaires
if [ -d "$FILEMAN_DIR/utils" ]; then
    shopt -s nullglob 2>/dev/null || setopt null_glob 2>/dev/null || true
    for util_file in "$FILEMAN_DIR/utils"/*.sh; do
        if [ -f "$util_file" ]; then
            source "$util_file" 2>/dev/null || true
        fi
    done
    shopt -u nullglob 2>/dev/null || unsetopt null_glob 2>/dev/null || true
fi

# DESC: Gestionnaire interactif complet pour les opérations sur fichiers
# USAGE: fileman [category]
# EXAMPLE: fileman
# EXAMPLE: fileman archive
# EXAMPLE: fileman backup
fileman() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local MAGENTA='\033[0;35m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    # Fonction pour afficher le header
    show_header() {
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                  FILEMAN - FILE MANAGER                        ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        echo -e "${YELLOW}📁 GESTION DES FICHIERS${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        echo "1.  📦 Archive (créer/extraire archives)"
        echo "2.  💾 Backup (créer/sauvegarder)"
        echo "3.  🔍 Recherche (trouver fichiers)"
        echo "4.  🔐 Permissions (gérer permissions)"
        echo "5.  📋 Opérations fichiers (copier/déplacer/supprimer)"
        echo ""
        echo "0.  Quitter"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                if [ -f "$FILEMAN_MODULES_DIR/archive/archive_manager.sh" ]; then
                    bash "$FILEMAN_MODULES_DIR/archive/archive_manager.sh"
                else
                    echo -e "${RED}❌ Module Archive non disponible${RESET}"
                    sleep 2
                fi
                ;;
            2)
                if [ -f "$FILEMAN_MODULES_DIR/backup/backup_manager.sh" ]; then
                    bash "$FILEMAN_MODULES_DIR/backup/backup_manager.sh"
                else
                    echo -e "${RED}❌ Module Backup non disponible${RESET}"
                    sleep 2
                fi
                ;;
            3)
                if [ -f "$FILEMAN_MODULES_DIR/search/search_manager.sh" ]; then
                    bash "$FILEMAN_MODULES_DIR/search/search_manager.sh"
                else
                    echo -e "${RED}❌ Module Recherche non disponible${RESET}"
                    sleep 2
                fi
                ;;
            4)
                if [ -f "$FILEMAN_MODULES_DIR/permissions/permissions_manager.sh" ]; then
                    bash "$FILEMAN_MODULES_DIR/permissions/permissions_manager.sh"
                else
                    echo -e "${RED}❌ Module Permissions non disponible${RESET}"
                    sleep 2
                fi
                ;;
            5)
                if [ -f "$FILEMAN_MODULES_DIR/files/files_manager.sh" ]; then
                    bash "$FILEMAN_MODULES_DIR/files/files_manager.sh"
                else
                    echo -e "${RED}❌ Module Fichiers non disponible${RESET}"
                    sleep 2
                fi
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${RED}Choix invalide${RESET}"
                sleep 1
                ;;
        esac
        
        # Retourner au menu après action
        echo ""
        read -k 1 "?Appuyez sur une touche pour continuer... "
        fileman
    }
    
    # Si un argument est fourni, lancer directement le module
    if [ -n "$1" ]; then
        case "$1" in
            archive|arch)
                if [ -f "$FILEMAN_MODULES_DIR/archive/archive_manager.sh" ]; then
                    bash "$FILEMAN_MODULES_DIR/archive/archive_manager.sh"
                fi
                ;;
            backup|back)
                if [ -f "$FILEMAN_MODULES_DIR/backup/backup_manager.sh" ]; then
                    bash "$FILEMAN_MODULES_DIR/backup/backup_manager.sh"
                fi
                ;;
            search|find|recherche)
                if [ -f "$FILEMAN_MODULES_DIR/search/search_manager.sh" ]; then
                    bash "$FILEMAN_MODULES_DIR/search/search_manager.sh"
                fi
                ;;
            permissions|perms|chmod)
                if [ -f "$FILEMAN_MODULES_DIR/permissions/permissions_manager.sh" ]; then
                    bash "$FILEMAN_MODULES_DIR/permissions/permissions_manager.sh"
                fi
                ;;
            files|file|ops)
                if [ -f "$FILEMAN_MODULES_DIR/files/files_manager.sh" ]; then
                    bash "$FILEMAN_MODULES_DIR/files/files_manager.sh"
                fi
                ;;
            *)
                echo -e "${RED}Module inconnu: $1${RESET}"
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

# Alias
alias fm='fileman'

