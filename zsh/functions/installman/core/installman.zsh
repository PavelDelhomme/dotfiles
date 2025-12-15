#!/bin/zsh
# =============================================================================
# INSTALLMAN - Installation Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet des installations d'outils de développement
# Author: Paul Delhomme
# Version: 2.0
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

# Charger les fonctions de gestion de version
[ -f "$INSTALLMAN_UTILS_DIR/version_utils.sh" ] && source "$INSTALLMAN_UTILS_DIR/version_utils.sh"

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
    "handbrake:hb,handbrake-cli:🎬:HandBrake (encodage vidéo):check_handbrake_installed:handbrake/install_handbrake.sh:install_handbrake"
    "network-tools:net-tools,net-tools:🌐:Outils réseau (nslookup, dig, nmap, etc.):check_network_tools_installed:network-tools/install_network_tools.sh:install_network_tools"
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
        local install_status=$($tool_check 2>/dev/null)
        if [ "$install_status" = "installed" ]; then
            echo -e "${GREEN}[✓ Installé]${RESET}"
        else
            echo -e "${YELLOW}[✗ Non installé]${RESET}"
        fi
    }
    
    # Fonction pour afficher le menu de mise à jour
    show_update_menu() {
        show_header
        echo -e "${YELLOW}🔄 MISE À JOUR D'OUTILS${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        # Lister les outils installés avec leurs versions
        echo -e "${BOLD}📦 Outils installés:${RESET}\n"
        local index=1
        local installed_tools=()
        
        for tool_def in "${TOOLS[@]}"; do
            IFS=':' read -rA tool_parts <<< "$tool_def"
            local tool_name="${tool_parts[1]}"
            local tool_check="${tool_parts[5]}"
            local install_status=$($tool_check 2>/dev/null)
            
            if [ "$install_status" = "installed" ]; then
                local tool_emoji="${tool_parts[3]}"
                local tool_desc="${tool_parts[4]}"
                local current_version=$(get_current_version "$tool_name" 2>/dev/null || echo "unknown")
                local latest_version=$(get_latest_version "$tool_name" 2>/dev/null || echo "unknown")
                
                # Vérifier si mise à jour disponible
                local update_indicator=""
                if is_update_available "$tool_name" 2>/dev/null; then
                    update_indicator="${YELLOW}🆕${RESET}"
                else
                    update_indicator="${GREEN}✓${RESET}"
                fi
                
                printf "  %-3s %s %-30s ${CYAN}v%s${RESET} → ${GREEN}v%s${RESET} %s\n" \
                    "$index." "$tool_emoji" "$tool_desc" "$current_version" "$latest_version" "$update_indicator"
                
                installed_tools+=("$tool_def")
                ((index++))
            fi
        done
        
        if [ ${#installed_tools[@]} -eq 0 ]; then
            echo -e "${YELLOW}Aucun outil installé${RESET}"
            echo ""
            read -p "Appuyez sur Entrée pour retourner au menu principal..."
            show_main_menu
            return 0
        fi
        
        echo ""
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choisir un outil à mettre à jour (numéro): "
        read -r update_choice
        update_choice=$(echo "$update_choice" | tr -d '[:space:]')
        
        if [ -z "$update_choice" ] || [ "$update_choice" = "0" ]; then
            show_main_menu
            return 0
        fi
        
        if [[ "$update_choice" =~ ^[0-9]+$ ]]; then
            local tool_index=$((update_choice))
            if [ $tool_index -ge 1 ] && [ $tool_index -le ${#installed_tools[@]} ]; then
                local tool_def="${installed_tools[$tool_index]}"
                update_tool_from_def "$tool_def"
            else
                echo -e "${RED}❌ Numéro invalide: $update_choice${RESET}"
                sleep 2
                show_update_menu
            fi
        else
            echo -e "${RED}❌ Choix invalide${RESET}"
            sleep 2
            show_update_menu
        fi
    }
    
    # Fonction pour mettre à jour un outil avec choix de version
    update_tool_from_def() {
        local tool_def="$1"
        IFS=':' read -rA tool_parts <<< "$tool_def"
        local tool_name="${tool_parts[1]}"
        local tool_desc="${tool_parts[4]}"
        local module_file="${tool_parts[6]}"
        local install_func="${tool_parts[7]}"
        
        show_header
        echo -e "${YELLOW}🔄 Mise à jour: $tool_desc${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        # Obtenir la version actuelle
        local current_version=$(get_current_version "$tool_name" 2>/dev/null || echo "unknown")
        echo -e "${CYAN}Version actuelle:${RESET} ${BOLD}$current_version${RESET}"
        
        # Obtenir les versions disponibles
        echo -e "\n${CYAN}Versions disponibles:${RESET}"
        local available_versions=$(get_available_versions "$tool_name" 2>/dev/null)
        local latest_version=$(echo "$available_versions" | head -n1)
        
        if [ -n "$available_versions" ] && [ "$available_versions" != "latest" ]; then
            local version_index=1
            local versions_array=()
            while IFS= read -r version; do
                if [ -n "$version" ]; then
                    if [ "$version" = "$latest_version" ]; then
                        echo -e "  ${GREEN}${version_index}.${RESET} ${BOLD}$version${RESET} ${GREEN}(dernière)${RESET}"
                    else
                        echo -e "  ${version_index}. $version"
                    fi
                    versions_array+=("$version")
                    ((version_index++))
                fi
            done <<< "$available_versions"
        else
            echo -e "  ${GREEN}1.${RESET} ${BOLD}latest${RESET} ${GREEN}(dernière version)${RESET}"
            versions_array=("latest")
        fi
        
        echo ""
        echo "0.  Annuler"
        echo ""
        printf "Choisir une version (numéro ou version exacte): "
        read -r version_choice
        version_choice=$(echo "$version_choice" | tr -d '[:space:]')
        
        if [ -z "$version_choice" ] || [ "$version_choice" = "0" ]; then
            show_update_menu
            return 0
        fi
        
        # Déterminer la version choisie
        local selected_version=""
        if [[ "$version_choice" =~ ^[0-9]+$ ]]; then
            local version_index=$((version_choice))
            if [ $version_index -ge 1 ] && [ $version_index -le ${#versions_array[@]} ]; then
                selected_version="${versions_array[$version_index]}"
            else
                echo -e "${RED}❌ Numéro invalide${RESET}"
                sleep 2
                update_tool_from_def "$tool_def"
                return 1
            fi
        else
            # Version spécifique fournie
            selected_version="$version_choice"
        fi
        
        # Confirmer la mise à jour
        echo ""
        echo -e "${YELLOW}⚠️  Mise à jour de $tool_desc${RESET}"
        echo -e "   ${CYAN}De:${RESET} $current_version"
        echo -e "   ${CYAN}Vers:${RESET} $selected_version"
        echo ""
        read -p "Confirmer la mise à jour? (O/n): " confirm
        confirm=${confirm:-O}
        
        if [[ ! "$confirm" =~ ^[oO]$ ]]; then
            echo -e "${YELLOW}Mise à jour annulée${RESET}"
            sleep 1
            show_update_menu
            return 0
        fi
        
        # Exécuter la mise à jour
        local full_module_path="$INSTALLMAN_MODULES_DIR/$module_file"
        
        if [ -f "$full_module_path" ]; then
            source "$full_module_path"
            
            # Si la fonction d'installation supporte un paramètre de version, l'utiliser
            # Sinon, réinstaller simplement (la plupart des modules gèrent déjà la réinstallation)
            if type "${install_func}_with_version" &>/dev/null; then
                "${install_func}_with_version" "$selected_version"
            else
                # Réinstaller (les modules gèrent généralement la mise à jour via réinstallation)
                echo -e "\n${CYAN}Mise à jour en cours...${RESET}\n"
                $install_func
            fi
            
            # Vérifier la nouvelle version
            local new_version=$(get_current_version "$tool_name" 2>/dev/null || echo "unknown")
            echo ""
            if [ "$new_version" != "not_installed" ] && [ "$new_version" != "unknown" ]; then
                echo -e "${GREEN}✅ Mise à jour terminée!${RESET}"
                echo -e "${CYAN}Nouvelle version:${RESET} ${BOLD}$new_version${RESET}"
            else
                echo -e "${YELLOW}⚠️  Mise à jour terminée (version non détectable)${RESET}"
            fi
            
            echo ""
            read -p "Appuyez sur Entrée pour continuer..."
            show_update_menu
        else
            echo -e "${RED}❌ Module $tool_desc non disponible: $full_module_path${RESET}"
            sleep 2
            show_update_menu
        fi
    }
    
    # Fonction pour mettre à jour tous les outils installés
    update_all_tools() {
        show_header
        echo -e "${YELLOW}🔄 Mise à jour de tous les outils${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        local tools_to_update=()
        
        # Trouver tous les outils installés qui ont des mises à jour disponibles
        for tool_def in "${TOOLS[@]}"; do
            IFS=':' read -rA tool_parts <<< "$tool_def"
            local tool_name="${tool_parts[1]}"
            local tool_check="${tool_parts[5]}"
            local install_status=$($tool_check 2>/dev/null)
            
            if [ "$install_status" = "installed" ]; then
                if is_update_available "$tool_name" 2>/dev/null; then
                    tools_to_update+=("$tool_def")
                fi
            fi
        done
        
        if [ ${#tools_to_update[@]} -eq 0 ]; then
            echo -e "${GREEN}✅ Tous les outils sont à jour!${RESET}"
            echo ""
            read -p "Appuyez sur Entrée pour retourner au menu principal..."
            show_main_menu
            return 0
        fi
        
        echo -e "${CYAN}Outils à mettre à jour:${RESET} ${#tools_to_update[@]}"
        echo ""
        for tool_def in "${tools_to_update[@]}"; do
            IFS=':' read -rA tool_parts <<< "$tool_def"
            local tool_name="${tool_parts[1]}"
            local tool_desc="${tool_parts[4]}"
            local current_version=$(get_current_version "$tool_name" 2>/dev/null || echo "unknown")
            local latest_version=$(get_latest_version "$tool_name" 2>/dev/null || echo "unknown")
            echo -e "  • $tool_desc: ${CYAN}$current_version${RESET} → ${GREEN}$latest_version${RESET}"
        done
        
        echo ""
        read -p "Mettre à jour tous ces outils? (O/n): " confirm
        confirm=${confirm:-O}
        
        if [[ ! "$confirm" =~ ^[oO]$ ]]; then
            echo -e "${YELLOW}Mise à jour annulée${RESET}"
            sleep 1
            show_main_menu
            return 0
        fi
        
        # Mettre à jour chaque outil
        local updated=0
        local failed=0
        
        for tool_def in "${tools_to_update[@]}"; do
            IFS=':' read -rA tool_parts <<< "$tool_def"
            local tool_desc="${tool_parts[4]}"
            
            echo ""
            echo -e "${CYAN}Mise à jour de $tool_desc...${RESET}"
            if update_tool_from_def "$tool_def" 2>/dev/null; then
                ((updated++))
            else
                ((failed++))
            fi
        done
        
        echo ""
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo -e "${GREEN}✅ Mises à jour terminées!${RESET}"
        echo -e "   ${GREEN}Réussies:${RESET} $updated"
        if [ $failed -gt 0 ]; then
            echo -e "   ${RED}Échouées:${RESET} $failed"
        fi
        echo ""
        read -p "Appuyez sur Entrée pour retourner au menu principal..."
        show_main_menu
    }
    
    # Fonction pour trouver un outil par nom/alias
    find_tool() {
        local search_term="$1"
        search_term=$(echo "$search_term" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        
        for tool_def in "${TOOLS[@]}"; do
            # Utiliser la syntaxe Zsh native pour split par ':'
            local tool_parts=("${(@s/:/)tool_def}")
            
            # Vérifier que nous avons assez de parties (7: nom, alias, emoji, desc, check, module, func)
            if [ ${#tool_parts[@]} -lt 7 ]; then
                continue
            fi
            
            local tool_name="${tool_parts[1]}"
            local tool_aliases_str="${tool_parts[2]}"
            
            # Vérifier si le terme correspond au nom principal
            if [ "$tool_name" = "$search_term" ]; then
                echo "$tool_def"
                return 0
            fi
            
            # Vérifier les alias (séparés par des virgules)
            if [ -n "$tool_aliases_str" ]; then
                local aliases=("${(@s/,/)tool_aliases_str}")
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
                IFS=':' read -rA tool_parts <<< "$tool_def"
                if [ "${tool_parts[1]}" = "$tool_name" ]; then
                    local tool_emoji="${tool_parts[3]}"
                    local tool_desc="${tool_parts[4]}"
                    local tool_check="${tool_parts[5]}"
                    local install_status=$(get_install_status "$tool_check")
                    printf "  %-3s %s %-30s %s\n" "$index." "$tool_emoji" "$tool_desc" "$install_status"
                    ((index++))
                    break
                fi
            done
        done
        
        echo ""
        echo -e "${BOLD}🌐 APPLICATIONS:${RESET}"
        local app_tools=("brave" "cursor")
        for tool_name in "${app_tools[@]}"; do
            for tool_def in "${TOOLS[@]}"; do
                IFS=':' read -rA tool_parts <<< "$tool_def"
                if [ "${tool_parts[1]}" = "$tool_name" ]; then
                    local tool_emoji="${tool_parts[3]}"
                    local tool_desc="${tool_parts[4]}"
                    local tool_check="${tool_parts[5]}"
                    local install_status=$(get_install_status "$tool_check")
                    printf "  %-3s %s %-30s %s\n" "$index." "$tool_emoji" "$tool_desc" "$install_status"
                    ((index++))
                    break
                fi
            done
        done
        
        echo ""
        echo -e "${BOLD}🎬 MULTIMÉDIA:${RESET}"
        local media_tools=("handbrake")
        for tool_name in "${media_tools[@]}"; do
            for tool_def in "${TOOLS[@]}"; do
                IFS=':' read -rA tool_parts <<< "$tool_def"
                if [ "${tool_parts[1]}" = "$tool_name" ]; then
                    local tool_emoji="${tool_parts[3]}"
                    local tool_desc="${tool_parts[4]}"
                    local tool_check="${tool_parts[5]}"
                    local install_status=$(get_install_status "$tool_check")
                    printf "  %-3s %s %-30s %s\n" "$index." "$tool_emoji" "$tool_desc" "$install_status"
                    ((index++))
                    break
                fi
            done
        done
        
        echo ""
        echo -e "${BOLD}⚙️  CONFIGURATION ANDROID:${RESET}"
        local android_config_tools=("android-licenses")
        for tool_name in "${android_config_tools[@]}"; do
            for tool_def in "${TOOLS[@]}"; do
                IFS=':' read -rA tool_parts <<< "$tool_def"
                if [ "${tool_parts[1]}" = "$tool_name" ]; then
                    local tool_emoji="${tool_parts[3]}"
                    local tool_desc="${tool_parts[4]}"
                    local tool_check="${tool_parts[5]}"
                    local install_status=$(get_install_status "$tool_check")
                    printf "  %-3s %s %-30s %s\n" "$index." "$tool_emoji" "$tool_desc" "$install_status"
                    ((index++))
                    break
                fi
            done
        done
        
        echo ""
        echo -e "${BOLD}🌐 RÉSEAU:${RESET}"
        local network_tools=("network-tools")
        for tool_name in "${network_tools[@]}"; do
            for tool_def in "${TOOLS[@]}"; do
                IFS=':' read -rA tool_parts <<< "$tool_def"
                if [ "${tool_parts[1]}" = "$tool_name" ]; then
                    local tool_emoji="${tool_parts[3]}"
                    local tool_desc="${tool_parts[4]}"
                    local tool_check="${tool_parts[5]}"
                    local install_status=$(get_install_status "$tool_check")
                    printf "  %-3s %s %-30s %s\n" "$index." "$tool_emoji" "$tool_desc" "$install_status"
                    ((index++))
                    break
                fi
            done
        done
        
        echo ""
        echo -e "${BOLD}🖥️  SYSTÈME & VIRTUALISATION:${RESET}"
        local sys_tools=("qemu")
        for tool_name in "${sys_tools[@]}"; do
            for tool_def in "${TOOLS[@]}"; do
                IFS=':' read -rA tool_parts <<< "$tool_def"
                if [ "${tool_parts[1]}" = "$tool_name" ]; then
                    local tool_emoji="${tool_parts[3]}"
                    local tool_desc="${tool_parts[4]}"
                    local tool_check="${tool_parts[5]}"
                    local install_status=$(get_install_status "$tool_check")
                    printf "  %-3s %s %-30s %s\n" "$index." "$tool_emoji" "$tool_desc" "$install_status"
                    ((index++))
                    break
                fi
            done
        done
        
        echo ""
        echo -e "${BOLD}🔄 MISE À JOUR:${RESET}"
        echo "  u.  Mettre à jour un outil"
        echo "  ua. Mettre à jour tous les outils installés"
        echo ""
        echo "0.  Quitter"
        echo ""
        echo -e "${CYAN}💡 Tapez le nom de l'outil (ex: 'flutter', 'docker', 'brave') puis appuyez sur Entrée${RESET}"
        echo -e "${CYAN}   Ou tapez un numéro pour sélectionner par position${RESET}"
        echo -e "${CYAN}   Ou 'u' pour mettre à jour un outil${RESET}"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        # Fonction pour installer un outil
        install_tool_from_def() {
            local tool_def="$1"
            IFS=':' read -rA tool_parts <<< "$tool_def"
            local tool_name="${tool_parts[1]}"
            local tool_desc="${tool_parts[4]}"
            local module_file="${tool_parts[6]}"
            local install_func="${tool_parts[7]}"
            
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
        
        # Gérer les options de mise à jour
        if [ "$choice" = "u" ] || [ "$choice" = "update" ]; then
            show_update_menu
            return 0
        fi
        
        if [ "$choice" = "ua" ] || [ "$choice" = "update-all" ]; then
            update_all_tools
            return 0
        fi
        
        # Vérifier si c'est un numéro
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            local tool_index=$((choice))
            if [ $tool_index -ge 1 ] && [ $tool_index -le ${#TOOLS[@]} ]; then
                local tool_def="${TOOLS[$tool_index]}"
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
                    IFS=':' read -rA tool_parts <<< "$tool_def"
                    echo "  - ${tool_parts[1]}"
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
        
        # Gérer les commandes spéciales
        if [ "$tool_arg" = "update" ] || [ "$tool_arg" = "u" ]; then
            show_update_menu
            return 0
        fi
        
        if [ "$tool_arg" = "update-all" ] || [ "$tool_arg" = "ua" ]; then
            update_all_tools
            return 0
        fi
        
        # Rechercher l'outil
        local found_tool=$(find_tool "$tool_arg")
        if [ -n "$found_tool" ]; then
            IFS=':' read -rA tool_parts <<< "$found_tool"
            local tool_desc="${tool_parts[4]}"
            local module_file="${tool_parts[6]}"
            local install_func="${tool_parts[7]}"
            local full_module_path="$INSTALLMAN_MODULES_DIR/$module_file"
            install_tool "$tool_desc" "$full_module_path" "$install_func"
        elif [ "$tool_arg" = "list" ] || [ "$tool_arg" = "help" ] || [ "$tool_arg" = "--help" ] || [ "$tool_arg" = "-h" ]; then
            echo -e "${CYAN}${BOLD}INSTALLMAN - Outils disponibles:${RESET}"
            echo ""
            for tool_def in "${TOOLS[@]}"; do
                IFS=':' read -rA tool_parts <<< "$tool_def"
                local tool_name="${tool_parts[1]}"
                local tool_emoji="${tool_parts[3]}"
                local tool_desc="${tool_parts[4]}"
                echo "  ${GREEN}$tool_name${RESET} $tool_emoji - $tool_desc"
            done
            echo ""
            echo -e "${YELLOW}Usage:${RESET}"
            echo "  installman [tool-name]     - Installer directement un outil"
            echo "  installman                 - Menu interactif"
            echo "  installman update          - Menu de mise à jour"
            echo "  installman update-all      - Mettre à jour tous les outils"
            echo ""
            echo -e "${CYAN}Exemples:${RESET}"
            echo "  installman flutter"
            echo "  installman docker"
            echo "  installman cursor"
            echo "  installman update          - Mettre à jour un outil"
            echo "  installman update-all     - Mettre à jour tous les outils"
        else
            echo -e "${RED}❌ Outil inconnu: '$1'${RESET}"
            echo ""
            echo -e "${YELLOW}Outils disponibles:${RESET}"
            for tool_def in "${TOOLS[@]}"; do
                IFS=':' read -rA tool_parts <<< "$tool_def"
                echo "  - ${tool_parts[1]}"
            done
            echo ""
            echo "Usage: installman [tool-name]"
            echo "   ou: install-tool [tool-name] (alias)"
            echo "   ou: installman (menu interactif)"
            echo "   ou: installman list (afficher la liste)"
            return 1
        fi
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

# Message d'initialisation - désactivé pour éviter l'avertissement Powerlevel10k
# echo "📦 INSTALLMAN chargé - Tapez 'installman' ou 'im' pour démarrer"
