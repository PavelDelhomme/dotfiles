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
    echo " 10. Neofetch (affichage système)"
    echo ""
    echo "Cybersécurité (cyberman):"
    echo " 11. Outils de cybersécurité complets"
    echo " 12. Dépendances cyberman (jq pour workflows/rapports)"
    echo ""
    echo "🛠️  Managers & Outils:"
    echo " 13. Vérifier/Configurer tous les managers (cyberman, devman, gitman, etc.)"
    echo " 14. Installer dépendances managers (jq, git, etc.)"
    echo ""
    echo "  0. Retour au menu principal"
    echo ""
    
    printf "Votre choix [0-14]: "
    read -r choice
    
    case "$choice" in
        1)
            log_section "Installation Docker"
            bash "$SCRIPT_DIR/install/dev/install_docker.sh"
            ;;
        2)
            log_section "Installation Go"
            bash "$SCRIPT_DIR/install/dev/install_go.sh"
            ;;
        3)
            log_section "Installation Cursor"
            bash "$SCRIPT_DIR/install/apps/install_cursor.sh"
            ;;
        4)
            log_section "Installation Brave"
            bash "$SCRIPT_DIR/install/apps/install_brave.sh"
            ;;
        5)
            log_section "Installation yay"
            bash "$SCRIPT_DIR/install/tools/install_yay.sh"
            ;;
        6)
            log_section "Installation NVM"
            bash "$SCRIPT_DIR/install/tools/install_nvm.sh"
            ;;
        7)
            log_section "Installation packages de base"
            bash "$SCRIPT_DIR/install/system/packages_base.sh"
            ;;
        8)
            log_section "Installation gestionnaires de paquets"
            bash "$SCRIPT_DIR/install/system/package_managers.sh"
            ;;
        9)
            log_section "Installation QEMU/KVM"
            bash "$SCRIPT_DIR/install/tools/install_qemu_full.sh"
            ;;
        10)
            log_section "Installation Neofetch"
            if command -v pacman >/dev/null 2>&1; then
                log_info "Installation via pacman..."
                sudo pacman -S --noconfirm neofetch
            elif command -v apt-get >/dev/null 2>&1; then
                log_info "Installation via apt-get..."
                sudo apt-get install -y neofetch
            elif command -v yum >/dev/null 2>&1; then
                log_info "Installation via yum..."
                sudo yum install -y neofetch
            else
                log_error "Gestionnaire de paquets non supporté"
            fi
            if command -v neofetch >/dev/null 2>&1; then
                log_info "✓ Neofetch installé avec succès"
            else
                log_error "✗ Erreur lors de l'installation de Neofetch"
            fi
            ;;
        11)
            log_section "Installation outils de cybersécurité"
            bash "$SCRIPT_DIR/install/cyber/install_cyber_tools.sh"
            ;;
        12)
            log_section "Installation dépendances cyberman"
            bash "$SCRIPT_DIR/tools/install_cyberman_deps.sh"
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

