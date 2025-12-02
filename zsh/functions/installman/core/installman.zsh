#!/bin/zsh
# =============================================================================
# INSTALLMAN - Installation Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet des installations d'outils de développement
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoires de base
INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_MODULES_DIR="$INSTALLMAN_DIR/modules"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"

# Chemins
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"
INSTALL_DIR="$SCRIPTS_DIR/install/dev"
ENV_FILE="$DOTFILES_DIR/zsh/env.sh"

# Charger les utilitaires
if [ -d "$INSTALLMAN_UTILS_DIR" ]; then
    for util_file in "$INSTALLMAN_UTILS_DIR"/*.sh; do
        [ -f "$util_file" ] && source "$util_file" 2>/dev/null || true
    done
fi

# Charger les fonctions de vérification
[ -f "$INSTALLMAN_UTILS_DIR/check_installed.sh" ] && source "$INSTALLMAN_UTILS_DIR/check_installed.sh"

# DESC: Gestionnaire interactif complet pour installer des outils de développement
# USAGE: installman [tool-name]
# EXAMPLE: installman
# EXAMPLE: installman flutter
# EXAMPLE: installman android-studio
installman() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    # Fonction pour afficher le header
    show_header() {
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                  INSTALLMAN - INSTALLATION MANAGER            ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
    }
    
    # Fonction pour obtenir le statut d'installation
    get_install_status() {
        local tool_check="$1"
        local status=$($tool_check 2>/dev/null)
        if [ "$status" = "installed" ]; then
            echo -e "${GREEN}[✓ Installé]${RESET}"
        else
            echo -e "${YELLOW}[✗ Non installé]${RESET}"
        fi
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        echo -e "${YELLOW}📦 INSTALLATION D'OUTILS DE DÉVELOPPEMENT${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        # Vérifier les statuts d'installation
        local flutter_status=$(get_install_status "check_flutter_installed")
        local dotnet_status=$(get_install_status "check_dotnet_installed")
        local emacs_status=$(get_install_status "check_emacs_installed")
        local java_status=$(get_install_status "check_java17_installed")
        local android_studio_status=$(get_install_status "check_android_studio_installed")
        local android_tools_status=$(get_install_status "check_android_tools_installed")
        
        echo "1.  🎯 Flutter SDK                    (flutter)     $flutter_status"
        echo "2.  🔷 .NET SDK                       (dotnet)       $dotnet_status"
        echo "3.  📝 Emacs + Doom Emacs             (emacs)        $emacs_status"
        echo "4.  ☕ Java 17 OpenJDK                (java17)       $java_status"
        echo "5.  🤖 Android Studio                 (android-studio) $android_studio_status"
        echo "6.  🔧 Outils Android (ADB, SDK)      (android-tools) $android_tools_status"
        echo ""
        echo "0.  Quitter"
        echo ""
        echo -e "${CYAN}💡 Astuce: Vous pouvez taper le nom complet (ex: 'flutter') au lieu du numéro${RESET}"
        echo ""
        printf "Choix [numéro ou nom]: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        # Fonction pour installer un outil
        install_tool() {
            local tool_name="$1"
            local module_file="$2"
            local install_func="$3"
            
            if [ -f "$module_file" ]; then
                source "$module_file"
                $install_func
            else
                echo -e "${RED}❌ Module $tool_name non disponible${RESET}"
                sleep 2
            fi
        }
        
        # Traitement du choix (numéro ou nom)
        case "$choice" in
            # Numéros
            1|flutter|flut)
                install_tool "Flutter" "$INSTALLMAN_MODULES_DIR/flutter/install_flutter.sh" "install_flutter"
                ;;
            2|dotnet|dot-net|.net|net)
                install_tool ".NET" "$INSTALLMAN_MODULES_DIR/dotnet/install_dotnet.sh" "install_dotnet"
                ;;
            3|emacs|emac)
                install_tool "Emacs" "$INSTALLMAN_MODULES_DIR/emacs/install_emacs.sh" "install_emacs"
                ;;
            4|java|java17|java-17|jdk|openjdk)
                install_tool "Java 17" "$INSTALLMAN_MODULES_DIR/java/install_java17.sh" "install_java17"
                ;;
            5|android-studio|androidstudio|android|studio|as)
                install_tool "Android Studio" "$INSTALLMAN_MODULES_DIR/android/install_android_studio.sh" "install_android_studio"
                ;;
            6|android-tools|androidtools|adb|sdk|android-sdk)
                install_tool "Outils Android" "$INSTALLMAN_MODULES_DIR/android/install_android_tools.sh" "install_android_tools"
                ;;
            0|quit|exit|q)
                return 0
                ;;
            *)
                echo -e "${RED}❌ Choix invalide: '$choice'${RESET}"
                echo ""
                echo -e "${YELLOW}Outils disponibles:${RESET}"
                echo "  - flutter"
                echo "  - dotnet"
                echo "  - emacs"
                echo "  - java17"
                echo "  - android-studio"
                echo "  - android-tools"
                echo ""
                sleep 2
                show_main_menu
                ;;
        esac
    }
    
    # Fonction pour installer un outil (utilisée par le menu et les arguments)
    install_tool() {
        local tool_name="$1"
        local module_file="$2"
        local install_func="$3"
        
        if [ -f "$module_file" ]; then
            source "$module_file"
            $install_func
        else
            echo -e "${RED}❌ Module $tool_name non disponible${RESET}"
            return 1
        fi
    }
    
    # Si un argument est fourni, lancer directement le module
    if [ -n "$1" ]; then
        local tool_arg=$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        
        case "$tool_arg" in
            flutter|flut)
                install_tool "Flutter" "$INSTALLMAN_MODULES_DIR/flutter/install_flutter.sh" "install_flutter"
                ;;
            dotnet|dot-net|.net|net)
                install_tool ".NET" "$INSTALLMAN_MODULES_DIR/dotnet/install_dotnet.sh" "install_dotnet"
                ;;
            emacs|emac)
                install_tool "Emacs" "$INSTALLMAN_MODULES_DIR/emacs/install_emacs.sh" "install_emacs"
                ;;
            java|java17|java-17|jdk|openjdk)
                install_tool "Java 17" "$INSTALLMAN_MODULES_DIR/java/install_java17.sh" "install_java17"
                ;;
            android-studio|androidstudio|android|studio|as)
                install_tool "Android Studio" "$INSTALLMAN_MODULES_DIR/android/install_android_studio.sh" "install_android_studio"
                ;;
            android-tools|androidtools|adb|sdk|android-sdk)
                install_tool "Outils Android" "$INSTALLMAN_MODULES_DIR/android/install_android_tools.sh" "install_android_tools"
                ;;
            list|help|--help|-h)
                echo -e "${CYAN}${BOLD}INSTALLMAN - Outils disponibles:${RESET}"
                echo ""
                echo "  ${GREEN}flutter${RESET}          - Flutter SDK"
                echo "  ${GREEN}dotnet${RESET}           - .NET SDK"
                echo "  ${GREEN}emacs${RESET}            - Emacs + Doom Emacs"
                echo "  ${GREEN}java17${RESET}           - Java 17 OpenJDK"
                echo "  ${GREEN}android-studio${RESET}   - Android Studio"
                echo "  ${GREEN}android-tools${RESET}    - Outils Android (ADB, SDK)"
                echo ""
                echo -e "${YELLOW}Usage:${RESET}"
                echo "  installman [tool-name]     - Installer directement un outil"
                echo "  installman                 - Menu interactif"
                echo ""
                echo -e "${CYAN}Exemples:${RESET}"
                echo "  installman flutter"
                echo "  installman android-studio"
                echo "  installman java17"
                ;;
            *)
                echo -e "${RED}❌ Outil inconnu: '$1'${RESET}"
                echo ""
                echo -e "${YELLOW}Outils disponibles:${RESET}"
                echo "  - flutter"
                echo "  - dotnet"
                echo "  - emacs"
                echo "  - java17"
                echo "  - android-studio"
                echo "  - android-tools"
                echo ""
                echo "Usage: installman [tool-name]"
                echo "   ou: install-tool [tool-name] (alias)"
                echo "   ou: installman (menu interactif)"
                echo "   ou: installman list (afficher la liste)"
                return 1
                ;;
        esac
    else
        # Mode interactif - NE PAS APPELER AUTOMATIQUEMENT
        # Le menu ne s'affiche que si installman est appelé explicitement
        show_main_menu
    fi
}

# Créer l'alias install-tool pour compatibilité
alias install-tool='installman'

# Alias
alias im='installman'

