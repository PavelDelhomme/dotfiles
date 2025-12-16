#!/bin/sh
# =============================================================================
# DEVMAN - Development Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des outils de développement
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

# DESC: Gestionnaire interactif complet pour les outils de développement
# USAGE: devman [category]
# EXAMPLE: devman
# EXAMPLE: devman docker
# EXAMPLE: devman go
devman() {
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
    DEVMAN_DIR="$DOTFILES_DIR/zsh/functions/devman"
    DEV_DIR="$DEVMAN_DIR/modules/legacy"
    UTILS_DIR="$DOTFILES_DIR/zsh/functions/utils"
    
    # Charger les utilitaires si disponibles
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        . "$UTILS_DIR/ensure_tool.sh" 2>/dev/null || true
    fi
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                    DEVMAN - DEVELOPMENT MANAGER                ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        printf "${YELLOW}🛠️  OUTILS DE DÉVELOPPEMENT${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        echo "1.  🐳 Docker (gestion conteneurs)"
        echo "2.  🐹 Go (langage Go)"
        echo "3.  🔨 Make (gestion builds)"
        echo "4.  📦 C/C++ (compilation)"
        echo "5.  📁 Projets (gestion projets)"
        echo "6.  🔧 Utilitaires dev"
        echo ""
        echo "0.  Quitter"
        echo ""
        printf "Choix: "
        read choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                if [ -f "$DEV_DIR/docker.sh" ]; then
                    . "$DEV_DIR/docker.sh"
                else
                    printf "${RED}❌ Module Docker non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            2)
                if [ -f "$DEV_DIR/go.sh" ]; then
                    . "$DEV_DIR/go.sh"
                else
                    printf "${RED}❌ Module Go non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            3)
                if [ -f "$DEV_DIR/make.sh" ]; then
                    . "$DEV_DIR/make.sh"
                else
                    printf "${RED}❌ Module Make non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            4)
                if [ -f "$DEV_DIR/c.sh" ]; then
                    . "$DEV_DIR/c.sh"
                else
                    printf "${RED}❌ Module C/C++ non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            5)
                show_projects_menu
                ;;
            6)
                show_dev_utils_menu
                ;;
            0) return ;;
            *)
                printf "${RED}Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
    }
    
    # Menu projets
    show_projects_menu() {
        show_header
        printf "${YELLOW}📁 PROJETS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        if [ -d "$DEV_DIR/projects" ]; then
            count=1
            for project_file in "$DEV_DIR/projects"/*.sh; do
                if [ -f "$project_file" ]; then
                    project_name=$(basename "$project_file" .sh)
                    printf "%d.  %s\n" "$count" "$project_name"
                    count=$((count + 1))
                fi
            done
        fi
        
        echo ""
        echo "0.  Retour"
        echo ""
        printf "Choix: "
        read choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        if [ "$choice" = "0" ]; then
            return
        fi
        
        # Charger le projet sélectionné
        project_index=1
        for project_file in "$DEV_DIR/projects"/*.sh; do
            if [ -f "$project_file" ]; then
                if [ "$project_index" -eq "$choice" ]; then
                    . "$project_file"
                    break
                fi
                project_index=$((project_index + 1))
            fi
        done
    }
    
    # Menu utilitaires dev
    show_dev_utils_menu() {
        show_header
        printf "${YELLOW}🔧 UTILITAIRES DEV${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        echo "1.  📦 Gestionnaire de dépendances"
        echo "2.  🔨 Build tools"
        echo "3.  🧪 Testing tools"
        echo "4.  📊 Code analysis"
        echo ""
        echo "0.  Retour"
        echo ""
        printf "Choix: "
        read choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1|2|3|4)
                printf "${YELLOW}⚠️  À implémenter${RESET}\n"
                sleep 2
                ;;
            0) return ;;
            *)
                printf "${RED}Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
    }
    
    # Gestion des arguments en ligne de commande
    if [ -n "$1" ]; then
        case "$1" in
            docker)
                if [ -f "$DEV_DIR/docker.sh" ]; then
                    . "$DEV_DIR/docker.sh"
                fi
                ;;
            go)
                if [ -f "$DEV_DIR/go.sh" ]; then
                    . "$DEV_DIR/go.sh"
                fi
                ;;
            make)
                if [ -f "$DEV_DIR/make.sh" ]; then
                    . "$DEV_DIR/make.sh"
                fi
                ;;
            c|cpp)
                if [ -f "$DEV_DIR/c.sh" ]; then
                    . "$DEV_DIR/c.sh"
                fi
                ;;
            projects)
                show_projects_menu
                ;;
            utils)
                show_dev_utils_menu
                ;;
            help|--help|-h)
                echo "🔧 DEVMAN - Development Manager"
                echo ""
                echo "Usage: devman [category]"
                echo ""
                echo "Catégories:"
                echo "  docker    - Gestion conteneurs Docker"
                echo "  go        - Langage Go"
                echo "  make      - Gestion builds Make"
                echo "  c|cpp     - Compilation C/C++"
                echo "  projects  - Gestion projets"
                echo "  utils     - Utilitaires dev"
                echo ""
                echo "Sans argument: menu interactif"
                ;;
            *)
                printf "${RED}Catégorie inconnue: %s${RESET}\n" "$1"
                echo "Utilisez 'devman help' pour voir les catégories disponibles"
                return 1
                ;;
        esac
    else
        # Menu interactif principal
        while true; do
            show_main_menu
        done
    fi
}
