#!/bin/sh
# =============================================================================
# CONFIGMAN - Configuration Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des configurations système
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

# DESC: Gestionnaire interactif complet pour les configurations système
# USAGE: configman [category]
# EXAMPLE: configman
# EXAMPLE: configman git
# EXAMPLE: configman qemu
configman() {
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
    CONFIGMAN_DIR="$DOTFILES_DIR/zsh/functions/configman"
    CONFIGMAN_MODULES_DIR="$CONFIGMAN_DIR/modules"
    
    # Charger les utilitaires si disponibles
    if [ -d "$CONFIGMAN_DIR/utils" ]; then
        for util_file in "$CONFIGMAN_DIR/utils"/*.sh; do
            if [ -f "$util_file" ]; then
                . "$util_file" 2>/dev/null || true
            fi
        done
    fi
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                  CONFIGMAN - CONFIGURATION MANAGER             ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
    }
    
    # Fonction pour afficher la vue d'ensemble de la configuration
    show_config_overview() {
        show_header
        printf "${YELLOW}👁️  VUE D'ENSEMBLE DE LA CONFIGURATION${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        # Versions des outils
        printf "${BOLD}📊 Versions des outils:${RESET}\n"
        node_ver="N/A"
        python_ver="N/A"
        java_ver="N/A"
        if command -v get_current_node_version >/dev/null 2>&1; then
            node_ver=$(get_current_node_version 2>/dev/null || echo "N/A")
        elif command -v node >/dev/null 2>&1; then
            node_ver=$(node --version 2>/dev/null | head -n1 || echo "N/A")
        fi
        if command -v get_current_python_version >/dev/null 2>&1; then
            python_ver=$(get_current_python_version 2>/dev/null || echo "N/A")
        elif command -v python3 >/dev/null 2>&1; then
            python_ver=$(python3 --version 2>/dev/null | head -n1 || echo "N/A")
        fi
        if command -v get_current_java_version >/dev/null 2>&1; then
            java_ver=$(get_current_java_version 2>/dev/null || echo "N/A")
        elif command -v java >/dev/null 2>&1; then
            java_ver=$(java -version 2>&1 | head -n1 || echo "N/A")
        fi
        printf "  Node.js:   ${GREEN}%s${RESET}\n" "$node_ver"
        printf "  Python:    ${GREEN}%s${RESET}\n" "$python_ver"
        printf "  Java:      ${GREEN}%s${RESET}\n" "$java_ver"
        echo ""
        
        # Configuration Git
        printf "${BOLD}🔧 Configuration Git:${RESET}\n"
        if command -v git >/dev/null 2>&1; then
            git_name=$(git config --global user.name 2>/dev/null || echo "Non configuré")
            git_email=$(git config --global user.email 2>/dev/null || echo "Non configuré")
            git_remote=$(git config --global remote.origin.url 2>/dev/null || echo "Non configuré")
            printf "  Nom:       ${GREEN}%s${RESET}\n" "$git_name"
            printf "  Email:     ${GREEN}%s${RESET}\n" "$git_email"
            printf "  Remote:    ${GREEN}%s${RESET}\n" "$git_remote"
        else
            printf "  ${YELLOW}Git non installé${RESET}\n"
        fi
        echo ""
        
        # Gestionnaires de paquets
        printf "${BOLD}📦 Gestionnaires de paquets:${RESET}\n"
        managers=""
        command -v pacman >/dev/null 2>&1 && managers="${managers} pacman"
        command -v yay >/dev/null 2>&1 && managers="${managers} yay"
        command -v snap >/dev/null 2>&1 && managers="${managers} snap"
        command -v flatpak >/dev/null 2>&1 && managers="${managers} flatpak"
        command -v apt >/dev/null 2>&1 && managers="${managers} apt"
        command -v dnf >/dev/null 2>&1 && managers="${managers} dnf"
        command -v npm >/dev/null 2>&1 && managers="${managers} npm"
        if [ -n "$managers" ]; then
            printf "  Disponibles: ${GREEN}%s${RESET}\n" "$(echo "$managers" | sed 's/^ //')"
        else
            printf "  ${YELLOW}Aucun gestionnaire détecté${RESET}\n"
        fi
        echo ""
        
        # Outils installés via installman
        printf "${BOLD}🛠️  Outils installés:${RESET}\n"
        tools=""
        command -v flutter >/dev/null 2>&1 && tools="${tools} Flutter"
        command -v dotnet >/dev/null 2>&1 && tools="${tools} .NET"
        command -v docker >/dev/null 2>&1 && tools="${tools} Docker"
        command -v emacs >/dev/null 2>&1 && tools="${tools} Emacs"
        command -v java >/dev/null 2>&1 && tools="${tools} Java"
        if [ -n "$tools" ]; then
            printf "  ${GREEN}%s${RESET}\n" "$(echo "$tools" | sed 's/^ //')"
        else
            printf "  ${YELLOW}Aucun outil détecté${RESET}\n"
        fi
        echo ""
        
        # Shells disponibles
        printf "${BOLD}🐚 Shells disponibles:${RESET}\n"
        shells=""
        command -v zsh >/dev/null 2>&1 && shells="${shells} zsh"
        command -v bash >/dev/null 2>&1 && shells="${shells} bash"
        command -v fish >/dev/null 2>&1 && shells="${shells} fish"
        if [ -n "$shells" ]; then
            printf "  ${GREEN}%s${RESET}\n" "$(echo "$shells" | sed 's/^ //')"
        fi
        printf "  Shell actuel: ${GREEN}%s${RESET}\n" "${SHELL:-$0}"
        echo ""
        
        # Configuration SSH
        printf "${BOLD}🔐 Configuration SSH:${RESET}\n"
        if [ -f ~/.ssh/id_ed25519 ] || [ -f ~/.ssh/id_rsa ]; then
            printf "  ${GREEN}Clés SSH présentes${RESET}\n"
        else
            printf "  ${YELLOW}Aucune clé SSH trouvée${RESET}\n"
        fi
        echo ""
        
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Fonction pour le menu de gestion de versions
    version_manager_menu() {
        show_header
        printf "${YELLOW}📊 GESTION DE VERSIONS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        if [ -f "$CONFIGMAN_DIR/utils/version_manager.sh" ]; then
            # Charger le script de gestion de versions
            . "$CONFIGMAN_DIR/utils/version_manager.sh" 2>/dev/null || true
            
            # Appeler la fonction menu si elle existe
            if command -v version_manager_menu_internal >/dev/null 2>&1; then
                version_manager_menu_internal
            else
                printf "${YELLOW}⚠️  Menu de gestion de versions non disponible${RESET}\n"
                printf "Appuyez sur Entrée pour continuer... "
                read dummy
            fi
        else
            printf "${RED}❌ Module de gestion de versions non disponible${RESET}\n"
            printf "Appuyez sur Entrée pour continuer... "
            read dummy
        fi
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        printf "${YELLOW}⚙️  CONFIGURATIONS SYSTÈME${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        echo "1.  📦 Git (configuration Git globale)"
        echo "2.  🔗 Git Remote (configuration remote GitHub)"
        echo "3.  🔗 Symlinks (création des symlinks dotfiles)"
        echo "4.  🐚 Shell (gestion des shells)"
        echo "5.  🎨 Powerlevel10k (configuration prompt avec Git)"
        echo "6.  🔐 SSH (configuration connexion SSH interactive)"
        echo "6a. 🔐 SSH Auto (configuration automatique avec mot de passe .env)"
        echo "7.  🖥️  QEMU Libvirt (permissions libvirt)"
        echo "8.  🌐 QEMU Network (configuration réseau NAT)"
        echo "9.  📦 QEMU Packages (installation paquets QEMU)"
        echo "10. 🔍 OSINT Tools (configuration outils OSINT et clés API)"
        echo "11. 📊 Gestion de versions (Node, Python, Java)"
        echo "12. 👁️  Visualisation de configuration complète"
        echo ""
        echo "0.  Quitter"
        echo ""
        printf "Choix: "
        read choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                if [ -f "$CONFIGMAN_MODULES_DIR/git/git_config.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/git/git_config.sh"
                else
                    printf "${RED}❌ Module Git non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            2)
                if [ -f "$CONFIGMAN_MODULES_DIR/git/git_remote.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/git/git_remote.sh"
                else
                    printf "${RED}❌ Module Git Remote non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            3)
                if [ -f "$CONFIGMAN_MODULES_DIR/symlinks/create_symlinks.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/symlinks/create_symlinks.sh"
                else
                    printf "${RED}❌ Module Symlinks non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            4)
                if [ -f "$CONFIGMAN_MODULES_DIR/shell/shell_manager.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/shell/shell_manager.sh" menu
                else
                    printf "${RED}❌ Module Shell non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            5)
                if [ -f "$CONFIGMAN_MODULES_DIR/prompt/p10k_config.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/prompt/p10k_config.sh"
                else
                    printf "${RED}❌ Module Powerlevel10k non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            6)
                if [ -f "$CONFIGMAN_MODULES_DIR/ssh/ssh_config.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/ssh/ssh_config.sh"
                else
                    printf "${RED}❌ Module SSH non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            6a)
                if [ -f "$CONFIGMAN_MODULES_DIR/ssh/ssh_auto_setup.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/ssh/ssh_auto_setup.sh"
                else
                    printf "${RED}❌ Module SSH Auto non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            7)
                if [ -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_libvirt.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_libvirt.sh"
                else
                    printf "${RED}❌ Module QEMU Libvirt non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            8)
                if [ -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_network.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_network.sh"
                else
                    printf "${RED}❌ Module QEMU Network non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            9)
                if [ -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_packages.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_packages.sh"
                else
                    printf "${RED}❌ Module QEMU Packages non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            10)
                if [ -f "$CONFIGMAN_MODULES_DIR/osint/osint_config.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/osint/osint_config.sh"
                else
                    printf "${RED}❌ Module OSINT Config non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            11)
                version_manager_menu
                ;;
            12)
                show_config_overview
                ;;
            0)
                return 0
                ;;
            *)
                printf "${RED}Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
    }
    
    # Si un argument est fourni, lancer directement le module
    if [ -n "$1" ]; then
        CONFIGMAN_MODULES_DIR="$CONFIGMAN_DIR/modules"
        
        case "$1" in
            git)
                if [ -f "$CONFIGMAN_MODULES_DIR/git/git_config.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/git/git_config.sh"
                fi
                ;;
            git-remote|gitremote)
                if [ -f "$CONFIGMAN_MODULES_DIR/git/git_remote.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/git/git_remote.sh"
                fi
                ;;
            symlinks|symlink)
                if [ -f "$CONFIGMAN_MODULES_DIR/symlinks/create_symlinks.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/symlinks/create_symlinks.sh"
                fi
                ;;
            shell)
                if [ -f "$CONFIGMAN_MODULES_DIR/shell/shell_manager.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/shell/shell_manager.sh" menu
                fi
                ;;
            p10k|powerlevel10k|prompt)
                if [ -f "$CONFIGMAN_MODULES_DIR/prompt/p10k_config.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/prompt/p10k_config.sh"
                fi
                ;;
            ssh)
                if [ -f "$CONFIGMAN_MODULES_DIR/ssh/ssh_config.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/ssh/ssh_config.sh"
                fi
                ;;
            ssh-auto|sshauto)
                if [ -f "$CONFIGMAN_MODULES_DIR/ssh/ssh_auto_setup.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/ssh/ssh_auto_setup.sh" "$2" "$3" "$4" "$5"
                fi
                ;;
            qemu-libvirt|qemulibvirt)
                if [ -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_libvirt.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_libvirt.sh"
                fi
                ;;
            qemu-network|qemunetwork)
                if [ -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_network.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_network.sh"
                fi
                ;;
            qemu-packages|qemupackages)
                if [ -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_packages.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_packages.sh"
                fi
                ;;
            osint|osint-config)
                CONFIGMAN_MODULES_DIR="$CONFIGMAN_DIR/modules"
                osint_script="$CONFIGMAN_MODULES_DIR/osint/osint_config.sh"
                if [ -f "$osint_script" ]; then
                    bash "$osint_script"
                else
                    printf "${RED}❌ Module OSINT non disponible${RESET}\n"
                    printf "${YELLOW}Fichier attendu: %s${RESET}\n" "$osint_script"
                    printf "${CYAN}CONFIGMAN_DIR: %s${RESET}\n" "$CONFIGMAN_DIR"
                    printf "${CYAN}CONFIGMAN_MODULES_DIR: %s${RESET}\n" "$CONFIGMAN_MODULES_DIR"
                    ls -la "$CONFIGMAN_MODULES_DIR" 2>/dev/null || echo "Répertoire modules n'existe pas"
                    return 1
                fi
                ;;
            version|versions|version-manager)
                version_manager_menu
                ;;
            overview|config-overview)
                show_config_overview
                ;;
            *)
                printf "${RED}Module inconnu: %s${RESET}\n" "$1"
                echo ""
                echo "Modules disponibles:"
                echo "  - git"
                echo "  - git-remote"
                echo "  - symlinks"
                echo "  - shell"
                echo "  - p10k (Powerlevel10k)"
                echo "  - ssh (configuration SSH interactive)"
                echo "  - ssh-auto (configuration SSH automatique avec .env)"
                echo "  - qemu-libvirt"
                echo "  - qemu-network"
                echo "  - qemu-packages"
                echo "  - osint (configuration outils OSINT et clés API)"
                echo "  - version (gestion de versions)"
                echo "  - overview (visualisation de configuration)"
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
