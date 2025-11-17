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
    echo "12. Configuration auto-sync Git (systemd timer)"
    echo "13. Tester synchronisation manuellement"
    echo "14. Afficher statut auto-sync"
    echo ""
    echo "15. Installation Docker & Docker Compose"
    echo "16. Installation Docker Desktop (optionnel)"
    echo "17. Installation Brave Browser (optionnel)"
    echo "18. Installation yay (AUR - Arch Linux)"
    echo "19. Installation Go"
    echo ""
    echo "20. Recharger configuration ZSH"
    echo "21. Installer fonctions USB test"
    echo "22. Validation complète du setup"
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
            run_script "$SCRIPT_DIR/install/apps/install_cursor.sh" "Installation Cursor"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        9)
            run_script "$SCRIPT_DIR/install/apps/install_portproton.sh" "Installation PortProton"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        10)
            log_section "Installation complète système"
            run_script "$SCRIPT_DIR/install/system/packages_base.sh" "Paquets de base"
            run_script "$SCRIPT_DIR/install/system/package_managers.sh" "Gestionnaires"
            run_script "$SCRIPT_DIR/install/apps/install_cursor.sh" "Cursor"
            run_script "$SCRIPT_DIR/install/apps/install_portproton.sh" "PortProton"
            
            # Prompts pour installations optionnelles
            read -p "Installer Docker? (o/n): " install_docker
            if [[ "$install_docker" =~ ^[oO]$ ]]; then
                run_script "$SCRIPT_DIR/install/dev/install_docker.sh" "Docker"
            fi
            
            read -p "Installer Docker Desktop? (o/n): " install_docker_desktop
            if [[ "$install_docker_desktop" =~ ^[oO]$ ]]; then
                run_script "$SCRIPT_DIR/install/dev/install_docker.sh --desktop-only" "Docker Desktop"
            fi
            
            read -p "Installer Brave? (o/n): " install_brave
            if [[ "$install_brave" =~ ^[oO]$ ]]; then
                run_script "$SCRIPT_DIR/install/apps/install_brave.sh" "Brave"
            fi
            
            read -p "Configurer auto-sync Git? (o/n): " install_autosync
            if [[ "$install_autosync" =~ ^[oO]$ ]]; then
                run_script "$SCRIPT_DIR/sync/install_auto_sync.sh" "Auto-sync Git"
            fi
            
            log_info "✓ Installation système complète terminée"
            echo ""
            log_info "Résumé des installations:"
            echo "  ✓ Paquets de base"
            echo "  ✓ Gestionnaires"
            echo "  ✓ Cursor"
            echo "  ✓ PortProton"
            [ "$install_docker" = "o" ] && echo "  ✓ Docker"
            [ "$install_docker_desktop" = "o" ] && echo "  ✓ Docker Desktop"
            [ "$install_brave" = "o" ] && echo "  ✓ Brave"
            [ "$install_autosync" = "o" ] && echo "  ✓ Auto-sync Git"
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
        12)
            run_script "$SCRIPT_DIR/sync/install_auto_sync.sh" "Configuration auto-sync Git"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        13)
            run_script "$SCRIPT_DIR/sync/git_auto_sync.sh" "Test synchronisation manuelle"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        14)
            log_section "Statut auto-sync"
            systemctl --user status dotfiles-sync.timer --no-pager -l || log_warn "Timer non configuré"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        15)
            run_script "$SCRIPT_DIR/install/dev/install_docker.sh" "Installation Docker & Docker Compose"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        16)
            run_script "$SCRIPT_DIR/install/dev/install_docker.sh --desktop-only" "Installation Docker Desktop"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        17)
            run_script "$SCRIPT_DIR/install/apps/install_brave.sh" "Installation Brave Browser"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        18)
            run_script "$SCRIPT_DIR/install/tools/install_yay.sh" "Installation yay (AUR)"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        19)
            run_script "$SCRIPT_DIR/install/dev/install_go.sh" "Installation Go"
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        20)
            log_section "Rechargement configuration ZSH"
            log_info "Rechargement de la configuration ZSH..."
            exec zsh
            ;;
        21)
            log_section "Installation fonctions USB test"
            USB_FUNCTIONS="$DOTFILES_DIR/zsh/functions/misc/usb_test_functions.zsh"
            if [ -f "$USB_FUNCTIONS" ]; then
                log_info "Copie des fonctions USB test..."
                if [ -f "$HOME/.zshrc" ]; then
                    if ! grep -q "usb_test_functions.zsh" "$HOME/.zshrc"; then
                        echo "" >> "$HOME/.zshrc"
                        echo "# USB Test Functions" >> "$HOME/.zshrc"
                        echo "[ -f $USB_FUNCTIONS ] && source $USB_FUNCTIONS" >> "$HOME/.zshrc"
                        log_info "✓ Fonctions USB ajoutées au .zshrc"
                    else
                        log_info "✓ Fonctions USB déjà présentes"
                    fi
                fi
                source "$USB_FUNCTIONS" 2>/dev/null && log_info "✓ Fonctions USB chargées" || log_warn "⚠ Erreur lors du chargement"
            else
                log_error "Fichier non trouvé: $USB_FUNCTIONS"
            fi
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        22)
            run_script "$SCRIPT_DIR/test/validate_setup.sh" "Validation complète du setup"
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
