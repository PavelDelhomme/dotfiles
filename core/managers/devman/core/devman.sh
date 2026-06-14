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
    if [ -f "$DOTFILES_DIR/scripts/lib/manager_ui.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/manager_ui.sh"
        dotfiles_manager_load_ui_libs
    elif [ -f "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh"
    fi
    
    # Charger les utilitaires si disponibles
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        . "$UTILS_DIR/ensure_tool.sh" 2>/dev/null || true
    fi
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}"
        if command -v manager_ui_print_banner >/dev/null 2>&1; then
            manager_ui_print_banner "DEVMAN - DEVELOPMENT MANAGER"
        else
            echo "╔════════════════════════════════════════════════════════════════╗"
            echo "║                    DEVMAN - DEVELOPMENT MANAGER                ║"
            echo "╚════════════════════════════════════════════════════════════════╝"
        fi
        printf "${RESET}"
    }

    pause_if_tty() {
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée pour continuer... "
            read _dev_pause || true
        fi
    }

    devman_print_quick_help() {
        echo "🔧 DEVMAN - Development Manager"
        echo ""
        echo "Interface :"
        echo "  devman                       cette aide (stdout)"
        echo "  devman help | -h             idem"
        echo "  devman help --interactive    cette aide + pause (TTY)"
        echo "  devman --help                cette aide + pause + menu interactif"
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
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        printf "${YELLOW}🛠️  OUTILS DE DÉVELOPPEMENT${RESET}\n"
        manager_ui_section_line "${BLUE}" "${RESET}\n\n"
        
        echo "1.  🐳 Docker (gestion conteneurs)"
        echo "2.  🐹 Go (langage Go)"
        echo "3.  🔨 Make (gestion builds)"
        echo "4.  📦 C/C++ (compilation)"
        echo "5.  📁 Projets (gestion projets)"
        echo "6.  🔧 Utilitaires dev"
        echo ""
        echo "0.  Quitter  (q)"
        echo ""
        choice=""
        if [ -t 0 ] && [ -t 1 ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
            menu_input_file=$(mktemp)
            cat > "$menu_input_file" <<'EOF'
Docker (gestion conteneurs)|1
Go (langage Go)|2
Make (gestion builds)|3
C/C++ (compilation)|4
Projets (gestion projets)|5
Utilitaires dev|6
Quitter|0
Quitter|q
EOF
            choice=$(dotfiles_ncmenu_select "DEVMAN - Menu principal" < "$menu_input_file" 2>/dev/null || true)
            rm -f "$menu_input_file"
        fi
        if [ -z "$choice" ]; then
            printf "Choix (0 ou q pour quitter): "
            read choice
            choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        fi
        if command -v manager_ui_is_quit_choice >/dev/null 2>&1 && manager_ui_is_quit_choice "$choice"; then
            printf "${GREEN}Au revoir!${RESET}\n"
            return 1
        fi
        
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
            0|q|Q|quit|exit)
                printf "${GREEN}Au revoir!${RESET}\n"
                return 1
                ;;
            *)
                printf "${RED}Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
        return 0
    }
    
    # Menu projets
    show_projects_menu() {
        show_header
        printf "${YELLOW}📁 PROJETS${RESET}\n"
        manager_ui_section_line "${BLUE}" "${RESET}\n\n"
        
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
        manager_ui_section_line "${BLUE}" "${RESET}\n\n"
        
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
    
    if [ -z "$1" ]; then
        devman_print_quick_help
        return 0
    fi
    if [ "$1" = "help" ] || [ "$1" = "-h" ]; then
        case "${2:-}" in
        --interactive|-i)
            if [ -t 0 ] && [ -t 1 ]; then
                devman_print_quick_help
                pause_if_tty
            else
                printf '%s\n' "devman: help --interactive nécessite un TTY." >&2
                devman_print_quick_help
            fi
            return 0
            ;;
        *)
            devman_print_quick_help
            return 0
            ;;
        esac
    fi
    if [ "$1" = "--help" ]; then
        devman_print_quick_help
        return 0
    fi
    if [ "$1" = menu ] || [ "$1" = "--interactive" ]; then
        if ! { [ -t 0 ] && [ -t 1 ]; }; then
            printf '%s\n' "devman: menu nécessite un terminal (TTY)." >&2
            return 2
        fi
        while true; do
            show_main_menu || break
        done
        return 0
    fi
        return 0
    fi

    if [ -n "$1" ]; then
        _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
        [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ] && . "$_logdf/scripts/lib/managers_log_posix.sh" && managers_cli_log devman "$@"
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
            *)
                printf "${RED}Catégorie inconnue: %s${RESET}\n" "$1"
                echo "Utilisez 'devman help' pour voir les catégories disponibles"
                return 1
                ;;
        esac
    fi
}
