#!/bin/zsh
# =============================================================================
# VIRTMAN - Virtual Environment Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet des environnements virtuels (VMs, conteneurs)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoires de base
VIRTMAN_DIR="${VIRTMAN_DIR:-$HOME/dotfiles/zsh/functions/virtman}"
VIRTMAN_MODULES_DIR="$VIRTMAN_DIR/modules"

# Charger les utilitaires
if [ -d "$VIRTMAN_DIR/utils" ]; then
    shopt -s nullglob 2>/dev/null || setopt null_glob 2>/dev/null || true
    for util_file in "$VIRTMAN_DIR/utils"/*.sh; do
        if [ -f "$util_file" ]; then
            source "$util_file" 2>/dev/null || true
        fi
    done
    shopt -u nullglob 2>/dev/null || unsetopt null_glob 2>/dev/null || true
fi

# DESC: Gestionnaire interactif complet pour les environnements virtuels
# USAGE: virtman [category]
# EXAMPLE: virtman
# EXAMPLE: virtman qemu
# EXAMPLE: virtman docker
virtman() {
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
        echo "║              VIRTMAN - VIRTUAL ENVIRONMENT MANAGER             ║"
        echo "║         Gestionnaire d'Environnements Virtuels (VMs/Containers) ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        echo -e "${YELLOW}🖥️  GESTION DES ENVIRONNEMENTS VIRTUELS${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
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
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                if [ -f "$VIRTMAN_MODULES_DIR/docker/docker_manager.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/docker/docker_manager.sh"
                else
                    echo -e "${RED}❌ Module Docker non disponible${RESET}"
                    sleep 2
                fi
                ;;
            2)
                if [ -f "$VIRTMAN_MODULES_DIR/qemu/qemu_manager.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/qemu/qemu_manager.sh"
                else
                    echo -e "${RED}❌ Module QEMU/KVM non disponible${RESET}"
                    sleep 2
                fi
                ;;
            3)
                if [ -f "$VIRTMAN_MODULES_DIR/libvirt/libvirt_manager.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/libvirt/libvirt_manager.sh"
                else
                    echo -e "${RED}❌ Module libvirt non disponible${RESET}"
                    sleep 2
                fi
                ;;
            4)
                if [ -f "$VIRTMAN_MODULES_DIR/lxc/lxc_manager.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/lxc/lxc_manager.sh"
                else
                    echo -e "${RED}❌ Module LXC non disponible${RESET}"
                    sleep 2
                fi
                ;;
            5)
                if [ -f "$VIRTMAN_MODULES_DIR/vagrant/vagrant_manager.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/vagrant/vagrant_manager.sh"
                else
                    echo -e "${RED}❌ Module Vagrant non disponible${RESET}"
                    sleep 2
                fi
                ;;
            6)
                if [ -f "$VIRTMAN_MODULES_DIR/overview.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/overview.sh"
                else
                    echo -e "${YELLOW}⚠️  Vue d'ensemble non disponible${RESET}"
                    sleep 2
                fi
                ;;
            7)
                if [ -f "$VIRTMAN_MODULES_DIR/search.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/search.sh"
                else
                    echo -e "${YELLOW}⚠️  Recherche non disponible${RESET}"
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
        virtman
    }
    
    # Si un argument est fourni, lancer directement le module
    if [ -n "$1" ]; then
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
            overview|overview|all)
                if [ -f "$VIRTMAN_MODULES_DIR/overview.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/overview.sh"
                fi
                ;;
            search|find)
                if [ -f "$VIRTMAN_MODULES_DIR/search.sh" ]; then
                    bash "$VIRTMAN_MODULES_DIR/search.sh"
                fi
                ;;
            *)
                echo -e "${RED}Module inconnu: $1${RESET}"
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
    else
        # Mode interactif
        while true; do
            show_main_menu
        done
    fi
}

# Message d'initialisation - désactivé pour éviter l'avertissement Powerlevel10k
# echo "🖥️  VIRTMAN chargé - Tapez 'virtman' ou 'vm' pour démarrer"

# Alias
alias vm='virtman'
alias virt='virtman'

