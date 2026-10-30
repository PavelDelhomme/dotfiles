#!/bin/bash
# =============================================================================
# INSTALLMAN - Installation Manager pour Bash
# =============================================================================
# Description: Gestionnaire complet des installations d'outils de développement
# Author: Paul Delhomme
# Version: 2.0
# Converted from ZSH to Bash
# =============================================================================

# Répertoires de base
INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/bash/functions/installman}"
INSTALLMAN_MODULES_DIR="$INSTALLMAN_DIR/modules"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"

# Chemins - utiliser les modules ZSH pour compatibilité
if [ -z "$DOTFILES_DIR" ]; then
    DOTFILES_DIR="$HOME/dotfiles"
fi

ZSH_INSTALLMAN_DIR="$DOTFILES_DIR/zsh/functions/installman"
ZSH_INSTALLMAN_MODULES_DIR="$ZSH_INSTALLMAN_DIR/modules"
ZSH_INSTALLMAN_UTILS_DIR="$ZSH_INSTALLMAN_DIR/utils"

# Utiliser les modules ZSH (partagés)
INSTALLMAN_MODULES_DIR="$ZSH_INSTALLMAN_MODULES_DIR"
INSTALLMAN_UTILS_DIR="$ZSH_INSTALLMAN_UTILS_DIR"

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

# =============================================================================
# DÉFINITION DES OUTILS DISPONIBLES
# =============================================================================
# Format: "nom:alias1,alias2:emoji:description:check_function:module_file:install_function"
declare -a TOOLS=(
    "flutter:flut:🎯:Flutter SDK:check_flutter_installed:flutter/install_flutter.sh:install_flutter"
    "dotnet:dot-net,.net,net:🔷:.NET SDK:check_dotnet_installed:dotnet/install_dotnet.sh:install_dotnet"
    "emacs:emac:📝:Emacs + Doom Emacs:check_emacs_installed:emacs/install_emacs.sh:install_emacs"
    "java8:java8,jdk8:☕:Java 8 OpenJDK:check_java8_installed:java/install_java.sh:install_java8"
    "java11:java11,jdk11:☕:Java 11 OpenJDK:check_java11_installed:java/install_java.sh:install_java11"
    "java17:java17,java-17,jdk17:☕:Java 17 OpenJDK:check_java17_installed:java/install_java.sh:install_java17"
    "java21:java21,jdk21:☕:Java 21 OpenJDK:check_java21_installed:java/install_java.sh:install_java21"
    "java25:java25,jdk25,java,jdk:☕:Java 25 OpenJDK:check_java25_installed:java/install_java.sh:install_java25"
    "android-studio:androidstudio,android,studio,as:🤖:Android Studio:check_android_studio_installed:android/install_android_studio.sh:install_android_studio"
    "android-tools:androidtools,adb,sdk,android-sdk:🔧:Outils Android (ADB, SDK):check_android_tools_installed:android/install_android_tools.sh:install_android_tools"
    "android-licenses:android-license,licenses:📝:Accepter licences Android SDK:check_android_licenses_accepted:android/accept_android_licenses.sh:accept_android_licenses"
    "docker::🐳:Docker & Docker Compose:check_docker_installed:docker/install_docker.sh:install_docker"
    "brave:brave-browser:🌐:Brave Browser:check_brave_installed:brave/install_brave.sh:install_brave"
    "cursor::💻:Cursor IDE:check_cursor_installed:cursor/install_cursor.sh:install_cursor"
    "i2p:i2pd,purple-i2p,purple:🧅:I2P (i2pd / réseau I2P):check_i2p_installed:i2p/install_i2p.sh:install_i2p"
    "icecat:gnu-icecat,iceweasel:🦊:GNU IceCat (navigateur libre):check_icecat_installed:icecat/install_icecat.sh:install_icecat"
    "qemu:qemu-kvm,kvm:🖥️:QEMU/KVM (Virtualisation):check_qemu_installed:qemu/install_qemu.sh:install_qemu"
    "ssh-config:ssh,ssh-setup:🔐:Configuration SSH automatique:check_ssh_configured:ssh/install_ssh_config.sh:install_ssh_config"
)

# DESC: Gestionnaire interactif complet pour installer des outils de développement
# USAGE: installman [tool-name]
# EXAMPLE: installman
# EXAMPLE: installman flutter
# EXAMPLE: installman docker
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
    
    # Fonction pour split une chaîne par un délimiteur (Bash)
    split_string() {
        local str="$1"
        local delimiter="$2"
        IFS="$delimiter" read -ra parts <<< "$str"
        echo "${parts[@]}"
    }
    
    # Fonction pour trouver un outil par nom/alias
    find_tool() {
        local search_term="$1"
        search_term=$(echo "$search_term" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        
        for tool_def in "${TOOLS[@]}"; do
            # Split par ':' pour Bash
            IFS=':' read -ra tool_parts <<< "$tool_def"
            
            # Vérifier que nous avons assez de parties (7: nom, alias, emoji, desc, check, module, func)
            if [ ${#tool_parts[@]} -lt 7 ]; then
                continue
            fi
            
            local tool_name="${tool_parts[0]}"
            local tool_aliases_str="${tool_parts[1]}"
            
            # Vérifier si le terme correspond au nom principal
            if [ "$tool_name" = "$search_term" ]; then
                echo "$tool_def"
                return 0
            fi
            
            # Vérifier les alias (séparés par des virgules)
            if [ -n "$tool_aliases_str" ]; then
                IFS=',' read -ra aliases <<< "$tool_aliases_str"
                for alias in "${aliases[@]}"; do
                    alias=$(echo "$alias" | tr -d '[:space:]')
                    if [ "$alias" = "$search_term" ]; then
                        echo "$tool_def"
                        return 0
                    fi
                done
            fi
        done
        
        return 1
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        echo -e "${YELLOW}📦 INSTALLATION D'OUTILS ET APPLICATIONS${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        # Organiser par catégories
        echo -e "${BOLD}💻 DÉVELOPPEMENT:${RESET}"
        local index=1
        local dev_tools=("flutter" "dotnet" "emacs" "java8" "java11" "java17" "java21" "java25" "android-studio" "android-tools" "docker")
        for tool_name in "${dev_tools[@]}"; do
            for tool_def in "${TOOLS[@]}"; do
                IFS=':' read -ra tool_parts <<< "$tool_def"
                if [ "${tool_parts[0]}" = "$tool_name" ]; then
                    local tool_emoji="${tool_parts[2]}"
                    local tool_desc="${tool_parts[3]}"
                    local tool_check="${tool_parts[4]}"
                    local status=$(get_install_status "$tool_check")
                    printf "  %-3s %s %-30s %s\n" "$index." "$tool_emoji" "$tool_desc" "$status"
                    index=$((index + 1))
                    break
                fi
            done
        done
        
        echo ""
        echo -e "${BOLD}🌐 APPLICATIONS:${RESET}"
        local app_tools=("brave" "cursor")
        for tool_name in "${app_tools[@]}"; do
            for tool_def in "${TOOLS[@]}"; do
                IFS=':' read -ra tool_parts <<< "$tool_def"
                if [ "${tool_parts[0]}" = "$tool_name" ]; then
                    local tool_emoji="${tool_parts[2]}"
                    local tool_desc="${tool_parts[3]}"
                    local tool_check="${tool_parts[4]}"
                    local status=$(get_install_status "$tool_check")
                    printf "  %-3s %s %-30s %s\n" "$index." "$tool_emoji" "$tool_desc" "$status"
                    index=$((index + 1))
                    break
                fi
            done
        done
        
        echo ""
        echo -e "${BOLD}⚙️  CONFIGURATION ANDROID:${RESET}"
        local android_config_tools=("android-licenses")
        for tool_name in "${android_config_tools[@]}"; do
            for tool_def in "${TOOLS[@]}"; do
                IFS=':' read -ra tool_parts <<< "$tool_def"
                if [ "${tool_parts[0]}" = "$tool_name" ]; then
                    local tool_emoji="${tool_parts[2]}"
                    local tool_desc="${tool_parts[3]}"
                    local tool_check="${tool_parts[4]}"
                    local status=$(get_install_status "$tool_check")
                    printf "  %-3s %s %-30s %s\n" "$index." "$tool_emoji" "$tool_desc" "$status"
                    index=$((index + 1))
                    break
                fi
            done
        done
        
        echo ""
        echo -e "${BOLD}🖥️  SYSTÈME & VIRTUALISATION:${RESET}"
        local sys_tools=("qemu")
        for tool_name in "${sys_tools[@]}"; do
            for tool_def in "${TOOLS[@]}"; do
                IFS=':' read -ra tool_parts <<< "$tool_def"
                if [ "${tool_parts[0]}" = "$tool_name" ]; then
                    local tool_emoji="${tool_parts[2]}"
                    local tool_desc="${tool_parts[3]}"
                    local tool_check="${tool_parts[4]}"
                    local status=$(get_install_status "$tool_check")
                    printf "  %-3s %s %-30s %s\n" "$index." "$tool_emoji" "$tool_desc" "$status"
                    index=$((index + 1))
                    break
                fi
            done
        done
        
        echo ""
        echo "0.  Quitter"
        echo ""
        echo -e "${CYAN}💡 Tapez le nom de l'outil (ex: 'flutter', 'docker', 'brave') puis appuyez sur Entrée${RESET}"
        echo -e "${CYAN}   Ou tapez un numéro pour sélectionner par position${RESET}"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        # Fonction pour installer un outil
        install_tool_from_def() {
            local tool_def="$1"
            IFS=':' read -ra tool_parts <<< "$tool_def"
            local tool_name="${tool_parts[0]}"
            local tool_desc="${tool_parts[3]}"
            local module_file="${tool_parts[5]}"
            local install_func="${tool_parts[6]}"
            
            local full_module_path="$INSTALLMAN_MODULES_DIR/$module_file"
            
            if [ -f "$full_module_path" ]; then
                source "$full_module_path"
                $install_func
            else
                echo -e "${RED}❌ Module $tool_desc non disponible: $full_module_path${RESET}"
                sleep 2
            fi
        }
        
        # Traitement du choix
        if [ -z "$choice" ] || [ "$choice" = "0" ] || [ "$choice" = "quit" ] || [ "$choice" = "exit" ] || [ "$choice" = "q" ]; then
            return 0
        fi
        
        # Vérifier si c'est un numéro
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            local tool_index=$((choice))
            local tools_count=${#TOOLS[@]}
            if [ $tool_index -ge 1 ] && [ $tool_index -le $tools_count ]; then
                local array_index=$((tool_index - 1))
                local tool_def="${TOOLS[$array_index]}"
                install_tool_from_def "$tool_def"
            else
                echo -e "${RED}❌ Numéro invalide: $choice${RESET}"
                sleep 2
                show_main_menu
            fi
        else
            # Rechercher par nom/alias
            local found_tool=$(find_tool "$choice")
            if [ -n "$found_tool" ]; then
                install_tool_from_def "$found_tool"
            else
                echo -e "${RED}❌ Outil non trouvé: '$choice'${RESET}"
                echo ""
                echo -e "${YELLOW}Outils disponibles:${RESET}"
                for tool_def in "${TOOLS[@]}"; do
                    IFS=':' read -ra tool_parts <<< "$tool_def"
                    echo "  - ${tool_parts[0]}"
                done
                echo ""
                sleep 2
                show_main_menu
            fi
        fi
    }
    
    # Fonction pour installer un outil (utilisée par les arguments en ligne de commande)
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
        
        # Rechercher l'outil
        local found_tool=$(find_tool "$tool_arg")
        if [ -n "$found_tool" ]; then
            IFS=':' read -ra tool_parts <<< "$found_tool"
            local tool_desc="${tool_parts[3]}"
            local module_file="${tool_parts[5]}"
            local install_func="${tool_parts[6]}"
            local full_module_path="$INSTALLMAN_MODULES_DIR/$module_file"
            install_tool "$tool_desc" "$full_module_path" "$install_func"
        elif [ "$tool_arg" = "list" ] || [ "$tool_arg" = "help" ] || [ "$tool_arg" = "--help" ] || [ "$tool_arg" = "-h" ]; then
            echo -e "${CYAN}${BOLD}INSTALLMAN - Outils disponibles:${RESET}"
            echo ""
            for tool_def in "${TOOLS[@]}"; do
                IFS=':' read -ra tool_parts <<< "$tool_def"
                local tool_name="${tool_parts[0]}"
                local tool_emoji="${tool_parts[2]}"
                local tool_desc="${tool_parts[3]}"
                echo "  ${GREEN}$tool_name${RESET} $tool_emoji - $tool_desc"
            done
            echo ""
            echo -e "${YELLOW}Usage:${RESET}"
            echo "  installman [tool-name]     - Installer directement un outil"
            echo "  installman                 - Menu interactif"
            echo ""
            echo -e "${CYAN}Exemples:${RESET}"
            echo "  installman flutter"
            echo "  installman docker"
            echo "  installman cursor"
        else
            echo -e "${RED}❌ Outil inconnu: '$1'${RESET}"
            echo ""
            echo -e "${YELLOW}Outils disponibles:${RESET}"
            for tool_def in "${TOOLS[@]}"; do
                IFS=':' read -ra tool_parts <<< "$tool_def"
                echo "  - ${tool_parts[0]}"
            done
            echo ""
            echo "Usage: installman [tool-name]"
            echo "   ou: install-tool [tool-name] (alias)"
            echo "   ou: installman (menu interactif)"
            echo "   ou: installman list (afficher la liste)"
            return 1
        fi
    else
        # Mode interactif
        show_main_menu
    fi
}

# Créer l'alias install-tool pour compatibilité (Bash)
alias install-tool='installman'

# Alias
alias im='installman'

