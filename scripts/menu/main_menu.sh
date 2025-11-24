#!/bin/bash

################################################################################
# Menu principal - Point d'entrée pour tous les menus
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

show_main_menu() {
    clear
    log_section "Menu principal - Dotfiles"
    
    echo "Menus disponibles:"
    echo "  1. Menu d'installation (applications, outils)"
    echo "  2. Menu de configuration (Git, shell, symlinks)"
    echo "  3. Menu de gestion des shells (zsh/fish/bash)"
    echo "  4. Menu de gestion des VM (tests)"
    echo "  5. Menu de validation (vérifier le setup)"
    echo "  6. Menu de corrections (fixes automatiques)"
    echo ""
    echo "Actions rapides:"
    echo "  7. Validation complète (make validate)"
    echo "  8. Setup complet (menu setup.sh)"
    echo ""
    echo "  0. Quitter"
    echo ""
    
    printf "Votre choix [0-8]: "
    read -r choice
    
    case "$choice" in
        1)
            bash "$SCRIPT_DIR/menu/install_menu.sh"
            ;;
        2)
            bash "$SCRIPT_DIR/menu/config_menu.sh"
            ;;
        3)
            bash "$SCRIPT_DIR/config/shell_manager.sh" "menu"
            ;;
        4)
            bash "$SCRIPT_DIR/vm/vm_manager.sh"
            ;;
        5)
            log_section "Validation du setup"
            bash "$SCRIPT_DIR/test/validate_setup.sh"
            echo ""
            printf "Appuyez sur Entrée pour continuer... "
            read -r dummy
            ;;
        6)
            bash "$SCRIPT_DIR/fix/fix_manager.sh"
            echo ""
            printf "Appuyez sur Entrée pour continuer... "
            read -r dummy
            ;;
        7)
            log_section "Validation complète"
            bash "$SCRIPT_DIR/test/validate_setup.sh"
            echo ""
            printf "Appuyez sur Entrée pour continuer... "
            read -r dummy
            ;;
        8)
            bash "$SCRIPT_DIR/setup.sh"
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
}

# Boucle principale
while true; do
    show_main_menu
done

