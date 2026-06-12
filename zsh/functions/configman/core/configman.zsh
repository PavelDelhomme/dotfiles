#!/bin/zsh
# =============================================================================
# CONFIGMAN - Configuration Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet des configurations système
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoires de base (globaux pour être accessibles partout)
CONFIGMAN_DIR="${CONFIGMAN_DIR:-$HOME/dotfiles/zsh/functions/configman}"

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

# Charger le gestionnaire de versions
[ -f "$CONFIGMAN_DIR/utils/version_manager.sh" ] && source "$CONFIGMAN_DIR/utils/version_manager.sh"

# Log commun des managers (optionnel)
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
[ -f "$DOTFILES_DIR/scripts/lib/managers_log.sh" ] && source "$DOTFILES_DIR/scripts/lib/managers_log.sh"

# DESC: Gestionnaire interactif complet pour les configurations système
# USAGE: configman [category]
# EXAMPLE: configman
# EXAMPLE: configman git
# EXAMPLE: configman qemu
configman() {
    # Variables locales pour éviter les modifications par les scripts enfants
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local MAGENTA='\033[0;35m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    # Répertoires de base (toujours réinitialisés)
    local CONFIGMAN_DIR="${CONFIGMAN_DIR:-$HOME/dotfiles/zsh/functions/configman}"
    local CONFIGMAN_MODULES_DIR="$CONFIGMAN_DIR/modules"
    
    # Fonction pour afficher le header
    show_header() {
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                  CONFIGMAN - CONFIGURATION MANAGER             ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
    }
    
    # Fonction pour afficher la vue d'ensemble de la configuration
    show_config_overview() {
        show_header
        echo -e "${YELLOW}👁️  VUE D'ENSEMBLE DE LA CONFIGURATION${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        # Versions des outils
        echo -e "${BOLD}📊 Versions des outils:${RESET}"
        echo -e "  Node.js:   ${GREEN}$(get_current_node_version 2>/dev/null || echo "N/A")${RESET}"
        echo -e "  Python:    ${GREEN}$(get_current_python_version 2>/dev/null || echo "N/A")${RESET}"
        echo -e "  Java:      ${GREEN}$(get_current_java_version 2>/dev/null || echo "N/A")${RESET}"
        echo ""
        
        # Configuration Git
        echo -e "${BOLD}🔧 Configuration Git:${RESET}"
        if command -v git &>/dev/null; then
            echo -e "  Nom:       ${GREEN}$(git config --global user.name 2>/dev/null || echo "Non configuré")${RESET}"
            echo -e "  Email:     ${GREEN}$(git config --global user.email 2>/dev/null || echo "Non configuré")${RESET}"
            echo -e "  Remote:    ${GREEN}$(git config --global remote.origin.url 2>/dev/null || echo "Non configuré")${RESET}"
        else
            echo -e "  ${YELLOW}Git non installé${RESET}"
        fi
        echo ""
        
        # Gestionnaires de paquets
        echo -e "${BOLD}📦 Gestionnaires de paquets:${RESET}"
        local managers=()
        command -v pacman &>/dev/null && managers+=("pacman")
        command -v yay &>/dev/null && managers+=("yay")
        command -v snap &>/dev/null && managers+=("snap")
        command -v flatpak &>/dev/null && managers+=("flatpak")
        command -v apt &>/dev/null && managers+=("apt")
        command -v dnf &>/dev/null && managers+=("dnf")
        command -v npm &>/dev/null && managers+=("npm")
        if [ ${#managers[@]} -gt 0 ]; then
            echo -e "  Disponibles: ${GREEN}${managers[*]}${RESET}"
        else
            echo -e "  ${YELLOW}Aucun gestionnaire détecté${RESET}"
        fi
        echo ""
        
        # Outils installés via installman
        echo -e "${BOLD}🛠️  Outils installés:${RESET}"
        local tools_installed=()
        command -v flutter &>/dev/null && tools_installed+=("Flutter")
        command -v dotnet &>/dev/null && tools_installed+=(".NET")
        command -v docker &>/dev/null && tools_installed+=("Docker")
        command -v emacs &>/dev/null && tools_installed+=("Emacs")
        command -v java &>/dev/null && tools_installed+=("Java")
        if [ ${#tools_installed[@]} -gt 0 ]; then
            echo -e "  ${GREEN}${tools_installed[*]}${RESET}"
        else
            echo -e "  ${YELLOW}Aucun outil détecté${RESET}"
        fi
        echo ""
        
        # Shells disponibles
        echo -e "${BOLD}🐚 Shells disponibles:${RESET}"
        local shells=()
        command -v zsh &>/dev/null && shells+=("zsh")
        command -v bash &>/dev/null && shells+=("bash")
        command -v fish &>/dev/null && shells+=("fish")
        echo -e "  ${GREEN}${shells[*]}${RESET}"
        echo -e "  Shell actuel: ${GREEN}${SHELL:-$0}${RESET}"
        echo ""
        
        # Configuration SSH
        echo -e "${BOLD}🔐 Configuration SSH:${RESET}"
        if [ -f ~/.ssh/id_ed25519 ] || [ -f ~/.ssh/id_rsa ]; then
            echo -e "  ${GREEN}Clés SSH présentes${RESET}"
        else
            echo -e "  ${YELLOW}Aucune clé SSH trouvée${RESET}"
        fi
        echo ""
        
        read -p "Appuyez sur Entrée pour continuer..."
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
        echo "6.  🔐 SSH (configuration connexion SSH interactive)"
        echo "6a. 🔐 SSH Auto (configuration automatique avec mot de passe .env)"
        echo "7.  🖥️  QEMU Libvirt (permissions libvirt)"
        echo "8.  🌐 QEMU Network (configuration réseau NAT)"
        echo "9.  📦 QEMU Packages (installation paquets QEMU)"
        echo "10. 🔍 OSINT Tools (configuration outils OSINT et clés API)"
        echo "11. 📊 Gestion de versions (Node, Python, Java)"
        echo "12. 👁️  Visualisation de configuration complète"
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
                if [ -f "$CONFIGMAN_MODULES_DIR/ssh/ssh_config.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/ssh/ssh_config.sh"
                else
                    echo -e "${RED}❌ Module SSH non disponible${RESET}"
                    sleep 2
                fi
                ;;
            6a)
                if [ -f "$CONFIGMAN_MODULES_DIR/ssh/ssh_auto_setup.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/ssh/ssh_auto_setup.sh"
                else
                    echo -e "${RED}❌ Module SSH Auto non disponible${RESET}"
                    sleep 2
                fi
                ;;
            7)
                if [ -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_libvirt.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_libvirt.sh"
                else
                    echo -e "${RED}❌ Module QEMU Libvirt non disponible${RESET}"
                    sleep 2
                fi
                ;;
            8)
                if [ -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_network.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_network.sh"
                else
                    echo -e "${RED}❌ Module QEMU Network non disponible${RESET}"
                    sleep 2
                fi
                ;;
            9)
                if [ -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_packages.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_packages.sh"
                else
                    echo -e "${RED}❌ Module QEMU Packages non disponible${RESET}"
                    sleep 2
                fi
                ;;
            10)
                if [ -f "$CONFIGMAN_MODULES_DIR/osint/osint_config.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/osint/osint_config.sh"
                else
                    echo -e "${RED}❌ Module OSINT Config non disponible${RESET}"
                    sleep 2
                fi
                ;;
            11)
                version_manager_menu
                ;;
            12)
                show_config_overview
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${RED}Choix invalide${RESET}"
                sleep 1
                ;;
        esac
        
        # Retourner au menu après action (sauf si choix 0)
        if [ "$choice" != "0" ]; then
            echo ""
            read -k 1 "?Appuyez sur une touche pour continuer... "
            configman
        fi
    }
    
    # Si un argument est fourni, lancer directement le module
    if [ -n "$1" ]; then
        # Réinitialiser CONFIGMAN_MODULES_DIR (variable locale, pas exportée)
        CONFIGMAN_MODULES_DIR="$CONFIGMAN_DIR/modules"
        type log_manager_action &>/dev/null && log_manager_action "configman" "run" "$1" "start" ""

        case "$1" in
            apply|reapply|bootstrap|converge)
                if [ -f "$DOTFILES_DIR/scripts/bootstrap/apply_dotfiles.sh" ]; then
                    shift
                    bash "$DOTFILES_DIR/scripts/bootstrap/apply_dotfiles.sh" "$@"
                else
                    echo -e "${RED}❌ Script apply dotfiles non disponible${RESET}"
                    return 1
                fi
                ;;
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
            ssh)
                if [ -f "$CONFIGMAN_MODULES_DIR/ssh/ssh_config.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/ssh/ssh_config.sh"
                fi
                ;;
            ssh-auto|sshauto)
                if [ -f "$CONFIGMAN_MODULES_DIR/ssh/ssh_auto_setup.sh" ]; then
                    bash "$CONFIGMAN_MODULES_DIR/ssh/ssh_auto_setup.sh" "$2" "$3" "$4" "$5"
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
            osint|osint-config)
                # S'assurer que CONFIGMAN_MODULES_DIR est correct
                CONFIGMAN_MODULES_DIR="$CONFIGMAN_DIR/modules"
                local osint_script="$CONFIGMAN_MODULES_DIR/osint/osint_config.sh"
                if [ -f "$osint_script" ]; then
                    bash "$osint_script"
                else
                    echo -e "${RED}❌ Module OSINT non disponible${RESET}"
                    echo -e "${YELLOW}Fichier attendu: $osint_script${RESET}"
                    echo -e "${CYAN}CONFIGMAN_DIR: $CONFIGMAN_DIR${RESET}"
                    echo -e "${CYAN}CONFIGMAN_MODULES_DIR: $CONFIGMAN_MODULES_DIR${RESET}"
                    ls -la "$CONFIGMAN_MODULES_DIR" 2>/dev/null || echo "Répertoire modules n'existe pas"
                    return 1
                fi
                ;;
            *)
                echo -e "${RED}Module inconnu: $1${RESET}"
                echo ""
                echo "Modules disponibles:"
                echo "  - apply (réappliquer shell/prompt dotfiles)"
                echo "  - git"
                echo "  - git-remote"
                echo "  - symlinks"
                echo "  - shell"
                echo "  - p10k (Powerlevel10k)"
                echo "  - ssh (configuration SSH interactive)"
                echo "  - ssh-auto (configuration SSH automatique avec .env)"
                echo "  - qemu-libvirt"
                echo "  - qemu-network"
                echo "  - qemu-packages"
                echo "  - osint (configuration outils OSINT et clés API)"
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
alias dotfilesman='configman'
# dfm est reserve a dotfiles_menu_run (menus declaratifs share/menus).
# Garder configman via cm/config/dotfilesman.

# Message d'initialisation - désactivé pour éviter l'avertissement Powerlevel10k
# echo "⚙️  CONFIGMAN chargé - Tapez 'configman' ou 'cm' pour démarrer"

