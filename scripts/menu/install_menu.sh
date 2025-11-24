#!/bin/bash

################################################################################
# Menu d'installation - Menu interactif pour installer les applications
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

show_install_menu() {
    clear
    log_section "Menu d'installation"
    
    echo "Applications disponibles:"
    echo "  1. Docker & Docker Compose"
    echo "  2. Go (Golang)"
    echo "  3. Cursor IDE"
    echo "  4. Brave Browser"
    echo "  5. yay (AUR helper - Arch Linux)"
    echo "  6. NVM (Node Version Manager)"
    echo ""
    echo "Outils système:"
    echo "  7. Packages de base (Arch Linux)"
    echo "  8. Gestionnaires de paquets"
    echo "  9. QEMU/KVM complet"
    echo ""
    echo "  0. Retour au menu principal"
    echo ""
    
    printf "Votre choix [0-9]: "
    read -r choice
    
    case "$choice" in
        1)
            run_script "$SCRIPT_DIR/install/dev/install_docker.sh" "Installation Docker"
            ;;
        2)
            run_script "$SCRIPT_DIR/install/dev/install_go.sh" "Installation Go"
            ;;
        3)
            run_script "$SCRIPT_DIR/install/apps/install_cursor.sh" "Installation Cursor"
            ;;
        4)
            run_script "$SCRIPT_DIR/install/apps/install_brave.sh" "Installation Brave"
            ;;
        5)
            run_script "$SCRIPT_DIR/install/tools/install_yay.sh" "Installation yay"
            ;;
        6)
            run_script "$SCRIPT_DIR/install/tools/install_nvm.sh" "Installation NVM"
            ;;
        7)
            run_script "$SCRIPT_DIR/install/system/packages_base.sh" "Installation packages de base"
            ;;
        8)
            run_script "$SCRIPT_DIR/install/system/package_managers.sh" "Installation gestionnaires de paquets"
            ;;
        9)
            run_script "$SCRIPT_DIR/install/tools/install_qemu_full.sh" "Installation QEMU/KVM"
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
    show_install_menu
    if [ $? -eq 0 ] && [ "$choice" = "0" ]; then
        break
    fi
done

