#!/bin/sh
# =============================================================================
# VIRTMAN - Virtual Environment Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des environnements virtuels (VMs, conteneurs)
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

# DESC: Gestionnaire interactif complet pour les environnements virtuels
# USAGE: virtman [category]
# EXAMPLE: virtman
# EXAMPLE: virtman qemu
# EXAMPLE: virtman docker
virtman() {
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
    VIRTMAN_DIR="$DOTFILES_DIR/zsh/functions/virtman"
    VIRTMAN_MODULES_DIR="$VIRTMAN_DIR/modules"
    if [ -f "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh"
    fi
    
    pause_if_tty() {
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée pour continuer... "
            read dummy
        fi
    }
    
    # Charger les utilitaires si disponibles
    if [ -d "$VIRTMAN_DIR/utils" ]; then
        for util_file in "$VIRTMAN_DIR/utils"/*.sh; do
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
        echo "║              VIRTMAN - VIRTUAL ENVIRONMENT MANAGER             ║"
        echo "║         Gestionnaire d'Environnements Virtuels (VMs/Containers) ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        printf "${YELLOW}🖥️  GESTION DES ENVIRONNEMENTS VIRTUELS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        echo "1.  🐳 Docker (conteneurs)"
        echo "2.  ⚡ QEMU/KVM (machines virtuelles)"
        echo "3.  🔧 libvirt/virsh (gestion VMs)"
        echo "4.  📦 LXC (Linux Containers)"
        echo "5.  🚀 Vagrant (VMs provisionnées)"
        echo "6.  📊 Vue d'ensemble (tous les environnements)"
        echo "7.  🔍 Recherche d'environnements"
        echo ""
        echo "0.  Quitter"
        echo ""
        choice=""
        if [ -t 0 ] && [ -t 1 ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
            menu_input_file=$(mktemp)
            cat > "$menu_input_file" <<'EOF'
Docker (conteneurs)|1
QEMU/KVM (machines virtuelles)|2
libvirt/virsh (gestion VMs)|3
LXC (Linux Containers)|4
Vagrant (VMs provisionnees)|5
Vue d'ensemble (tous les environnements)|6
Recherche d'environnements|7
Quitter|0
EOF
            choice=$(dotfiles_ncmenu_select "VIRTMAN - Menu principal" < "$menu_input_file" 2>/dev/null || true)
            rm -f "$menu_input_file"
        fi
        if [ -z "$choice" ]; then
            printf "Choix: "
            read choice
            choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        fi
        
        case "$choice" in
            1)
                if [ -f "$VIRTMAN_MODULES_DIR/docker/docker_manager.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/docker/docker_manager.sh"
                else
                    printf "${RED}❌ Module Docker non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            2)
                if [ -f "$VIRTMAN_MODULES_DIR/qemu/qemu_manager.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/qemu/qemu_manager.sh"
                else
                    printf "${RED}❌ Module QEMU/KVM non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            3)
                if [ -f "$VIRTMAN_MODULES_DIR/libvirt/libvirt_manager.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/libvirt/libvirt_manager.sh"
                else
                    printf "${RED}❌ Module libvirt non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            4)
                if [ -f "$VIRTMAN_MODULES_DIR/lxc/lxc_manager.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/lxc/lxc_manager.sh"
                else
                    printf "${RED}❌ Module LXC non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            5)
                if [ -f "$VIRTMAN_MODULES_DIR/vagrant/vagrant_manager.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/vagrant/vagrant_manager.sh"
                else
                    printf "${RED}❌ Module Vagrant non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            6)
                if [ -f "$VIRTMAN_MODULES_DIR/overview.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/overview.sh"
                else
                    printf "${YELLOW}⚠️  Vue d'ensemble non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            7)
                if [ -f "$VIRTMAN_MODULES_DIR/search.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/search.sh"
                else
                    printf "${YELLOW}⚠️  Recherche non disponible${RESET}\n"
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
        pause_if_tty
    }
    
    # Si un argument est fourni, lancer directement le module
    if [ -z "$1" ] || [ "$1" = "--help" ]; then
        :
    elif [ -n "$1" ]; then
        _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
        [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ] && . "$_logdf/scripts/lib/managers_log_posix.sh" && managers_cli_log virtman "$@"
        case "$1" in
            docker|d)
                if [ -f "$VIRTMAN_MODULES_DIR/docker/docker_manager.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/docker/docker_manager.sh"
                fi
                ;;
            qemu|kvm|vm)
                if [ -f "$VIRTMAN_MODULES_DIR/qemu/qemu_manager.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/qemu/qemu_manager.sh"
                fi
                ;;
            libvirt|virsh)
                if [ -f "$VIRTMAN_MODULES_DIR/libvirt/libvirt_manager.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/libvirt/libvirt_manager.sh"
                fi
                ;;
            lxc)
                if [ -f "$VIRTMAN_MODULES_DIR/lxc/lxc_manager.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/lxc/lxc_manager.sh"
                fi
                ;;
            vagrant)
                if [ -f "$VIRTMAN_MODULES_DIR/vagrant/vagrant_manager.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/vagrant/vagrant_manager.sh"
                fi
                ;;
            overview|all)
                if [ -f "$VIRTMAN_MODULES_DIR/overview.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/overview.sh"
                fi
                ;;
            search|find)
                if [ -f "$VIRTMAN_MODULES_DIR/search.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/search.sh"
                fi
                ;;
            help|-h)
                echo "🖥️  VIRTMAN - Virtual Environment Manager"
                echo ""
                echo "Usage: virtman [module]"
                echo ""
                echo "Modules disponibles:"
                echo "  docker    - Gestion conteneurs Docker"
                echo "  qemu|kvm|vm - Machines virtuelles QEMU/KVM"
                echo "  libvirt|virsh - Gestion VMs via libvirt"
                echo "  lxc       - Linux Containers"
                echo "  vagrant   - VMs provisionnées Vagrant"
                echo "  overview|all - Vue d'ensemble"
                echo "  search|find - Recherche d'environnements"
                echo ""
                echo "Sans argument ou virtman --help : menu interactif"
                ;;
            *)
                printf "${RED}Module inconnu: %s${RESET}\n" "$1"
                echo ""
                echo "Modules disponibles:"
                echo "  - docker"
                echo "  - qemu"
                echo "  - libvirt"
                echo "  - lxc"
                echo "  - vagrant"
                echo "  - overview"
                echo "  - search"
                return 1
                ;;
        esac
    fi
    if [ -z "$1" ] || [ "$1" = "--help" ]; then
        if [ "$1" = "--help" ]; then
            virtman help
            if ! { [ -t 0 ] && [ -t 1 ]; }; then
                return 0
            fi
            if [ -t 0 ] && [ -t 1 ]; then
                printf "Appuyez sur Entrée pour continuer... "
                read _virt_dummy || true
            fi
        fi
        # Mode interactif
        while true; do
            show_main_menu
        done
    fi
}
