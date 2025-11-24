#!/bin/bash

################################################################################
# Menu de configuration - Menu interactif pour configurer le système
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

show_config_menu() {
    clear
    log_section "Menu de configuration"
    
    echo "Configuration Git:"
    echo "  1. Configurer Git (nom, email)"
    echo "  2. Configurer remote Git (SSH/HTTPS)"
    echo ""
    echo "Configuration système:"
    echo "  3. Créer les symlinks de configuration"
    echo "  4. Gestionnaire de shell (zsh/fish/bash)"
    echo "  5. Configurer auto-sync Git (systemd timer)"
    echo ""
    echo "Configuration QEMU/KVM:"
    echo "  6. Configuration réseau QEMU"
    echo "  7. Configuration libvirt QEMU"
    echo "  8. Packages QEMU"
    echo ""
    echo "  0. Retour au menu principal"
    echo ""
    
    printf "Votre choix [0-8]: "
    read -r choice
    
    case "$choice" in
        1)
            log_section "Configuration Git"
            bash "$SCRIPT_DIR/config/git_config.sh"
            ;;
        2)
            log_section "Configuration remote Git"
            bash "$SCRIPT_DIR/config/git_remote.sh"
            ;;
        3)
            log_section "Création des symlinks"
            bash "$SCRIPT_DIR/config/create_symlinks.sh"
            ;;
        4)
            log_section "Gestionnaire de shell"
            bash "$SCRIPT_DIR/config/shell_manager.sh" "menu"
            ;;
        5)
            log_section "Configuration auto-sync"
            bash "$SCRIPT_DIR/sync/install_auto_sync.sh"
            ;;
        6)
            log_section "Configuration réseau QEMU"
            bash "$SCRIPT_DIR/config/qemu_network.sh"
            ;;
        7)
            log_section "Configuration libvirt QEMU"
            bash "$SCRIPT_DIR/config/qemu_libvirt.sh"
            ;;
        8)
            log_section "Packages QEMU"
            bash "$SCRIPT_DIR/config/qemu_packages.sh"
            ;;
        0)
            return 0
            ;;
        *)
            log_error "Choix invalide"
            sleep 1
            ;;
    esac
    
    echo ""
    printf "Appuyez sur Entrée pour continuer... "
    read -r dummy
}

# Boucle principale
while true; do
    show_config_menu
    if [ $? -eq 0 ] && [ "$choice" = "0" ]; then
        break
    fi
done

