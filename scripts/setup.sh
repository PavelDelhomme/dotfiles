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
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

################################################################################
# GESTION DE L'INTERRUPTION (Ctrl+C)
################################################################################
cleanup_on_interrupt() {
    echo ""
    echo ""
    log_warn "⚠️  Menu interrompu par l'utilisateur (Ctrl+C)"
    echo ""
    log_info "Vous pouvez relancer le menu avec :"
    echo "  cd ~/dotfiles && bash scripts/setup.sh"
    echo ""
    log_info "Ou utiliser le Makefile :"
    echo "  cd ~/dotfiles && make setup"
    echo ""
    exit 130  # Code de sortie standard pour SIGINT
}

# Capturer Ctrl+C (SIGINT) et SIGTERM
trap cleanup_on_interrupt SIGINT SIGTERM

DOTFILES_DIR="$HOME/dotfiles"
SCRIPT_DIR="$DOTFILES_DIR/scripts"

# Charger les bibliothèques
source "$SCRIPT_DIR/lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/lib/install_logger.sh" 2>/dev/null || {
    # Fallback si install_logger.sh n'existe pas
    log_install_action() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@" >> "$DOTFILES_DIR/install.log"
    }
}
source "$SCRIPT_DIR/lib/check_missing.sh" 2>/dev/null || true

################################################################################
# FONCTIONS UTILITAIRES
################################################################################
is_installed() {
    command -v "$1" >/dev/null 2>&1
}

is_package_installed() {
    pacman -Q "$1" >/dev/null 2>&1 2>/dev/null
}

################################################################################
# AFFICHAGE DE L'ÉTAT D'INSTALLATION
################################################################################
show_status() {
    echo ""
    log_section "État de l'installation"
    echo ""
    
    # Configuration Git
    if git config --global user.name &>/dev/null && git config --global user.email &>/dev/null; then
        GIT_NAME=$(git config --global user.name)
        GIT_EMAIL=$(git config --global user.email)
        log_info "✅ Git configuré: $GIT_NAME <$GIT_EMAIL>"
    else
        log_warn "❌ Git non configuré (option 1)"
    fi
    
    # Clé SSH
    if [ -f "$HOME/.ssh/id_ed25519" ] || [ -f "$HOME/.ssh/id_rsa" ]; then
        log_info "✅ Clé SSH présente"
    else
        log_warn "❌ Clé SSH absente (option 1)"
    fi
    
    # Outils de base
    echo ""
    echo "Outils de base:"
    TOOLS_BASE=("git" "curl" "wget" "zsh" "btop")
    for tool in "${TOOLS_BASE[@]}"; do
        if is_installed "$tool"; then
            echo "  ✅ $tool"
        else
            echo "  ❌ $tool (option 3)"
        fi
    done
    
    # Gestionnaires
    echo ""
    echo "Gestionnaires de paquets:"
    if is_installed "yay"; then
        echo "  ✅ yay"
    else
        echo "  ❌ yay (option 4 ou 18)"
    fi
    if is_installed "snap"; then
        echo "  ✅ snap"
    else
        echo "  ❌ snap (option 4)"
    fi
    if is_installed "flatpak"; then
        echo "  ✅ flatpak"
    else
        echo "  ❌ flatpak (option 4)"
    fi
    
    # Outils de développement
    echo ""
    echo "Outils de développement:"
    if is_installed "docker"; then
        DOCKER_VERSION=$(docker --version 2>/dev/null | head -n1)
        echo "  ✅ Docker: $DOCKER_VERSION"
    else
        echo "  ❌ Docker (option 15)"
    fi
    if is_installed "go"; then
        GO_VERSION=$(go version 2>/dev/null | head -n1)
        echo "  ✅ Go: $GO_VERSION"
    else
        echo "  ❌ Go (option 19)"
    fi
    
    # Applications
    echo ""
    echo "Applications:"
    if is_installed "cursor"; then
        echo "  ✅ Cursor IDE"
    else
        echo "  ❌ Cursor IDE (option 8)"
    fi
    if is_installed "brave-browser" || is_installed "brave"; then
        echo "  ✅ Brave Browser"
    else
        echo "  ❌ Brave Browser (option 17)"
    fi
    
    # Auto-sync Git
    echo ""
    if systemctl --user is-active dotfiles-sync.timer &>/dev/null; then
        log_info "✅ Auto-sync Git actif (option 12)"
    else
        log_warn "❌ Auto-sync Git inactif (option 12)"
    fi
    
    # Symlinks
    echo ""
    if [ -L "$HOME/.zshrc" ] && [[ $(readlink "$HOME/.zshrc") == *"dotfiles"* ]]; then
        log_info "✅ Symlinks configurés (option 23)"
    else
        log_warn "❌ Symlinks non configurés (option 23)"
    fi
    
    echo ""
    echo "─────────────────────────────────────────────────────────"
    echo ""
}

run_script() {
    local full_path="$1"
    local name="$2"
    
    # Logger le début de l'exécution
    log_install_action "run" "$name" "info" "Exécution: $full_path"
    
    # Séparer le script et les arguments si présents
    local script="${full_path%% *}"  # Prendre tout jusqu'au premier espace
    local args="${full_path#* }"      # Prendre tout après le premier espace
    
    # Si args est identique à full_path, il n'y a pas d'arguments
    if [ "$args" = "$full_path" ]; then
        args=""
    fi
    
    if [ -f "$script" ]; then
        log_info "Exécution: $name"
        # Ne pas faire échouer setup.sh si un script échoue (certains scripts peuvent avoir des erreurs non critiques)
        if [ -n "$args" ]; then
            bash "$script" $args && {
                log_install_action "run" "$name" "success" "Exécution réussie: $script $args"
            } || {
                log_error "Erreur lors de l'exécution de: $name"
                log_install_action "run" "$name" "failed" "Exécution échouée: $script $args"
                log_warn "Le script a rencontré une erreur, mais le menu continue"
                return 1
            }
        else
            bash "$script" && {
                log_install_action "run" "$name" "success" "Exécution réussie: $script"
            } || {
                log_error "Erreur lors de l'exécution de: $name"
                log_install_action "run" "$name" "failed" "Exécution échouée: $script"
                log_warn "Le script a rencontré une erreur, mais le menu continue"
                return 1
            }
        fi
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
    echo "10. Installation complète système (tout SAUF Git)"
    echo "11. Configuration complète QEMU (tout)"
    echo ""
    echo "12. Configuration auto-sync Git (systemd timer)"
    echo "13. Activer/Désactiver auto-sync Git"
    echo "14. Tester synchronisation manuellement"
    echo "15. Afficher statut auto-sync"
    echo ""
    echo "16. Installation Docker & Docker Compose"
    echo "17. Installation Docker Desktop (optionnel)"
    echo "18. Installation Brave Browser (optionnel)"
    echo "19. Installation yay (AUR - Arch Linux)"
    echo "20. Installation Go"
    echo "21. Installation NVM (Node Version Manager)"
    echo "22. Installation .NET SDK et outils"
    echo "23. Installation Flutter SDK"
    echo "24. Installation Emacs et Doom Emacs"
    echo "25. Installation Java 17 OpenJDK"
    echo ""
    echo "26. Recharger configuration ZSH"
    echo "27. Installer fonctions USB test"
    echo "28. Validation complète du setup (détaillé)"
    echo "29. Créer symlinks (centraliser configuration)"
    echo "30. Sauvegarde manuelle (commit + push Git)"
    echo "31. Restaurer depuis Git (annuler modifications locales)"
    echo ""
    echo "32. Migration shell (Fish <-> Zsh)"
    echo "33. Gestionnaire de shell (installer/configurer/définir zsh/fish/bash)"
    echo ""
    echo "════════════════════════════════════════════════"
    echo "INSTALLATION & DÉTECTION"
    echo "════════════════════════════════════════════════"
    echo "50. Afficher ce qui manque (état)"
    echo "51. Installer éléments manquants (un par un)"
    echo "52. Installer tout ce qui manque (automatique)"
    echo "53. Afficher logs d'installation"
    echo ""
    echo "════════════════════════════════════════════════"
    echo "DÉSINSTALLATION INDIVIDUELLE"
    echo "════════════════════════════════════════════════"
    echo "60. Désinstaller configuration Git"
    echo "61. Désinstaller configuration remote Git"
    echo "62. Désinstaller paquets de base"
    echo "63. Désinstaller gestionnaires de paquets (yay, snap, flatpak)"
    echo "64. Désinstaller Brave Browser"
    echo "65. Désinstaller Cursor IDE"
    echo "66. Désinstaller Docker & Docker Compose"
    echo "67. Désinstaller Go (Golang)"
    echo "68. Désinstaller yay (AUR helper)"
    echo "69. Désinstaller auto-sync Git"
    echo "70. Désinstaller symlinks"
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
# Afficher l'état au premier lancement
FIRST_RUN=true

while true; do
    # Afficher l'état uniquement au premier lancement
    if [ "$FIRST_RUN" = true ]; then
        show_status
        FIRST_RUN=false
    fi
    
    show_menu
    printf "Choix: "
    
    # Lire l'input de manière robuste - utiliser read avec timeout
    choice=""
    
    # Essayer de lire depuis le terminal
    # Utiliser read avec timeout pour éviter de bloquer indéfiniment
    if [ -t 0 ]; then
        # Terminal interactif - lire normalement
        IFS= read -r choice </dev/tty 2>/dev/null || IFS= read -r choice
    else
        # Pas de terminal - essayer stdin
        IFS= read -r choice 2>/dev/null || read -r choice
    fi
    
    # Nettoyer le choix : enlever les espaces en début/fin seulement
    if [ -n "$choice" ]; then
        choice=$(echo "$choice" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        # Si le choix contient des caractères non numériques, garder seulement les chiffres
        if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
            # Extraire seulement les chiffres
            choice=$(echo "$choice" | tr -cd '0-9' | head -c 10)
        fi
    fi
    
    # Si le choix est vide après nettoyage, afficher un message et continuer
    if [ -z "$choice" ]; then
        echo ""
        log_warn "⚠️  Choix vide ou invalide"
        log_info "💡 Entrez un nombre entre 0 et 99 (ex: 10 pour installation complète)"
        sleep 2
        continue
    fi
    
    # Vérifier que le choix est un nombre valide
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo ""
        log_error "Choix invalide: '$choice' (doit être un nombre)"
        log_info "Veuillez entrer un nombre entre 0 et 99"
        sleep 2
        continue
    fi
    
    case "$choice" in
        1)
            run_script "$SCRIPT_DIR/config/git_config.sh" "Configuration Git"
            # Si Ctrl+C a été pressé dans run_script, retourner au menu sans demander Entrée
            if [ $? -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "
            read -r dummy
            ;;
        2)
            run_script "$SCRIPT_DIR/config/git_remote.sh" "Configuration remote Git"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        3)
            run_script "$SCRIPT_DIR/install/system/packages_base.sh" "Paquets de base"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        4)
            run_script "$SCRIPT_DIR/install/system/package_managers.sh" "Gestionnaires de paquets"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        5)
            run_script "$SCRIPT_DIR/config/qemu_packages.sh" "Installation QEMU/KVM"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        6)
            run_script "$SCRIPT_DIR/config/qemu_network.sh" "Configuration réseau QEMU"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        7)
            run_script "$SCRIPT_DIR/config/qemu_libvirt.sh" "Configuration libvirt"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        8)
            run_script "$SCRIPT_DIR/install/apps/install_cursor.sh" "Installation Cursor"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        9)
            run_script "$SCRIPT_DIR/install/apps/install_portproton.sh" "Installation PortProton"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        10)
            log_section "Installation complète système (sans Git)"
            log_info "Cette option installe tous les composants SAUF la configuration Git"
            echo ""
            printf "Continuer avec l'installation complète? (o/n) [défaut: o]: "
            read -r confirm_install
            confirm_install=${confirm_install:-o}
            if [[ ! "$confirm_install" =~ ^[oO]$ ]]; then
                log_info "Installation annulée"
                continue
            fi
            
            run_script "$SCRIPT_DIR/install/system/packages_base.sh" "Paquets de base"
            run_script "$SCRIPT_DIR/install/system/package_managers.sh" "Gestionnaires"
            
            # Installer yay AVANT Docker Desktop (nécessaire pour Docker Desktop sur Arch)
            if [ -f /etc/arch-release ] && ! command -v yay &> /dev/null; then
                log_info "Installation de yay (nécessaire pour Docker Desktop)..."
                run_script "$SCRIPT_DIR/install/tools/install_yay.sh" "Installation yay"
            fi
            
            run_script "$SCRIPT_DIR/install/apps/install_cursor.sh" "Cursor"
            run_script "$SCRIPT_DIR/install/apps/install_portproton.sh" "PortProton"
            
            # Prompts pour installations optionnelles
            printf "Installer Docker? (o/n): "
            read -r install_docker
            if [[ "$install_docker" =~ ^[oO]$ ]]; then
                run_script "$SCRIPT_DIR/install/dev/install_docker.sh" "Docker"
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
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        11)
            log_section "Configuration complète QEMU"
            run_script "$SCRIPT_DIR/config/qemu_packages.sh" "Paquets QEMU"
            run_script "$SCRIPT_DIR/config/qemu_network.sh" "Réseau"
            run_script "$SCRIPT_DIR/config/qemu_libvirt.sh" "Libvirt"
            log_info "✓ Configuration QEMU complète terminée"
            log_warn "⚠ Déconnectez-vous et reconnectez-vous pour groupe libvirt"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        12)
            run_script "$SCRIPT_DIR/sync/install_auto_sync.sh" "Configuration auto-sync Git"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        13)
            log_section "Activer/Désactiver auto-sync Git"
            if systemctl --user is-active --quiet dotfiles-sync.timer 2>/dev/null; then
                log_info "Auto-sync Git est actuellement ACTIF"
                echo ""
                echo "1. Désactiver auto-sync"
                echo "2. Arrêter temporairement (démarre au reboot)"
                echo "0. Annuler"
                echo ""
                printf "Choix: "
                read -r sync_choice
                case "$sync_choice" in
                    1)
                        systemctl --user stop dotfiles-sync.timer
                        systemctl --user disable dotfiles-sync.timer
                        log_info "✓ Auto-sync désactivé"
                        ;;
                    2)
                        systemctl --user stop dotfiles-sync.timer
                        log_info "✓ Auto-sync arrêté (redémarrera au reboot)"
                        ;;
                    0)
                        log_info "Opération annulée"
                        ;;
                esac
            else
                log_warn "Auto-sync Git est actuellement INACTIF"
                echo ""
                echo "1. Activer auto-sync"
                echo "2. Installer et activer (si non installé)"
                echo "0. Annuler"
                echo ""
                printf "Choix: "
                read -r sync_choice
                case "$sync_choice" in
                    1)
                        if systemctl --user list-unit-files | grep -q "dotfiles-sync.timer"; then
                            systemctl --user start dotfiles-sync.timer
                            systemctl --user enable dotfiles-sync.timer
                            log_info "✓ Auto-sync activé"
                        else
                            log_error "Timer non installé, utilisez l'option 12 pour l'installer"
                        fi
                        ;;
                    2)
                        run_script "$SCRIPT_DIR/sync/install_auto_sync.sh" "Installation auto-sync Git"
                        ;;
                    0)
                        log_info "Opération annulée"
                        ;;
                esac
            fi
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        14)
            run_script "$SCRIPT_DIR/sync/git_auto_sync.sh" "Test synchronisation manuelle"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        15)
            log_section "Statut auto-sync"
            if systemctl --user is-active --quiet dotfiles-sync.timer 2>/dev/null; then
                log_info "✅ Timer actif"
                systemctl --user status dotfiles-sync.timer --no-pager -l
            elif systemctl --user is-enabled --quiet dotfiles-sync.timer 2>/dev/null; then
                log_warn "⚠️ Timer activé mais arrêté"
                systemctl --user status dotfiles-sync.timer --no-pager -l
            else
                log_warn "❌ Timer non configuré (option 12 pour installer)"
            fi
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        16)
            run_script "$SCRIPT_DIR/install/dev/install_docker.sh" "Installation Docker & Docker Compose"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        16)
            run_script "$SCRIPT_DIR/install/dev/install_docker.sh --desktop-only" "Installation Docker Desktop"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        17)
            run_script "$SCRIPT_DIR/install/apps/install_brave.sh" "Installation Brave Browser"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        18)
            run_script "$SCRIPT_DIR/install/tools/install_yay.sh" "Installation yay (AUR)"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        20)
            run_script "$SCRIPT_DIR/install/dev/install_go.sh" "Installation Go"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        21)
            run_script "$SCRIPT_DIR/install/tools/install_nvm.sh" "Installation NVM"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        22)
            run_script "$SCRIPT_DIR/install/dev/install_dotnet.sh" "Installation .NET SDK"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        23)
            run_script "$SCRIPT_DIR/install/dev/install_flutter.sh" "Installation Flutter SDK"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        24)
            run_script "$SCRIPT_DIR/install/dev/install_emacs.sh" "Installation Emacs"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        25)
            run_script "$SCRIPT_DIR/install/dev/install_java17.sh" "Installation Java 17 OpenJDK"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        26)
            log_section "Rechargement configuration ZSH"
            log_info "Rechargement de la configuration ZSH..."
            exec zsh
            ;;
        27)
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
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        28)
            run_script "$SCRIPT_DIR/test/validate_setup.sh" "Validation complète du setup"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        29)
            log_section "Création des symlinks"
            run_script "$SCRIPT_DIR/config/create_symlinks.sh" "Création symlinks"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        30)
            log_section "Sauvegarde manuelle (Git commit + push)"
            if [ -d "$DOTFILES_DIR/.git" ]; then
                cd "$DOTFILES_DIR" || exit 1
                if [ -n "$(git status --porcelain)" ]; then
                    log_info "Modifications détectées, ajout au commit..."
                    git add -A
                    COMMIT_MSG="Manual backup: $(date '+%Y-%m-%d %H:%M:%S')"
                    if git commit -m "$COMMIT_MSG"; then
                        log_info "✓ Commit créé: $COMMIT_MSG"
                        if git push origin main 2>/dev/null || git push origin master 2>/dev/null; then
                            log_info "✓ Push réussi vers GitHub"
                        else
                            log_warn "⚠️ Push échoué (vérifiez votre connexion)"
                        fi
                    else
                        log_warn "⚠️ Aucun changement à committer"
                    fi
                else
                    log_info "✓ Aucune modification à sauvegarder"
                fi
            else
                log_error "Ce n'est pas un dépôt Git!"
            fi
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        31)
            log_section "Restaurer depuis Git"
            echo ""
            echo "Cette option permet de restaurer l'état du repo depuis GitHub"
            echo "et d'annuler toutes les modifications locales."
            echo ""
            echo "1. Restaurer tous les fichiers modifiés"
            echo "2. Restaurer un fichier spécifique (ex: zsh/path_log.txt)"
            echo "3. Reset hard vers origin/main (ATTENTION: supprime tout)"
            echo "0. Annuler"
            echo ""
            printf "Choix: "
            read -r restore_choice
            case "$restore_choice" in
                1)
                    run_script "$SCRIPT_DIR/sync/restore_from_git.sh" "Restauration depuis Git"
                    ;;
                2)
                    echo ""
                    printf "Chemin du fichier à restaurer (ex: zsh/path_log.txt): "
                    read -r file_path
                    if [[ -n "$file_path" ]]; then
                        run_script "$SCRIPT_DIR/sync/restore_from_git.sh $file_path" "Restauration fichier: $file_path"
                    else
                        log_warn "Chemin non fourni"
                    fi
                    ;;
                3)
                    log_warn "⚠️  ATTENTION: Cette opération va supprimer TOUTES les modifications locales"
                    printf "Confirmer reset hard? (tapez 'OUI' en majuscules): "
                    read -r confirm_reset
                    if [ "$confirm_reset" = "OUI" ]; then
                        run_script "$SCRIPT_DIR/sync/restore_from_git.sh" "Reset hard Git"
                    else
                        log_info "Reset hard annulé"
                    fi
                    ;;
                0)
                    log_info "Opération annulée"
                    ;;
                *)
                    log_error "Choix invalide"
                    ;;
            esac
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        32)
            log_section "Migration shell (Fish <-> Zsh)"
            run_script "$SCRIPT_DIR/migrate_shell.sh" "Migration shell"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        33)
            run_script "$SCRIPT_DIR/config/shell_manager.sh" "Gestionnaire de shell" "menu"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        29)
            # Option 29 conservée pour compatibilité (redirige vers shell_manager)
            run_script "$SCRIPT_DIR/config/shell_manager.sh" "Gestionnaire de shell" "menu"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        50)
            log_section "État des composants manquants"
            show_missing_components
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        51)
            log_section "Installation éléments manquants (un par un)"
            detect_missing_components
            
            if [ ${#MISSING_ITEMS[@]} -eq 0 ]; then
                log_info "✅ Tous les composants sont installés!"
                run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
                continue
            fi
            
            log_info "${#MISSING_ITEMS[@]} élément(s) manquant(s) détecté(s)"
            echo ""
            
            local index=1
            for item in "${MISSING_ITEMS[@]}"; do
                IFS=':' read -r type name action <<< "$item"
                echo "$index. $name ($action)"
                ((index++))
            done
            echo "0. Retour au menu principal"
            echo ""
            printf "Choisir un élément à installer [1-${#MISSING_ITEMS[@]}]: "
            read -r choice
            
            if [ "$choice" = "0" ] || [ -z "$choice" ]; then
                log_info "Retour au menu principal"
                run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
                continue
            fi
            
            if [ "$choice" -ge 1 ] && [ "$choice" -le ${#MISSING_ITEMS[@]} ]; then
                selected_item="${MISSING_ITEMS[$((choice-1))]}"
                IFS=':' read -r type name action <<< "$selected_item"
                
                log_info "Installation: $name (via $action)"
                log_install_action "install" "$name" "info" "Début installation via menu"
                
                case "$action" in
                    install_base_packages)
                        run_script "$SCRIPT_DIR/install/system/packages_base.sh" "Paquets de base"
                        if [ $? -eq 0 ]; then
                            log_install_action "install" "$name" "success" "Installation via packages_base.sh"
                        else
                            log_install_action "install" "$name" "failed" "Échec installation"
                        fi
                        ;;
                    install_yay)
                        run_script "$SCRIPT_DIR/install/tools/install_yay.sh" "yay"
                        if [ $? -eq 0 ]; then
                            log_install_action "install" "$name" "success" "Installation via install_yay.sh"
                        else
                            log_install_action "install" "$name" "failed" "Échec installation"
                        fi
                        ;;
                    install_package_managers)
                        run_script "$SCRIPT_DIR/install/system/package_managers.sh" "Gestionnaires"
                        if [ $? -eq 0 ]; then
                            log_install_action "install" "$name" "success" "Installation via package_managers.sh"
                        else
                            log_install_action "install" "$name" "failed" "Échec installation"
                        fi
                        ;;
                    install_cursor)
                        run_script "$SCRIPT_DIR/install/apps/install_cursor.sh" "Cursor"
                        if [ $? -eq 0 ]; then
                            log_install_action "install" "$name" "success" "Installation via install_cursor.sh"
                        else
                            log_install_action "install" "$name" "failed" "Échec installation"
                        fi
                        ;;
                    install_brave)
                        run_script "$SCRIPT_DIR/install/apps/install_brave.sh" "Brave"
                        if [ $? -eq 0 ]; then
                            log_install_action "install" "$name" "success" "Installation via install_brave.sh"
                        else
                            log_install_action "install" "$name" "failed" "Échec installation"
                        fi
                        ;;
                    install_docker)
                        run_script "$SCRIPT_DIR/install/dev/install_docker.sh" "Docker"
                        if [ $? -eq 0 ]; then
                            log_install_action "install" "$name" "success" "Installation via install_docker.sh"
                        else
                            log_install_action "install" "$name" "failed" "Échec installation"
                        fi
                        ;;
                    install_go)
                        run_script "$SCRIPT_DIR/install/dev/install_go.sh" "Go"
                        if [ $? -eq 0 ]; then
                            log_install_action "install" "$name" "success" "Installation via install_go.sh"
                        else
                            log_install_action "install" "$name" "failed" "Échec installation"
                        fi
                        ;;
                    config_git)
                        run_script "$SCRIPT_DIR/config/git_config.sh" "Configuration Git"
                        if [ $? -eq 0 ]; then
                            log_install_action "config" "$name" "success" "Configuration via git_config.sh"
                        else
                            log_install_action "config" "$name" "failed" "Échec configuration"
                        fi
                        ;;
                    config_git_remote)
                        run_script "$SCRIPT_DIR/config/git_remote.sh" "Remote Git"
                        if [ $? -eq 0 ]; then
                            log_install_action "config" "$name" "success" "Configuration via git_remote.sh"
                        else
                            log_install_action "config" "$name" "failed" "Échec configuration"
                        fi
                        ;;
                    install_auto_sync)
                        run_script "$SCRIPT_DIR/sync/install_auto_sync.sh" "Auto-sync Git"
                        if [ $? -eq 0 ]; then
                            log_install_action "install" "$name" "success" "Installation via install_auto_sync.sh"
                        else
                            log_install_action "install" "$name" "failed" "Échec installation"
                        fi
                        ;;
                    create_symlinks)
                        run_script "$SCRIPT_DIR/config/create_symlinks.sh" "Symlinks"
                        if [ $? -eq 0 ]; then
                            log_install_action "config" "$name" "success" "Création via create_symlinks.sh"
                        else
                            log_install_action "config" "$name" "failed" "Échec création"
                        fi
                        ;;
                    *)
                        log_warn "Action non reconnue: $action"
                        log_install_action "install" "$name" "failed" "Action inconnue: $action"
                        ;;
                esac
            else
                log_error "Choix invalide"
            fi
            
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        52)
            log_section "INSTALLER TOUT CE QUI MANQUE (automatique)"
            log_warn "⚠️  Cette opération va installer tous les composants manquants automatiquement"
            printf "Continuer? (o/n): "
            read -r confirm
            if [[ ! "$confirm" =~ ^[oO]$ ]]; then
                log_info "Installation annulée"
                run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
                continue
            fi
            
            log_install_action "install" "auto_all" "info" "Début installation automatique de tous les composants"
            log_info "Installation automatique des composants manquants..."
            echo ""
            
            # Paquets de base
            if ! command -v git &> /dev/null || ! command -v curl &> /dev/null || ! command -v zsh &> /dev/null; then
                log_info "Installation des paquets de base..."
                run_script "$SCRIPT_DIR/install/system/packages_base.sh" "Paquets de base"
                if [ $? -eq 0 ]; then
                    log_install_action "install" "packages_base" "success" "Installation automatique via packages_base.sh"
                else
                    log_install_action "install" "packages_base" "failed" "Échec installation automatique"
                fi
            else
                log_install_action "install" "packages_base" "skipped" "Déjà installés"
            fi
            
            # Gestionnaires
            if [ -f /etc/arch-release ] && ! command -v yay &> /dev/null; then
                log_info "Installation de yay..."
                run_script "$SCRIPT_DIR/install/tools/install_yay.sh" "yay"
                if [ $? -eq 0 ]; then
                    log_install_action "install" "yay" "success" "Installation automatique via install_yay.sh"
                else
                    log_install_action "install" "yay" "failed" "Échec installation automatique"
                fi
            else
                log_install_action "install" "yay" "skipped" "Non requis ou déjà installé"
            fi
            
            # Applications
            if ! command -v cursor &> /dev/null && [ ! -f /opt/cursor.appimage ]; then
                log_info "Installation de Cursor..."
                run_script "$SCRIPT_DIR/install/apps/install_cursor.sh" "Cursor"
                if [ $? -eq 0 ]; then
                    log_install_action "install" "cursor" "success" "Installation automatique via install_cursor.sh"
                else
                    log_install_action "install" "cursor" "failed" "Échec installation automatique"
                fi
            else
                log_install_action "install" "cursor" "skipped" "Déjà installé"
            fi
            
            if ! command -v docker &> /dev/null; then
                log_info "Installation de Docker..."
                run_script "$SCRIPT_DIR/install/dev/install_docker.sh" "Docker"
                if [ $? -eq 0 ]; then
                    log_install_action "install" "docker" "success" "Installation automatique via install_docker.sh"
                else
                    log_install_action "install" "docker" "failed" "Échec installation automatique"
                fi
            else
                log_install_action "install" "docker" "skipped" "Déjà installé"
            fi
            
            if ! command -v go &> /dev/null; then
                log_info "Installation de Go..."
                run_script "$SCRIPT_DIR/install/dev/install_go.sh" "Go"
                if [ $? -eq 0 ]; then
                    log_install_action "install" "go" "success" "Installation automatique via install_go.sh"
                else
                    log_install_action "install" "go" "failed" "Échec installation automatique"
                fi
            else
                log_install_action "install" "go" "skipped" "Déjà installé"
            fi
            
            # Auto-sync
            if ! systemctl --user is-active --quiet dotfiles-sync.timer 2>/dev/null; then
                log_info "Installation de l'auto-sync Git..."
                run_script "$SCRIPT_DIR/sync/install_auto_sync.sh" "Auto-sync Git"
                if [ $? -eq 0 ]; then
                    log_install_action "install" "auto_sync" "success" "Installation automatique via install_auto_sync.sh"
                else
                    log_install_action "install" "auto_sync" "failed" "Échec installation automatique"
                fi
            else
                log_install_action "install" "auto_sync" "skipped" "Déjà configuré"
            fi
            
            # Symlinks
            if [ ! -L "$HOME/.zshrc" ] || [[ $(readlink "$HOME/.zshrc") != *"dotfiles"* ]]; then
                log_info "Création des symlinks..."
                run_script "$SCRIPT_DIR/config/create_symlinks.sh" "Symlinks"
                if [ $? -eq 0 ]; then
                    log_install_action "config" "symlinks" "success" "Création automatique via create_symlinks.sh"
                else
                    log_install_action "config" "symlinks" "failed" "Échec création automatique"
                fi
            else
                log_install_action "config" "symlinks" "skipped" "Déjà créés"
            fi
            
            log_info "✓ Installation automatique terminée"
            log_install_action "install" "auto_all" "success" "Installation automatique terminée"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        53)
            log_section "Logs d'installation"
            if [ -f "$DOTFILES_DIR/install.log" ]; then
                echo ""
                echo "Options d'affichage:"
                echo "1. Dernières 50 lignes"
                echo "2. Dernières 100 lignes"
                echo "3. Toutes les lignes"
                echo "4. Filtrer par action (install, config, uninstall, etc.)"
                echo "5. Filtrer par composant"
                echo "6. Résumé (statistiques)"
                echo "0. Retour"
                echo ""
                printf "Choix: "
                read -r log_choice
                
                case "$log_choice" in
                    1)
                        tail -50 "$DOTFILES_DIR/install.log" | less -R
                        ;;
                    2)
                        tail -100 "$DOTFILES_DIR/install.log" | less -R
                        ;;
                    3)
                        less -R "$DOTFILES_DIR/install.log"
                        ;;
                    4)
                        printf "Action à filtrer (install/config/uninstall/test): "
                        read -r filter_action
                        grep -i "\[$filter_action\]" "$DOTFILES_DIR/install.log" | less -R
                        ;;
                    5)
                        printf "Composant à filtrer: "
                        read -r filter_component
                        grep -i "$filter_component" "$DOTFILES_DIR/install.log" | less -R
                        ;;
                    6)
                        if command -v get_install_summary &> /dev/null; then
                            get_install_summary
                        else
                            total=$(wc -l < "$DOTFILES_DIR/install.log" 2>/dev/null || echo "0")
                            success=$(grep -c "\[success\]" "$DOTFILES_DIR/install.log" 2>/dev/null || echo "0")
                            failed=$(grep -c "\[failed\]" "$DOTFILES_DIR/install.log" 2>/dev/null || echo "0")
                            skipped=$(grep -c "\[skipped\]" "$DOTFILES_DIR/install.log" 2>/dev/null || echo "0")
                            echo "Résumé des installations:"
                            echo "  Total d'actions: $total"
                            echo "  Réussies: $success"
                            echo "  Échouées: $failed"
                            echo "  Ignorées: $skipped"
                        fi
                        ;;
                    0)
                        log_info "Retour au menu"
                        ;;
                    *)
                        log_error "Choix invalide"
                        ;;
                esac
            else
                log_warn "Aucun log d'installation trouvé"
            fi
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        60)
            run_script "$SCRIPT_DIR/uninstall/uninstall_git_config.sh" "Désinstallation configuration Git"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        61)
            run_script "$SCRIPT_DIR/uninstall/uninstall_git_remote.sh" "Désinstallation configuration remote Git"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        62)
            run_script "$SCRIPT_DIR/uninstall/uninstall_base_packages.sh" "Désinstallation paquets de base"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        63)
            run_script "$SCRIPT_DIR/uninstall/uninstall_package_managers.sh" "Désinstallation gestionnaires de paquets"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        64)
            run_script "$SCRIPT_DIR/uninstall/uninstall_brave.sh" "Désinstallation Brave Browser"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        65)
            run_script "$SCRIPT_DIR/uninstall/uninstall_cursor.sh" "Désinstallation Cursor IDE"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        66)
            run_script "$SCRIPT_DIR/uninstall/uninstall_docker.sh" "Désinstallation Docker"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        67)
            run_script "$SCRIPT_DIR/uninstall/uninstall_go.sh" "Désinstallation Go"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        68)
            run_script "$SCRIPT_DIR/uninstall/uninstall_yay.sh" "Désinstallation yay"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        69)
            run_script "$SCRIPT_DIR/uninstall/uninstall_auto_sync.sh" "Désinstallation auto-sync Git"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
            printf "\nAppuyez sur Entrée pour continuer... "; read -r dummy
            ;;
        70)
            run_script "$SCRIPT_DIR/uninstall/uninstall_symlinks.sh" "Désinstallation symlinks"
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
            fi
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
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
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
            run_script_exit_code=$?
            if [ $run_script_exit_code -eq 130 ]; then
                continue
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
            log_info "Veuillez entrer un nombre valide (0-27, 28, 50-53, 60-70, 98-99)"
            sleep 2
            ;;
    esac
done
