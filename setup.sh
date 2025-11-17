#!/bin/bash

################################################################################
# Setup modulaire dotfiles - Menu interactif
# Permet de choisir ce qu'on veut installer/configurer
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

DOTFILES_DIR="$HOME/dotfiles"
SCRIPT_DIR="$DOTFILES_DIR/scripts"

################################################################################
# FONCTIONS UTILITAIRES
################################################################################
is_installed() {
    command -v "$1" >/dev/null 2>&1
}

is_package_installed() {
    pacman -Q "$1" >/dev/null 2>&1 2>/dev/null
}

run_script() {
    local script="$1"
    local name="$2"
    if [ -f "$script" ]; then
        log_info "Exécution: $name"
        bash "$script"
    else
        log_error "Script non trouvé: $script"
    fi
}

################################################################################
# MENU PRINCIPAL
################################################################################
show_menu() {
    clear
    log_section "Setup modulaire dotfiles"
    echo ""
    echo "1.  Configuration Git"
    echo "2.  Configuration remote Git (SSH/HTTPS)"
    echo ""
    echo "3.  Installation paquets de base (btop, curl, wget, etc.)"
    echo "4.  Installation gestionnaires (yay, snap, flatpak)"
    echo ""
    echo "5.  Installation QEMU/KVM (paquets)"
    echo "6.  Configuration réseau QEMU"
    echo "7.  Configuration libvirt (permissions)"
    echo ""
    echo "8.  Installation Cursor"
    echo "9.  Installation PortProton"
    echo ""
    echo "10. Installation complète système (tout)"
    echo "11. Configuration complète QEMU (tout)"
    echo ""
    echo "0.  Quitter"
    echo ""
}

################################################################################
# OPTIONS DU MENU
################################################################################
while true; do
    show_menu
    read -p "Choix: " choice
    
    case $choice in
        1)
            run_script "$SCRIPT_DIR/config/git_config.sh" "Configuration Git"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        2)
            run_script "$SCRIPT_DIR/config/git_remote.sh" "Configuration remote Git"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        3)
            run_script "$SCRIPT_DIR/install/system/packages_base.sh" "Paquets de base"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        4)
            run_script "$SCRIPT_DIR/install/system/package_managers.sh" "Gestionnaires de paquets"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        5)
            run_script "$SCRIPT_DIR/config/qemu_packages.sh" "Installation QEMU/KVM"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        6)
            run_script "$SCRIPT_DIR/config/qemu_network.sh" "Configuration réseau QEMU"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        7)
            run_script "$SCRIPT_DIR/config/qemu_libvirt.sh" "Configuration libvirt"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        8)
            run_script "$SCRIPT_DIR/install/install_cursor.sh" "Installation Cursor"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        9)
            run_script "$SCRIPT_DIR/install/install_portproton.sh" "Installation PortProton"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        10)
            log_section "Installation complète système"
            run_script "$SCRIPT_DIR/install/system/packages_base.sh" "Paquets de base"
            run_script "$SCRIPT_DIR/install/system/package_managers.sh" "Gestionnaires"
            run_script "$SCRIPT_DIR/install/install_cursor.sh" "Cursor"
            run_script "$SCRIPT_DIR/install/install_portproton.sh" "PortProton"
            log_info "✓ Installation système complète terminée"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        11)
            log_section "Configuration complète QEMU"
            run_script "$SCRIPT_DIR/config/qemu_packages.sh" "Paquets QEMU"
            run_script "$SCRIPT_DIR/config/qemu_network.sh" "Réseau"
            run_script "$SCRIPT_DIR/config/qemu_libvirt.sh" "Libvirt"
            log_info "✓ Configuration QEMU complète terminée"
            log_warn "⚠ Déconnectez-vous et reconnectez-vous pour groupe libvirt"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        0)
            log_info "Au revoir!"
            exit 0
            ;;
        *)
            log_error "Choix invalide"
            sleep 1
            ;;
    esac
done
