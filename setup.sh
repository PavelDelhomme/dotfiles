#!/bin/bash

################################################################################
# Setup modulaire dotfiles - Menu interactif
# Permet de choisir ce qu'on veut installer/configurer
################################################################################

# Ne pas utiliser set -e pour permettre la gestion d'erreurs dans le menu
set +e

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
        bash "$script" || {
            log_error "Erreur lors de l'exécution de: $name"
            return 1
        }
    else
        log_error "Script non trouvé: $script"
        return 1
    fi
}

################################################################################
# MENU PRINCIPAL
################################################################################
show_menu() {
    # Ne pas utiliser clear dans certains environnements (peut causer des problèmes)
    # clear
    echo ""
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
    echo "23. Créer symlinks (centraliser configuration)"
    echo ""
    echo "99. ROLLBACK - Désinstaller tout (ATTENTION!)"
    echo "98. RÉINITIALISATION - Remise à zéro complète (ATTENTION!)"
    echo ""
    echo "0.  Quitter"
    echo ""
}

################################################################################
# OPTIONS DU MENU
################################################################################
while true; do
    show_menu
    printf "Choix: "
    
    # Lire l'input de manière simple et robuste
    # Utiliser read avec IFS vide pour éviter les problèmes d'espaces
    IFS= read -r choice </dev/tty 2>/dev/null || read -r choice
    
    # Nettoyer le choix : enlever tous les espaces et caractères non-numériques
    # Garder uniquement les chiffres
    choice=$(echo "$choice" | tr -d '[:space:]' | tr -cd '0-9' | head -c 10)
    
    # Si le choix est vide, demander à nouveau sans réafficher tout le menu
    if [ -z "$choice" ]; then
        echo ""
        log_warn "Choix vide, veuillez entrer un nombre"
        sleep 1
        echo ""
        continue
    fi
    
    # Vérifier que le choix est un nombre valide (déjà fait par tr, mais double vérification)
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo ""
        log_error "Choix invalide: '$choice' (doit être un nombre)"
        log_info "Veuillez entrer un nombre entre 0 et 99"
        sleep 2
        echo ""
        continue
    fi
    
    case "$choice" in
        1)
            run_script "$SCRIPT_DIR/config/git_config.sh" "Configuration Git"
            printf "\nAppuyez sur Entrée pour continuer... "
            read -r dummy
            ;;
        2)
            run_script "$SCRIPT_DIR/config/git_remote.sh" "Configuration remote Git"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        3)
            run_script "$SCRIPT_DIR/install/system/packages_base.sh" "Paquets de base"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        4)
            run_script "$SCRIPT_DIR/install/system/package_managers.sh" "Gestionnaires de paquets"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        5)
            run_script "$SCRIPT_DIR/config/qemu_packages.sh" "Installation QEMU/KVM"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        6)
            run_script "$SCRIPT_DIR/config/qemu_network.sh" "Configuration réseau QEMU"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        7)
            run_script "$SCRIPT_DIR/config/qemu_libvirt.sh" "Configuration libvirt"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        8)
            run_script "$SCRIPT_DIR/install/apps/install_cursor.sh" "Installation Cursor"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        9)
            run_script "$SCRIPT_DIR/install/apps/install_portproton.sh" "Installation PortProton"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        10)
            log_section "Installation complète système"
            run_script "$SCRIPT_DIR/install/system/packages_base.sh" "Paquets de base"
            run_script "$SCRIPT_DIR/install/system/package_managers.sh" "Gestionnaires"
            run_script "$SCRIPT_DIR/install/apps/install_cursor.sh" "Cursor"
            run_script "$SCRIPT_DIR/install/apps/install_portproton.sh" "PortProton"
            
            # Prompts pour installations optionnelles
            printf "Installer Docker? (o/n): "
            read -r install_docker
            if [[ "$install_docker" =~ ^[oO]$ ]]; then
                run_script "$SCRIPT_DIR/install/dev/install_docker.sh" "Docker"
            fi
            
            printf "Installer Docker Desktop? (o/n): "
            read -r install_docker_desktop
            if [[ "$install_docker_desktop" =~ ^[oO]$ ]]; then
                run_script "$SCRIPT_DIR/install/dev/install_docker.sh --desktop-only" "Docker Desktop"
            fi
            
            printf "Installer Brave? (o/n): "
            read -r install_brave
            if [[ "$install_brave" =~ ^[oO]$ ]]; then
                run_script "$SCRIPT_DIR/install/apps/install_brave.sh" "Brave"
            fi
            
            printf "Configurer auto-sync Git? (o/n): "
            read -r install_autosync
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
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        11)
            log_section "Configuration complète QEMU"
            run_script "$SCRIPT_DIR/config/qemu_packages.sh" "Paquets QEMU"
            run_script "$SCRIPT_DIR/config/qemu_network.sh" "Réseau"
            run_script "$SCRIPT_DIR/config/qemu_libvirt.sh" "Libvirt"
            log_info "✓ Configuration QEMU complète terminée"
            log_warn "⚠ Déconnectez-vous et reconnectez-vous pour groupe libvirt"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        12)
            run_script "$SCRIPT_DIR/sync/install_auto_sync.sh" "Configuration auto-sync Git"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        13)
            run_script "$SCRIPT_DIR/sync/git_auto_sync.sh" "Test synchronisation manuelle"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        14)
            log_section "Statut auto-sync"
            systemctl --user status dotfiles-sync.timer --no-pager -l || log_warn "Timer non configuré"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        15)
            run_script "$SCRIPT_DIR/install/dev/install_docker.sh" "Installation Docker & Docker Compose"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        16)
            run_script "$SCRIPT_DIR/install/dev/install_docker.sh --desktop-only" "Installation Docker Desktop"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        17)
            run_script "$SCRIPT_DIR/install/apps/install_brave.sh" "Installation Brave Browser"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        18)
            run_script "$SCRIPT_DIR/install/tools/install_yay.sh" "Installation yay (AUR)"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        19)
            run_script "$SCRIPT_DIR/install/dev/install_go.sh" "Installation Go"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
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
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        22)
            run_script "$SCRIPT_DIR/test/validate_setup.sh" "Validation complète du setup"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        23)
            log_section "Création des symlinks"
            run_script "$SCRIPT_DIR/config/create_symlinks.sh" "Création symlinks"
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        99)
            log_section "ROLLBACK - Désinstallation complète"
            log_warn "⚠️  ATTENTION : Cette option va désinstaller TOUT"
            printf "Continuer avec le rollback? (tapez 'OUI' en majuscules): "
            read -r rollback_confirm
            if [ "$rollback_confirm" = "OUI" ]; then
                run_script "$SCRIPT_DIR/uninstall/rollback_all.sh" "Rollback complet"
            else
                log_info "Rollback annulé"
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        98)
            log_section "RÉINITIALISATION - Remise à zéro complète"
            log_warn "⚠️  ATTENTION : Cette option va TOUT désinstaller ET supprimer dotfiles"
            printf "Continuer avec la réinitialisation? (tapez 'OUI' en majuscules): "
            read -r reset_confirm
            if [ "$reset_confirm" = "OUI" ]; then
                run_script "$SCRIPT_DIR/uninstall/reset_all.sh" "Réinitialisation complète"
            else
                log_info "Réinitialisation annulée"
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        0)
            log_info "Au revoir!"
            exit 0
            ;;
        *)
            # Ce cas ne devrait jamais être atteint grâce à la validation avant
            log_error "Choix invalide: '$choice'"
            log_info "Veuillez entrer un nombre entre 0 et 23"
            sleep 2
            ;;
    esac
done
