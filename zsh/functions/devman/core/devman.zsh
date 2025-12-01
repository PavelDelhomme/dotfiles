#!/bin/zsh
# =============================================================================
# DEVMAN - Development Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet des outils de développement
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoires de base
DEVMAN_DIR="${DEVMAN_DIR:-$HOME/dotfiles/zsh/functions/devman}"
DEV_DIR="${DEV_DIR:-$HOME/dotfiles/zsh/functions/devman/modules/legacy}"

# Charger les utilitaires
UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
    source "$UTILS_DIR/ensure_tool.sh"
fi

# DESC: Gestionnaire interactif complet pour les outils de développement
# USAGE: devman [category]
# EXAMPLE: devman
# EXAMPLE: devman docker
# EXAMPLE: devman go
devman() {
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
        echo "║                    DEVMAN - DEVELOPMENT MANAGER                ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        echo -e "${YELLOW}🛠️  OUTILS DE DÉVELOPPEMENT${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
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
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                if [ -f "$DEV_DIR/docker.sh" ]; then
                    source "$DEV_DIR/docker.sh"
                else
                    echo "❌ Module Docker non disponible"
                    sleep 2
                fi
                ;;
            2)
                if [ -f "$DEV_DIR/go.sh" ]; then
                    source "$DEV_DIR/go.sh"
                else
                    echo "❌ Module Go non disponible"
                    sleep 2
                fi
                ;;
            3)
                if [ -f "$DEV_DIR/make.sh" ]; then
                    source "$DEV_DIR/make.sh"
                else
                    echo "❌ Module Make non disponible"
                    sleep 2
                fi
                ;;
            4)
                if [ -f "$DEV_DIR/c.sh" ]; then
                    source "$DEV_DIR/c.sh"
                else
                    echo "❌ Module C/C++ non disponible"
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
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # Menu projets
    show_projects_menu() {
        show_header
        echo -e "${YELLOW}📁 PROJETS${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        if [ -d "$DEV_DIR/projects" ]; then
            local count=1
            for project_file in "$DEV_DIR/projects"/*.sh; do
                if [ -f "$project_file" ]; then
                    local project_name=$(basename "$project_file" .sh)
                    echo "$count.  $project_name"
                    ((count++))
                fi
            done
        fi
        
        echo ""
        echo "0.  Retour"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        if [ "$choice" = "0" ]; then
            return
        fi
        
        # Charger le projet sélectionné
        local projects=($(ls "$DEV_DIR/projects"/*.sh 2>/dev/null))
        if [ -n "${projects[$choice]}" ]; then
            source "${projects[$choice]}"
        fi
    }
    
    # Menu utilitaires dev
    show_dev_utils_menu() {
        show_header
        echo -e "${YELLOW}🔧 UTILITAIRES DEV${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        echo "1.  📦 Gestionnaire de dépendances"
        echo "2.  🔨 Build tools"
        echo "3.  🧪 Testing tools"
        echo "4.  📊 Code analysis"
        echo ""
        echo "0.  Retour"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1) echo "⚠️  À implémenter" ; sleep 2 ;;
            2) echo "⚠️  À implémenter" ; sleep 2 ;;
            3) echo "⚠️  À implémenter" ; sleep 2 ;;
            4) echo "⚠️  À implémenter" ; sleep 2 ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # Gestion des arguments en ligne de commande
    if [[ "$1" == "docker" ]]; then
        if [ -f "$DEV_DIR/docker.sh" ]; then
            source "$DEV_DIR/docker.sh"
        fi
        return
    fi
    if [[ "$1" == "go" ]]; then
        if [ -f "$DEV_DIR/go.sh" ]; then
            source "$DEV_DIR/go.sh"
        fi
        return
    fi
    if [[ "$1" == "make" ]]; then
        if [ -f "$DEV_DIR/make.sh" ]; then
            source "$DEV_DIR/make.sh"
        fi
        return
    fi
    if [[ "$1" == "c" ]] || [[ "$1" == "cpp" ]]; then
        if [ -f "$DEV_DIR/c.sh" ]; then
            source "$DEV_DIR/c.sh"
        fi
        return
    fi
    
    # Menu interactif principal
    while true; do
        show_main_menu
    done
}

# Message d'initialisation
echo "💻 DEVMAN chargé - Tapez 'devman' ou 'dm' pour démarrer"

