#!/bin/zsh
# =============================================================================
# CONFIGMAN - Configuration Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet des configurations système
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoires de base
CONFIGMAN_DIR="${CONFIGMAN_DIR:-$HOME/dotfiles/zsh/functions/configman}"
CONFIGMAN_MODULES_DIR="$CONFIGMAN_DIR/modules"

# Charger les utilitaires (seulement si le répertoire existe et contient des fichiers)
if [ -d "$CONFIGMAN_DIR/utils" ]; then
    # Vérifier s'il y a des fichiers .sh avant de boucler
    shopt -s nullglob 2>/dev/null || setopt null_glob 2>/dev/null || true
    for util_file in "$CONFIGMAN_DIR/utils"/*.sh; do
        if [ -f "$util_file" ]; then
            source "$util_file" 2>/dev/null || true
        fi
    done
    shopt -u nullglob 2>/dev/null || unsetopt null_glob 2>/dev/null || true
fi

# DESC: Gestionnaire interactif complet pour les configurations système
# USAGE: configman [category]
# EXAMPLE: configman
# EXAMPLE: configman git
# EXAMPLE: configman qemu
configman() {
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
        echo "║                  CONFIGMAN - CONFIGURATION MANAGER             ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        echo -e "${YELLOW}⚙️  CONFIGURATIONS SYSTÈME${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        echo "1.  📦 Git (configuration Git globale)"
        echo "2.  🔗 Git Remote (configuration remote GitHub)"
        echo "3.  🔗 Symlinks (création des symlinks dotfiles)"
        echo "4.  🐚 Shell (gestion des shells)"
        echo "5.  🎨 Powerlevel10k (configuration prompt avec Git)"
        echo "6.  🖥️  QEMU Libvirt (permissions libvirt)"
        echo "7.  🌐 QEMU Network (configuration réseau NAT)"
        echo "8.  📦 QEMU Packages (installation paquets QEMU)"
        echo ""
        echo "0.  Quitter"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                if [ -f "$CONFIGMAN_MODULES_DIR/git/git_config.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/git/git_config.sh"
                else
                    echo -e "${RED}❌ Module Git non disponible${RESET}"
                    sleep 2
                fi
                ;;
            2)
                if [ -f "$CONFIGMAN_MODULES_DIR/git/git_remote.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/git/git_remote.sh"
                else
                    echo -e "${RED}❌ Module Git Remote non disponible${RESET}"
                    sleep 2
                fi
                ;;
            3)
                if [ -f "$CONFIGMAN_MODULES_DIR/symlinks/create_symlinks.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/symlinks/create_symlinks.sh"
                else
                    echo -e "${RED}❌ Module Symlinks non disponible${RESET}"
                    sleep 2
                fi
                ;;
            4)
                if [ -f "$CONFIGMAN_MODULES_DIR/shell/shell_manager.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/shell/shell_manager.sh" menu
                else
                    echo -e "${RED}❌ Module Shell non disponible${RESET}"
                    sleep 2
                fi
                ;;
            5)
                if [ -f "$CONFIGMAN_MODULES_DIR/prompt/p10k_config.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/prompt/p10k_config.sh"
                else
                    echo -e "${RED}❌ Module Powerlevel10k non disponible${RESET}"
                    sleep 2
                fi
                ;;
            6)
                if [ -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_libvirt.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_libvirt.sh"
                else
                    echo -e "${RED}❌ Module QEMU Libvirt non disponible${RESET}"
                    sleep 2
                fi
                ;;
            7)
                if [ -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_network.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_network.sh"
                else
                    echo -e "${RED}❌ Module QEMU Network non disponible${RESET}"
                    sleep 2
                fi
                ;;
            8)
                if [ -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_packages.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_packages.sh"
                else
                    echo -e "${RED}❌ Module QEMU Packages non disponible${RESET}"
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
        configman
    }
    
    # Si un argument est fourni, lancer directement le module
    if [ -n "$1" ]; then
        case "$1" in
            git)
                if [ -f "$CONFIGMAN_MODULES_DIR/git/git_config.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/git/git_config.sh"
                fi
                ;;
            git-remote|gitremote)
                if [ -f "$CONFIGMAN_MODULES_DIR/git/git_remote.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/git/git_remote.sh"
                fi
                ;;
            symlinks|symlink)
                if [ -f "$CONFIGMAN_MODULES_DIR/symlinks/create_symlinks.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/symlinks/create_symlinks.sh"
                fi
                ;;
            shell)
                if [ -f "$CONFIGMAN_MODULES_DIR/shell/shell_manager.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/shell/shell_manager.sh" menu
                fi
                ;;
            p10k|powerlevel10k|prompt)
                if [ -f "$CONFIGMAN_MODULES_DIR/prompt/p10k_config.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/prompt/p10k_config.sh"
                fi
                ;;
            qemu-libvirt|qemulibvirt)
                if [ -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_libvirt.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_libvirt.sh"
                fi
                ;;
            qemu-network|qemunetwork)
                if [ -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_network.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_network.sh"
                fi
                ;;
            qemu-packages|qemupackages)
                if [ -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_packages.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_packages.sh"
                fi
                ;;
            *)
                echo -e "${RED}Module inconnu: $1${RESET}"
                echo ""
                echo "Modules disponibles:"
                echo "  - git"
                echo "  - git-remote"
                echo "  - symlinks"
                echo "  - shell"
                echo "  - p10k (Powerlevel10k)"
                echo "  - qemu-libvirt"
                echo "  - qemu-network"
                echo "  - qemu-packages"
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

# Alias
alias cm='configman'
alias config='configman'

