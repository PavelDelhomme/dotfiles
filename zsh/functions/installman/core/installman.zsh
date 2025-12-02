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
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        echo -e "${YELLOW}📦 INSTALLATION D'OUTILS DE DÉVELOPPEMENT${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        echo "1.  🎯 Flutter SDK"
        echo "2.  🔷 .NET SDK"
        echo "3.  📝 Emacs + Doom Emacs + Config de base"
        echo "4.  ☕ Java 17 OpenJDK"
        echo "5.  🤖 Android Studio"
        echo "6.  🔧 Outils Android (ADB, SDK, etc.)"
        echo ""
        echo "0.  Quitter"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                if [ -f "$INSTALLMAN_MODULES_DIR/flutter/install_flutter.sh" ]; then
                    source "$INSTALLMAN_MODULES_DIR/flutter/install_flutter.sh"
                    install_flutter
                else
                    echo -e "${RED}❌ Module Flutter non disponible${RESET}"
                    sleep 2
                fi
                ;;
            2)
                if [ -f "$INSTALLMAN_MODULES_DIR/dotnet/install_dotnet.sh" ]; then
                    source "$INSTALLMAN_MODULES_DIR/dotnet/install_dotnet.sh"
                    install_dotnet
                else
                    echo -e "${RED}❌ Module .NET non disponible${RESET}"
                    sleep 2
                fi
                ;;
            3)
                if [ -f "$INSTALLMAN_MODULES_DIR/emacs/install_emacs.sh" ]; then
                    source "$INSTALLMAN_MODULES_DIR/emacs/install_emacs.sh"
                    install_emacs
                else
                    echo -e "${RED}❌ Module Emacs non disponible${RESET}"
                    sleep 2
                fi
                ;;
            4)
                if [ -f "$INSTALLMAN_MODULES_DIR/java/install_java17.sh" ]; then
                    source "$INSTALLMAN_MODULES_DIR/java/install_java17.sh"
                    install_java17
                else
                    echo -e "${RED}❌ Module Java 17 non disponible${RESET}"
                    sleep 2
                fi
                ;;
            5)
                if [ -f "$INSTALLMAN_MODULES_DIR/android/install_android_studio.sh" ]; then
                    source "$INSTALLMAN_MODULES_DIR/android/install_android_studio.sh"
                    install_android_studio
                else
                    echo -e "${RED}❌ Module Android Studio non disponible${RESET}"
                    sleep 2
                fi
                ;;
            6)
                if [ -f "$INSTALLMAN_MODULES_DIR/android/install_android_tools.sh" ]; then
                    source "$INSTALLMAN_MODULES_DIR/android/install_android_tools.sh"
                    install_android_tools
                else
                    echo -e "${RED}❌ Module Outils Android non disponible${RESET}"
                    sleep 2
                fi
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${RED}Choix invalide${RESET}"
                sleep 1
                show_main_menu
                ;;
        esac
    }
    
    # Si un argument est fourni, lancer directement le module
    if [ -n "$1" ]; then
        case "$1" in
            flutter|Flutter)
                if [ -f "$INSTALLMAN_MODULES_DIR/flutter/install_flutter.sh" ]; then
                    source "$INSTALLMAN_MODULES_DIR/flutter/install_flutter.sh"
                    install_flutter
                fi
                ;;
            dotnet|dot-net|.NET|net)
                if [ -f "$INSTALLMAN_MODULES_DIR/dotnet/install_dotnet.sh" ]; then
                    source "$INSTALLMAN_MODULES_DIR/dotnet/install_dotnet.sh"
                    install_dotnet
                fi
                ;;
            emacs|Emacs)
                if [ -f "$INSTALLMAN_MODULES_DIR/emacs/install_emacs.sh" ]; then
                    source "$INSTALLMAN_MODULES_DIR/emacs/install_emacs.sh"
                    install_emacs
                fi
                ;;
            java|java17|Java|Java17)
                if [ -f "$INSTALLMAN_MODULES_DIR/java/install_java17.sh" ]; then
                    source "$INSTALLMAN_MODULES_DIR/java/install_java17.sh"
                    install_java17
                fi
                ;;
            android-studio|androidstudio|AndroidStudio)
                if [ -f "$INSTALLMAN_MODULES_DIR/android/install_android_studio.sh" ]; then
                    source "$INSTALLMAN_MODULES_DIR/android/install_android_studio.sh"
                    install_android_studio
                fi
                ;;
            android-tools|androidtools|adb|AndroidTools)
                if [ -f "$INSTALLMAN_MODULES_DIR/android/install_android_tools.sh" ]; then
                    source "$INSTALLMAN_MODULES_DIR/android/install_android_tools.sh"
                    install_android_tools
                fi
                ;;
            *)
                echo -e "${RED}Outil inconnu: $1${RESET}"
                echo ""
                echo "Outils disponibles:"
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

