#!/bin/sh
# =============================================================================
# INSTALLMAN - Installation Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des installations d'outils de développement
# Author: Paul Delhomme
# Version: 2.0 - Migration POSIX Complète
# =============================================================================

# Détecter le shell pour adapter certaines syntaxes
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_TYPE="fish"
else
    SHELL_TYPE="sh"
fi

# DESC: Gestionnaire interactif complet pour installer des outils de développement
# USAGE: installman [tool-name]
# EXAMPLE: installman
# EXAMPLE: installman flutter
# EXAMPLE: installman docker
installman() {
    # Configuration des couleurs
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    INSTALLMAN_DIR="$DOTFILES_DIR/zsh/functions/installman"
    INSTALLMAN_MODULES_DIR="$INSTALLMAN_DIR/modules"
    INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"
    SCRIPTS_DIR="$DOTFILES_DIR/scripts"
    INSTALL_DIR="$SCRIPTS_DIR/install/dev"
    ENV_FILE="$DOTFILES_DIR/zsh/env.sh"
    
    # Charger les utilitaires si disponibles
    if [ -d "$INSTALLMAN_UTILS_DIR" ]; then
        for util_file in "$INSTALLMAN_UTILS_DIR"/*.sh; do
            if [ -f "$util_file" ]; then
                . "$util_file" 2>/dev/null || true
            fi
        done
    fi
    
    # Charger les fonctions de vérification
    [ -f "$INSTALLMAN_UTILS_DIR/check_installed.sh" ] && . "$INSTALLMAN_UTILS_DIR/check_installed.sh" 2>/dev/null || true
    
    # Charger les fonctions de gestion de version
    [ -f "$INSTALLMAN_UTILS_DIR/version_utils.sh" ] && . "$INSTALLMAN_UTILS_DIR/version_utils.sh" 2>/dev/null || true
    
    # Charger les fonctions de gestion de paquets
    [ -f "$INSTALLMAN_UTILS_DIR/package_manager.sh" ] && . "$INSTALLMAN_UTILS_DIR/package_manager.sh" 2>/dev/null || true
    
    # Définition des outils disponibles (format: "nom:alias1,alias2:emoji:description:check_function:module_file:install_function")
    TOOLS="flutter:flut:🎯:Flutter SDK:check_flutter_installed:flutter/install_flutter.sh:install_flutter
dotnet:dot-net,.net,net:🔷:.NET SDK:check_dotnet_installed:dotnet/install_dotnet.sh:install_dotnet
emacs:emac:📝:Emacs + Doom Emacs:check_emacs_installed:emacs/install_emacs.sh:install_emacs
java8:java8,jdk8:☕:Java 8 OpenJDK:check_java8_installed:java/install_java.sh:install_java8
java11:java11,jdk11:☕:Java 11 OpenJDK:check_java11_installed:java/install_java.sh:install_java11
java17:java17,java-17,jdk17:☕:Java 17 OpenJDK:check_java17_installed:java/install_java.sh:install_java17
java21:java21,jdk21:☕:Java 21 OpenJDK:check_java21_installed:java/install_java.sh:install_java21
java25:java25,jdk25,java,jdk:☕:Java 25 OpenJDK:check_java25_installed:java/install_java.sh:install_java25
android-studio:androidstudio,android,studio,as:🤖:Android Studio:check_android_studio_installed:android/install_android_studio.sh:install_android_studio
android-tools:androidtools,adb,sdk,android-sdk:🔧:Outils Android (ADB, SDK):check_android_tools_installed:android/install_android_tools.sh:install_android_tools
android-licenses:android-license,licenses:📝:Accepter licences Android SDK:check_android_licenses_accepted:android/accept_android_licenses.sh:accept_android_licenses
docker::🐳:Docker & Docker Compose:check_docker_installed:docker/install_docker.sh:install_docker
brave:brave-browser:🌐:Brave Browser:check_brave_installed:brave/install_brave.sh:install_brave
cursor::💻:Cursor IDE:check_cursor_installed:cursor/install_cursor.sh:install_cursor
handbrake:hb,handbrake-cli:🎬:HandBrake (encodage vidéo):check_handbrake_installed:handbrake/install_handbrake.sh:install_handbrake
network-tools:net-tools,net-tools:🌐:Outils réseau (nslookup, dig, nmap, etc.):check_network_tools_installed:network-tools/install_network_tools.sh:install_network_tools
qemu:qemu-kvm,kvm:🖥️:QEMU/KVM (Virtualisation):check_qemu_installed:qemu/install_qemu.sh:install_qemu
ssh-config:ssh,ssh-setup:🔐:Configuration SSH automatique:check_ssh_configured:ssh/install_ssh_config.sh:install_ssh_config
cmake::🔧:CMake (système de build):check_cmake_installed:cmake/install_cmake.sh:install_cmake
gdb::🐛:GDB (GNU Debugger):check_gdb_installed:gdb/install_gdb.sh:install_gdb
c-tools:c,c-tools,gcc:🔧:Outils C (GCC, make):check_c_tools_installed:c/install_c.sh:install_c_tools
cpp-tools:c++,cpp,cpp-tools:⚙️:Outils C++ (G++, make, CMake):check_cpp_tools_installed:cpp/install_cpp.sh:install_cpp_tools
tor::🔒:Tor (anonymisation réseau):check_tor_installed:tor/install_tor.sh:install_tor
tor-browser:torbrowser,tor-browser:🌐:Tor Browser (navigateur anonyme):check_tor_browser_installed:tor/install_tor_browser.sh:install_tor_browser
tor-navigation:tor-nav,tor-navigation:🔐:Navigation Tor (avec/sans navigateur):check_tor_navigation_installed:tor/install_tor_navigation.sh:install_tor_navigation"
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                  INSTALLMAN - INSTALLATION MANAGER            ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
    }
    
    # Fonction pour obtenir le statut d'installation
    get_install_status() {
        tool_check="$1"
        install_status=$($tool_check 2>/dev/null)
        if [ "$install_status" = "installed" ]; then
            printf "${GREEN}[✓ Installé]${RESET}\n"
        else
            printf "${YELLOW}[✗ Non installé]${RESET}\n"
        fi
    }
    
    # Fonction pour parser une définition d'outil
    parse_tool_def() {
        tool_def="$1"
        field_num="$2"
        echo "$tool_def" | cut -d: -f"$field_num"
    }
    
    # Fonction pour trouver un outil par nom/alias
    find_tool() {
        search_term="$1"
        search_term=$(echo "$search_term" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        
        echo "$TOOLS" | while IFS= read -r tool_def; do
            if [ -z "$tool_def" ]; then
                continue
            fi
            
            tool_name=$(parse_tool_def "$tool_def" 1)
            tool_aliases_str=$(parse_tool_def "$tool_def" 2)
            
            # Vérifier si le terme correspond au nom principal
            if [ "$tool_name" = "$search_term" ]; then
                echo "$tool_def"
                return 0
            fi
            
            # Vérifier les alias (séparés par des virgules)
            if [ -n "$tool_aliases_str" ]; then
                echo "$tool_aliases_str" | tr ',' '\n' | while IFS= read -r alias; do
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
    
    # Fonction pour installer un outil depuis sa définition
    install_tool_from_def() {
        tool_def="$1"
        tool_name=$(parse_tool_def "$tool_def" 1)
        tool_desc=$(parse_tool_def "$tool_def" 4)
        module_file=$(parse_tool_def "$tool_def" 6)
        install_func=$(parse_tool_def "$tool_def" 7)
        
        full_module_path="$INSTALLMAN_MODULES_DIR/$module_file"
        
        if [ -f "$full_module_path" ]; then
            . "$full_module_path"
            if command -v "$install_func" >/dev/null 2>&1; then
                $install_func
            else
                printf "${RED}❌ Fonction d'installation %s non disponible${RESET}\n" "$install_func"
                sleep 2
            fi
        else
            printf "${RED}❌ Module %s non disponible: %s${RESET}\n" "$tool_desc" "$full_module_path"
            sleep 2
        fi
    }
    
    # Fonction pour afficher le menu de mise à jour
    show_update_menu() {
        show_header
        printf "${YELLOW}🔄 MISE À JOUR D'OUTILS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        # Lister les outils installés avec leurs versions
        printf "${BOLD}📦 Outils installés:${RESET}\n\n"
        index=1
        installed_tools_list=""
        
        echo "$TOOLS" | while IFS= read -r tool_def; do
            if [ -z "$tool_def" ]; then
                continue
            fi
            
            tool_check=$(parse_tool_def "$tool_def" 5)
            if [ -n "$tool_check" ] && command -v "$tool_check" >/dev/null 2>&1; then
                install_status=$($tool_check 2>/dev/null)
                
                if [ "$install_status" = "installed" ]; then
                    tool_emoji=$(parse_tool_def "$tool_def" 3)
                    tool_desc=$(parse_tool_def "$tool_def" 4)
                    
                    current_version="unknown"
                    latest_version="unknown"
                    if command -v get_current_version >/dev/null 2>&1; then
                        tool_name=$(parse_tool_def "$tool_def" 1)
                        current_version=$(get_current_version "$tool_name" 2>/dev/null || echo "unknown")
                        latest_version=$(get_latest_version "$tool_name" 2>/dev/null || echo "unknown")
                    fi
                    
                    # Vérifier si mise à jour disponible
                    update_indicator=""
                    if command -v is_update_available >/dev/null 2>&1; then
                        tool_name=$(parse_tool_def "$tool_def" 1)
                        if is_update_available "$tool_name" 2>/dev/null; then
                            update_indicator="${YELLOW}🆕${RESET}"
                        else
                            update_indicator="${GREEN}✓${RESET}"
                        fi
                    else
                        update_indicator="${GREEN}✓${RESET}"
                    fi
                    
                    printf "  %-3d %s %-30s ${CYAN}v%s${RESET} → ${GREEN}v%s${RESET} %s\n" \
                           "$index" "$tool_emoji" "$tool_desc" "$current_version" "$latest_version" "$update_indicator"
                    
                    if [ -z "$installed_tools_list" ]; then
                        installed_tools_list="$tool_def"
                    else
                        installed_tools_list="$installed_tools_list
$tool_def"
                    fi
                    index=$((index + 1))
                fi
            fi
        done
        
        if [ -z "$installed_tools_list" ]; then
            printf "${YELLOW}Aucun outil installé${RESET}\n"
            echo ""
            printf "Appuyez sur Entrée pour retourner au menu principal... "
            read dummy
            show_main_menu
            return 0
        fi
        
        echo ""
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choisir un outil à mettre à jour (numéro): "
        read update_choice
        update_choice=$(echo "$update_choice" | tr -d '[:space:]')
        
        if [ -z "$update_choice" ] || [ "$update_choice" = "0" ]; then
            show_main_menu
            return 0
        fi
        
        case "$update_choice" in
            [0-9]*)
                tool_index=$update_choice
                tool_count=0
                selected_tool=""
                echo "$installed_tools_list" | while IFS= read -r tool_def; do
                    tool_count=$((tool_count + 1))
                    if [ "$tool_count" -eq "$tool_index" ]; then
                        selected_tool="$tool_def"
                        break
                    fi
                done
                
                if [ -n "$selected_tool" ]; then
                    update_tool_from_def "$selected_tool"
                else
                    printf "${RED}❌ Numéro invalide: %s${RESET}\n" "$update_choice"
                    sleep 2
                    show_update_menu
                fi
                ;;
            *)
                printf "${RED}❌ Choix invalide${RESET}\n"
                sleep 2
                show_update_menu
                ;;
        esac
    }
    
    # Fonction pour mettre à jour un outil avec choix de version
    update_tool_from_def() {
        tool_def="$1"
        tool_name=$(parse_tool_def "$tool_def" 1)
        tool_desc=$(parse_tool_def "$tool_def" 4)
        module_file=$(parse_tool_def "$tool_def" 6)
        install_func=$(parse_tool_def "$tool_def" 7)
        
        show_header
        printf "${YELLOW}🔄 Mise à jour: %s${RESET}\n" "$tool_desc"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        # Obtenir la version actuelle
        current_version="unknown"
        if command -v get_current_version >/dev/null 2>&1; then
            current_version=$(get_current_version "$tool_name" 2>/dev/null || echo "unknown")
        fi
        printf "${CYAN}Version actuelle:${RESET} ${BOLD}%s${RESET}\n" "$current_version"
        
        # Obtenir les versions disponibles
        printf "\n${CYAN}Versions disponibles:${RESET}\n"
        available_versions="latest"
        if command -v get_available_versions >/dev/null 2>&1; then
            available_versions=$(get_available_versions "$tool_name" 2>/dev/null || echo "latest")
        fi
        
        latest_version=$(echo "$available_versions" | head -n1)
        
        if [ -n "$available_versions" ] && [ "$available_versions" != "latest" ]; then
            version_index=1
            versions_list=""
            echo "$available_versions" | while IFS= read -r version; do
                if [ -n "$version" ]; then
                    if [ "$version" = "$latest_version" ]; then
                        printf "  ${GREEN}%d.${RESET} ${BOLD}%s${RESET} ${GREEN}(dernière)${RESET}\n" "$version_index" "$version"
                    else
                        printf "  %d. %s\n" "$version_index" "$version"
                    fi
                    if [ -z "$versions_list" ]; then
                        versions_list="$version"
                    else
                        versions_list="$versions_list
$version"
                    fi
                    version_index=$((version_index + 1))
                fi
            done
        else
            printf "  ${GREEN}1.${RESET} ${BOLD}latest${RESET} ${GREEN}(dernière version)${RESET}\n"
            versions_list="latest"
        fi
        
        echo ""
        echo "0.  Annuler"
        echo ""
        printf "Choisir une version (numéro ou version exacte): "
        read version_choice
        version_choice=$(echo "$version_choice" | tr -d '[:space:]')
        
        if [ -z "$version_choice" ] || [ "$version_choice" = "0" ]; then
            show_update_menu
            return 0
        fi
        
        # Déterminer la version choisie
        selected_version=""
        case "$version_choice" in
            [0-9]*)
                version_index=$version_choice
                version_count=0
                echo "$versions_list" | while IFS= read -r version; do
                    version_count=$((version_count + 1))
                    if [ "$version_count" -eq "$version_index" ]; then
                        selected_version="$version"
                        break
                    fi
                done
                
                if [ -z "$selected_version" ]; then
                    printf "${RED}❌ Numéro invalide${RESET}\n"
                    sleep 2
                    update_tool_from_def "$tool_def"
                    return 1
                fi
                ;;
            *)
                # Version spécifique fournie
                selected_version="$version_choice"
                ;;
        esac
        
        # Confirmer la mise à jour
        echo ""
        printf "${YELLOW}⚠️  Mise à jour de %s${RESET}\n" "$tool_desc"
        printf "   ${CYAN}De:${RESET} %s\n" "$current_version"
        printf "   ${CYAN}Vers:${RESET} %s\n" "$selected_version"
        echo ""
        printf "Confirmer la mise à jour? (O/n): "
        read confirm
        confirm=${confirm:-O}
        
        case "$confirm" in
            [oO]*)
                # Exécuter la mise à jour
                full_module_path="$INSTALLMAN_MODULES_DIR/$module_file"
                
                if [ -f "$full_module_path" ]; then
                    . "$full_module_path"
                    
                    # Si la fonction d'installation supporte un paramètre de version, l'utiliser
                    if command -v "${install_func}_with_version" >/dev/null 2>&1; then
                        "${install_func}_with_version" "$selected_version"
                    else
                        # Réinstaller (les modules gèrent généralement la mise à jour via réinstallation)
                        printf "\n${CYAN}Mise à jour en cours...${RESET}\n\n"
                        $install_func
                    fi
                    
                    # Vérifier la nouvelle version
                    new_version="unknown"
                    if command -v get_current_version >/dev/null 2>&1; then
                        new_version=$(get_current_version "$tool_name" 2>/dev/null || echo "unknown")
                    fi
                    echo ""
                    if [ "$new_version" != "not_installed" ] && [ "$new_version" != "unknown" ]; then
                        printf "${GREEN}✅ Mise à jour terminée!${RESET}\n"
                        printf "${CYAN}Nouvelle version:${RESET} ${BOLD}%s${RESET}\n" "$new_version"
                    else
                        printf "${YELLOW}⚠️  Mise à jour terminée (version non détectable)${RESET}\n"
                    fi
                    
                    echo ""
                    printf "Appuyez sur Entrée pour continuer... "
                    read dummy
                    show_update_menu
                else
                    printf "${RED}❌ Module %s non disponible: %s${RESET}\n" "$tool_desc" "$full_module_path"
                    sleep 2
                    show_update_menu
                fi
                ;;
            *)
                printf "${YELLOW}Mise à jour annulée${RESET}\n"
                sleep 1
                show_update_menu
                ;;
        esac
    }
    
    # Fonction pour mettre à jour tous les outils installés
    update_all_tools() {
        show_header
        printf "${YELLOW}🔄 Mise à jour de tous les outils${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        tools_to_update_list=""
        
        # Trouver tous les outils installés qui ont des mises à jour disponibles
        echo "$TOOLS" | while IFS= read -r tool_def; do
            if [ -z "$tool_def" ]; then
                continue
            fi
            
            tool_check=$(parse_tool_def "$tool_def" 5)
            if [ -n "$tool_check" ] && command -v "$tool_check" >/dev/null 2>&1; then
                install_status=$($tool_check 2>/dev/null)
                
                if [ "$install_status" = "installed" ]; then
                    tool_name=$(parse_tool_def "$tool_def" 1)
                    if command -v is_update_available >/dev/null 2>&1 && is_update_available "$tool_name" 2>/dev/null; then
                        if [ -z "$tools_to_update_list" ]; then
                            tools_to_update_list="$tool_def"
                        else
                            tools_to_update_list="$tools_to_update_list
$tool_def"
                        fi
                    fi
                fi
            fi
        done
        
        tool_count=$(echo "$tools_to_update_list" | grep -c . || echo "0")
        if [ "$tool_count" -eq 0 ]; then
            printf "${GREEN}✅ Tous les outils sont à jour!${RESET}\n"
            echo ""
            printf "Appuyez sur Entrée pour retourner au menu principal... "
            read dummy
            show_main_menu
            return 0
        fi
        
        printf "${CYAN}Outils à mettre à jour:${RESET} %d\n" "$tool_count"
        echo ""
        echo "$tools_to_update_list" | while IFS= read -r tool_def; do
            if [ -z "$tool_def" ]; then
                continue
            fi
            tool_desc=$(parse_tool_def "$tool_def" 4)
            tool_name=$(parse_tool_def "$tool_def" 1)
            
            current_version="unknown"
            latest_version="unknown"
            if command -v get_current_version >/dev/null 2>&1; then
                current_version=$(get_current_version "$tool_name" 2>/dev/null || echo "unknown")
                latest_version=$(get_latest_version "$tool_name" 2>/dev/null || echo "unknown")
            fi
            printf "  • %s: ${CYAN}%s${RESET} → ${GREEN}%s${RESET}\n" "$tool_desc" "$current_version" "$latest_version"
        done
        
        echo ""
        printf "Mettre à jour tous ces outils? (O/n): "
        read confirm
        confirm=${confirm:-O}
        
        case "$confirm" in
            [oO]*)
                updated=0
                failed=0
                
                echo "$tools_to_update_list" | while IFS= read -r tool_def; do
                    if [ -z "$tool_def" ]; then
                        continue
                    fi
                    tool_desc=$(parse_tool_def "$tool_def" 4)
                    
                    echo ""
                    printf "${CYAN}Mise à jour de %s...${RESET}\n" "$tool_desc"
                    if update_tool_from_def "$tool_def" 2>/dev/null; then
                        updated=$((updated + 1))
                    else
                        failed=$((failed + 1))
                    fi
                done
                
                echo ""
                printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
                printf "${GREEN}✅ Mises à jour terminées!${RESET}\n"
                printf "   ${GREEN}Réussies:${RESET} %d\n" "$updated"
                if [ "$failed" -gt 0 ]; then
                    printf "   ${RED}Échouées:${RESET} %d\n" "$failed"
                fi
                echo ""
                printf "Appuyez sur Entrée pour retourner au menu principal... "
                read dummy
                show_main_menu
                ;;
            *)
                printf "${YELLOW}Mise à jour annulée${RESET}\n"
                sleep 1
                show_main_menu
                ;;
        esac
    }
    
    # Fonction pour afficher le menu de gestion des paquets
    show_package_manager_menu() {
        show_header
        printf "${YELLOW}📦 GESTIONNAIRES DE PAQUETS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        available_managers=""
        if command -v detect_package_managers >/dev/null 2>&1; then
            available_managers=$(detect_package_managers 2>/dev/null || echo "")
        fi
        distro="unknown"
        if command -v detect_distro >/dev/null 2>&1; then
            distro=$(detect_distro 2>/dev/null || echo "unknown")
        fi
        
        printf "${CYAN}Distribution:${RESET} ${BOLD}%s${RESET}\n" "$distro"
        printf "${CYAN}Gestionnaires:${RESET} %s\n" "$available_managers"
        echo ""
        echo "1. 🔍 Rechercher un paquet"
        echo "2. 📥 Installer un paquet"
        echo "3. 🗑️  Supprimer un paquet"
        echo "4. 📋 Lister les paquets installés"
        echo "5. ℹ️  Informations sur un paquet"
        echo "6. 🔧 Installer/Configurer les gestionnaires"
        echo ""
        echo "0. Retour"
        echo ""
        printf "Choix: "
        read choice
        
        case "$choice" in
            1) package_search_interactive ;;
            2) package_install_interactive ;;
            3) package_remove_interactive ;;
            4) package_list_interactive ;;
            5) package_info_interactive ;;
            6) install_package_managers ;;
            0) show_main_menu ;;
            *) show_package_manager_menu ;;
        esac
    }
    
    package_search_interactive() {
        show_header
        printf "${YELLOW}🔍 RECHERCHE${RESET}\n\n"
        printf "Paquet: "
        read pkg
        if [ -z "$pkg" ]; then
            show_package_manager_menu
            return
        fi
        echo ""
        if command -v search_package >/dev/null 2>&1; then
            search_package "$pkg"
        else
            printf "${YELLOW}⚠️  Fonction search_package non disponible${RESET}\n"
        fi
        echo ""
        printf "Appuyez sur Entrée... "
        read dummy
        show_package_manager_menu
    }
    
    package_install_interactive() {
        show_header
        printf "${YELLOW}📥 INSTALLATION${RESET}\n\n"
        printf "Paquet: "
        read pkg
        if [ -z "$pkg" ]; then
            show_package_manager_menu
            return
        fi
        echo ""
        if command -v install_package >/dev/null 2>&1; then
            if install_package "$pkg" "auto"; then
                printf "${GREEN}✅ Installé!${RESET}\n"
            else
                printf "${RED}❌ Échec${RESET}\n"
            fi
        else
            printf "${YELLOW}⚠️  Fonction install_package non disponible${RESET}\n"
        fi
        echo ""
        printf "Appuyez sur Entrée... "
        read dummy
        show_package_manager_menu
    }
    
    package_remove_interactive() {
        show_header
        printf "${YELLOW}🗑️  SUPPRESSION${RESET}\n\n"
        printf "Paquet: "
        read pkg
        if [ -z "$pkg" ]; then
            show_package_manager_menu
            return
        fi
        echo ""
        printf "Confirmer? (o/N): "
        read confirm
        case "$confirm" in
            [oO]*)
                if command -v remove_package >/dev/null 2>&1; then
                    remove_package "$pkg" "auto"
                else
                    printf "${YELLOW}⚠️  Fonction remove_package non disponible${RESET}\n"
                fi
                ;;
        esac
        echo ""
        printf "Appuyez sur Entrée... "
        read dummy
        show_package_manager_menu
    }
    
    package_list_interactive() {
        show_header
        printf "${YELLOW}📋 PAQUETS INSTALLÉS${RESET}\n\n"
        if command -v list_installed_packages >/dev/null 2>&1; then
            list_installed_packages "all" | less -R || list_installed_packages "all"
        else
            printf "${YELLOW}⚠️  Fonction list_installed_packages non disponible${RESET}\n"
        fi
        show_package_manager_menu
    }
    
    package_info_interactive() {
        show_header
        printf "${YELLOW}ℹ️  INFORMATIONS${RESET}\n\n"
        printf "Paquet: "
        read pkg
        if [ -z "$pkg" ]; then
            show_package_manager_menu
            return
        fi
        echo ""
        if command -v get_package_info >/dev/null 2>&1; then
            get_package_info "$pkg" "auto" | less -R || get_package_info "$pkg" "auto"
        else
            printf "${YELLOW}⚠️  Fonction get_package_info non disponible${RESET}\n"
        fi
        show_package_manager_menu
    }
    
    install_package_managers() {
        show_header
        printf "${YELLOW}🔧 INSTALLATION GESTIONNAIRES${RESET}\n\n"
        script="$DOTFILES_DIR/scripts/install/system/package_managers.sh"
        if [ -f "$script" ]; then
            bash "$script"
        else
            printf "${RED}Script non trouvé${RESET}\n"
        fi
        echo ""
        printf "Appuyez sur Entrée... "
        read dummy
        show_package_manager_menu
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        printf "${YELLOW}📦 INSTALLATION D'OUTILS ET APPLICATIONS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        # Organiser par catégories
        printf "${BOLD}💻 DÉVELOPPEMENT:${RESET}\n"
        index=1
        dev_tools="flutter dotnet emacs java8 java11 java17 java21 java25 android-studio android-tools docker cmake"
        
        for tool_name in $dev_tools; do
            echo "$TOOLS" | while IFS= read -r tool_def; do
                if [ -z "$tool_def" ]; then
                    continue
                fi
                current_tool_name=$(parse_tool_def "$tool_def" 1)
                if [ "$current_tool_name" = "$tool_name" ]; then
                    tool_emoji=$(parse_tool_def "$tool_def" 3)
                    tool_desc=$(parse_tool_def "$tool_def" 4)
                    tool_check=$(parse_tool_def "$tool_def" 5)
                    install_status=""
                    if [ -n "$tool_check" ] && command -v "$tool_check" >/dev/null 2>&1; then
                        install_status=$($tool_check 2>/dev/null)
                    fi
                    if [ "$install_status" = "installed" ]; then
                        status_str="${GREEN}[✓ Installé]${RESET}"
                    else
                        status_str="${YELLOW}[✗ Non installé]${RESET}"
                    fi
                    printf "  %-3d %s %-30s %s\n" "$index" "$tool_emoji" "$tool_desc" "$status_str"
                    index=$((index + 1))
                    break
                fi
            done
        done
        
        echo ""
        printf "${BOLD}🌐 APPLICATIONS:${RESET}\n"
        app_tools="brave cursor"
        for tool_name in $app_tools; do
            echo "$TOOLS" | while IFS= read -r tool_def; do
                if [ -z "$tool_def" ]; then
                    continue
                fi
                current_tool_name=$(parse_tool_def "$tool_def" 1)
                if [ "$current_tool_name" = "$tool_name" ]; then
                    tool_emoji=$(parse_tool_def "$tool_def" 3)
                    tool_desc=$(parse_tool_def "$tool_def" 4)
                    tool_check=$(parse_tool_def "$tool_def" 5)
                    install_status=""
                    if [ -n "$tool_check" ] && command -v "$tool_check" >/dev/null 2>&1; then
                        install_status=$($tool_check 2>/dev/null)
                    fi
                    if [ "$install_status" = "installed" ]; then
                        status_str="${GREEN}[✓ Installé]${RESET}"
                    else
                        status_str="${YELLOW}[✗ Non installé]${RESET}"
                    fi
                    printf "  %-3d %s %-30s %s\n" "$index" "$tool_emoji" "$tool_desc" "$status_str"
                    index=$((index + 1))
                    break
                fi
            done
        done
        
        echo ""
        printf "${BOLD}🎬 MULTIMÉDIA:${RESET}\n"
        media_tools="handbrake"
        for tool_name in $media_tools; do
            echo "$TOOLS" | while IFS= read -r tool_def; do
                if [ -z "$tool_def" ]; then
                    continue
                fi
                current_tool_name=$(parse_tool_def "$tool_def" 1)
                if [ "$current_tool_name" = "$tool_name" ]; then
                    tool_emoji=$(parse_tool_def "$tool_def" 3)
                    tool_desc=$(parse_tool_def "$tool_def" 4)
                    tool_check=$(parse_tool_def "$tool_def" 5)
                    install_status=""
                    if [ -n "$tool_check" ] && command -v "$tool_check" >/dev/null 2>&1; then
                        install_status=$($tool_check 2>/dev/null)
                    fi
                    if [ "$install_status" = "installed" ]; then
                        status_str="${GREEN}[✓ Installé]${RESET}"
                    else
                        status_str="${YELLOW}[✗ Non installé]${RESET}"
                    fi
                    printf "  %-3d %s %-30s %s\n" "$index" "$tool_emoji" "$tool_desc" "$status_str"
                    index=$((index + 1))
                    break
                fi
            done
        done
        
        echo ""
        printf "${BOLD}⚙️  CONFIGURATION ANDROID:${RESET}\n"
        android_config_tools="android-licenses"
        for tool_name in $android_config_tools; do
            echo "$TOOLS" | while IFS= read -r tool_def; do
                if [ -z "$tool_def" ]; then
                    continue
                fi
                current_tool_name=$(parse_tool_def "$tool_def" 1)
                if [ "$current_tool_name" = "$tool_name" ]; then
                    tool_emoji=$(parse_tool_def "$tool_def" 3)
                    tool_desc=$(parse_tool_def "$tool_def" 4)
                    tool_check=$(parse_tool_def "$tool_def" 5)
                    install_status=""
                    if [ -n "$tool_check" ] && command -v "$tool_check" >/dev/null 2>&1; then
                        install_status=$($tool_check 2>/dev/null)
                    fi
                    if [ "$install_status" = "installed" ]; then
                        status_str="${GREEN}[✓ Installé]${RESET}"
                    else
                        status_str="${YELLOW}[✗ Non installé]${RESET}"
                    fi
                    printf "  %-3d %s %-30s %s\n" "$index" "$tool_emoji" "$tool_desc" "$status_str"
                    index=$((index + 1))
                    break
                fi
            done
        done
        
        echo ""
        printf "${BOLD}🌐 RÉSEAU:${RESET}\n"
        network_tools="network-tools"
        for tool_name in $network_tools; do
            echo "$TOOLS" | while IFS= read -r tool_def; do
                if [ -z "$tool_def" ]; then
                    continue
                fi
                current_tool_name=$(parse_tool_def "$tool_def" 1)
                if [ "$current_tool_name" = "$tool_name" ]; then
                    tool_emoji=$(parse_tool_def "$tool_def" 3)
                    tool_desc=$(parse_tool_def "$tool_def" 4)
                    tool_check=$(parse_tool_def "$tool_def" 5)
                    install_status=""
                    if [ -n "$tool_check" ] && command -v "$tool_check" >/dev/null 2>&1; then
                        install_status=$($tool_check 2>/dev/null)
                    fi
                    if [ "$install_status" = "installed" ]; then
                        status_str="${GREEN}[✓ Installé]${RESET}"
                    else
                        status_str="${YELLOW}[✗ Non installé]${RESET}"
                    fi
                    printf "  %-3d %s %-30s %s\n" "$index" "$tool_emoji" "$tool_desc" "$status_str"
                    index=$((index + 1))
                    break
                fi
            done
        done
        
        echo ""
        printf "${BOLD}🖥️  SYSTÈME & VIRTUALISATION:${RESET}\n"
        sys_tools="qemu"
        for tool_name in $sys_tools; do
            echo "$TOOLS" | while IFS= read -r tool_def; do
                if [ -z "$tool_def" ]; then
                    continue
                fi
                current_tool_name=$(parse_tool_def "$tool_def" 1)
                if [ "$current_tool_name" = "$tool_name" ]; then
                    tool_emoji=$(parse_tool_def "$tool_def" 3)
                    tool_desc=$(parse_tool_def "$tool_def" 4)
                    tool_check=$(parse_tool_def "$tool_def" 5)
                    install_status=""
                    if [ -n "$tool_check" ] && command -v "$tool_check" >/dev/null 2>&1; then
                        install_status=$($tool_check 2>/dev/null)
                    fi
                    if [ "$install_status" = "installed" ]; then
                        status_str="${GREEN}[✓ Installé]${RESET}"
                    else
                        status_str="${YELLOW}[✗ Non installé]${RESET}"
                    fi
                    printf "  %-3d %s %-30s %s\n" "$index" "$tool_emoji" "$tool_desc" "$status_str"
                    index=$((index + 1))
                    break
                fi
            done
        done
        
        echo ""
        printf "${BOLD}🔄 MISE À JOUR:${RESET}\n"
        echo "  u.  Mettre à jour un outil"
        echo "  ua. Mettre à jour tous les outils installés"
        echo ""
        printf "${BOLD}📦 GESTIONNAIRES DE PAQUETS:${RESET}\n"
        echo "  p.  Gérer les paquets (pacman, yay, snap, flatpak, apt, dnf, npm)"
        echo "  ps. Rechercher un paquet"
        echo "  pi. Installer un paquet"
        echo "  pr. Supprimer un paquet"
        echo "  pl. Lister les paquets installés"
        echo ""
        echo "0.  Quitter"
        echo ""
        printf "${CYAN}💡 Tapez le nom de l'outil (ex: 'flutter', 'docker', 'brave') puis appuyez sur Entrée${RESET}\n"
        printf "${CYAN}   Ou tapez un numéro pour sélectionner par position${RESET}\n"
        printf "${CYAN}   Ou 'u' pour mettre à jour un outil${RESET}\n"
        echo ""
        printf "Choix: "
        read choice
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        # Traitement du choix
        if [ -z "$choice" ] || [ "$choice" = "0" ] || [ "$choice" = "quit" ] || [ "$choice" = "exit" ] || [ "$choice" = "q" ]; then
            return 0
        fi
        
        # Gérer les options de mise à jour
        case "$choice" in
            u|update)
                show_update_menu
                return 0
                ;;
            ua|update-all)
                update_all_tools
                return 0
                ;;
            p|packages)
                show_package_manager_menu
                return 0
                ;;
            ps|search)
                package_search_interactive
                return 0
                ;;
            pi|install)
                package_install_interactive
                return 0
                ;;
            pr|remove)
                package_remove_interactive
                return 0
                ;;
            pl|list)
                package_list_interactive
                return 0
                ;;
            [0-9]*)
                tool_index=$choice
                tool_count=0
                selected_tool=""
                echo "$TOOLS" | while IFS= read -r tool_def; do
                    if [ -z "$tool_def" ]; then
                        continue
                    fi
                    tool_count=$((tool_count + 1))
                    if [ "$tool_count" -eq "$tool_index" ]; then
                        selected_tool="$tool_def"
                        break
                    fi
                done
                
                if [ -n "$selected_tool" ]; then
                    install_tool_from_def "$selected_tool"
                else
                    printf "${RED}❌ Numéro invalide: %s${RESET}\n" "$choice"
                    sleep 2
                    show_main_menu
                fi
                ;;
            *)
                # Rechercher par nom/alias
                found_tool=$(find_tool "$choice")
                if [ -n "$found_tool" ]; then
                    install_tool_from_def "$found_tool"
                else
                    printf "${RED}❌ Outil non trouvé: '%s'${RESET}\n" "$choice"
                    echo ""
                    printf "${YELLOW}Outils disponibles:${RESET}\n"
                    echo "$TOOLS" | while IFS= read -r tool_def; do
                        if [ -z "$tool_def" ]; then
                            continue
                        fi
                        tool_name=$(parse_tool_def "$tool_def" 1)
                        echo "  - $tool_name"
                    done
                    echo ""
                    sleep 2
                    show_main_menu
                fi
                ;;
        esac
    }
    
    # Fonction pour installer un outil (utilisée par les arguments en ligne de commande)
    install_tool() {
        tool_name="$1"
        module_file="$2"
        install_func="$3"
        
        if [ -f "$module_file" ]; then
            . "$module_file"
            if command -v "$install_func" >/dev/null 2>&1; then
                $install_func
            else
                printf "${RED}❌ Fonction d'installation %s non disponible${RESET}\n" "$install_func"
                return 1
            fi
        else
            printf "${RED}❌ Module %s non disponible${RESET}\n" "$tool_name"
            return 1
        fi
    }
    
    # Si un argument est fourni, lancer directement le module
    if [ -n "$1" ]; then
        tool_arg=$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        
        # Gérer les commandes spéciales
        case "$tool_arg" in
            update|u)
                show_update_menu
                return 0
                ;;
            update-all|ua)
                update_all_tools
                return 0
                ;;
            packages|p)
                show_package_manager_menu
                return 0
                ;;
            search|ps)
                if [ -n "$2" ]; then
                    if command -v search_package >/dev/null 2>&1; then
                        search_package "$2"
                    else
                        printf "${YELLOW}⚠️  Fonction search_package non disponible${RESET}\n"
                    fi
                else
                    package_search_interactive
                fi
                return 0
                ;;
            install|pi)
                if [ -n "$2" ]; then
                    if command -v install_package >/dev/null 2>&1; then
                        install_package "$2" "auto"
                    else
                        printf "${YELLOW}⚠️  Fonction install_package non disponible${RESET}\n"
                    fi
                else
                    package_install_interactive
                fi
                return 0
                ;;
            remove|pr)
                if [ -n "$2" ]; then
                    if command -v remove_package >/dev/null 2>&1; then
                        remove_package "$2" "auto"
                    else
                        printf "${YELLOW}⚠️  Fonction remove_package non disponible${RESET}\n"
                    fi
                else
                    package_remove_interactive
                fi
                return 0
                ;;
            list|pl)
                package_list_interactive
                return 0
                ;;
            help|--help|-h|list)
                printf "${CYAN}${BOLD}INSTALLMAN - Outils disponibles:${RESET}\n"
                echo ""
                echo "$TOOLS" | while IFS= read -r tool_def; do
                    if [ -z "$tool_def" ]; then
                        continue
                    fi
                    tool_name=$(parse_tool_def "$tool_def" 1)
                    tool_emoji=$(parse_tool_def "$tool_def" 3)
                    tool_desc=$(parse_tool_def "$tool_def" 4)
                    printf "  ${GREEN}%s${RESET} %s - %s\n" "$tool_name" "$tool_emoji" "$tool_desc"
                done
                echo ""
                printf "${YELLOW}Usage:${RESET}\n"
                echo "  installman [tool-name]     - Installer directement un outil"
                echo "  installman                 - Menu interactif"
                echo "  installman update          - Menu de mise à jour"
                echo "  installman update-all      - Mettre à jour tous les outils"
                echo ""
                printf "${CYAN}Exemples:${RESET}\n"
                echo "  installman flutter"
                echo "  installman docker"
                echo "  installman cursor"
                echo "  installman update          - Mettre à jour un outil"
                echo "  installman update-all     - Mettre à jour tous les outils"
                ;;
            *)
                # Rechercher l'outil
                found_tool=$(find_tool "$tool_arg")
                if [ -n "$found_tool" ]; then
                    tool_desc=$(parse_tool_def "$found_tool" 4)
                    module_file=$(parse_tool_def "$found_tool" 6)
                    install_func=$(parse_tool_def "$found_tool" 7)
                    full_module_path="$INSTALLMAN_MODULES_DIR/$module_file"
                    install_tool "$tool_desc" "$full_module_path" "$install_func"
                else
                    printf "${RED}❌ Outil inconnu: '%s'${RESET}\n" "$1"
                    echo ""
                    printf "${YELLOW}Outils disponibles:${RESET}\n"
                    echo "$TOOLS" | while IFS= read -r tool_def; do
                        if [ -z "$tool_def" ]; then
                            continue
                        fi
                        tool_name=$(parse_tool_def "$tool_def" 1)
                        echo "  - $tool_name"
                    done
                    echo ""
                    echo "Usage: installman [tool-name]"
                    echo "   ou: install-tool [tool-name] (alias)"
                    echo "   ou: installman (menu interactif)"
                    echo "   ou: installman list (afficher la liste)"
                    return 1
                fi
                ;;
        esac
    else
        # Mode interactif
        show_main_menu
    fi
}
