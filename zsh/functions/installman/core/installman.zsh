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

# Charger les fonctions de gestion de paquets
[ -f "$INSTALLMAN_UTILS_DIR/package_manager.sh" ] && source "$INSTALLMAN_UTILS_DIR/package_manager.sh"

# TUI (taille terminal, pagination) et logging installman
[ -f "$DOTFILES_DIR/scripts/lib/tui_core.sh" ] && source "$DOTFILES_DIR/scripts/lib/tui_core.sh"
[ -f "$DOTFILES_DIR/scripts/lib/installman_log.sh" ] && source "$DOTFILES_DIR/scripts/lib/installman_log.sh"

# =============================================================================
# DÉFINITION DES OUTILS DISPONIBLES
# =============================================================================
# Format: "nom:alias1,alias2:emoji:description:check_function:module_file:install_function"
# -g : obligatoire car ce fichier est souvent sourcé depuis load_manager() (zshrc) ;
#      sans -g, declare -a rend TOOLS local à load_manager et le tableau disparaît au return.
typeset -ga TOOLS=(
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
    "chrome:google-chrome:🌐:Google Chrome:check_chrome_installed:chrome/install_chrome.sh:install_chrome"
    "cursor::💻:Cursor IDE:check_cursor_installed:cursor/install_cursor.sh:install_cursor"
    "handbrake:hb,handbrake-cli:🎬:HandBrake (encodage vidéo):check_handbrake_installed:handbrake/install_handbrake.sh:install_handbrake"
    "network-tools:net-tools,net-tools:🌐:Outils réseau (nslookup, dig, nmap, etc.):check_network_tools_installed:network-tools/install_network_tools.sh:install_network_tools"
    "qemu:qemu-kvm,kvm:🖥️:QEMU/KVM (Virtualisation):check_qemu_installed:qemu/install_qemu.sh:install_qemu"
    "ssh-config:ssh,ssh-setup:🔐:Configuration SSH automatique:check_ssh_configured:ssh/install_ssh_config.sh:install_ssh_config"
    "cmake::🔧:CMake (système de build):check_cmake_installed:cmake/install_cmake.sh:install_cmake"
    "gdb::🐛:GDB (GNU Debugger):check_gdb_installed:gdb/install_gdb.sh:install_gdb"
    "c-tools:c,c-tools,gcc:🔧:Outils C (GCC, make):check_c_tools_installed:c/install_c.sh:install_c_tools"
    "cpp-tools:c++,cpp,cpp-tools:⚙️:Outils C++ (G++, make, CMake):check_cpp_tools_installed:cpp/install_cpp.sh:install_cpp_tools"
    "tor::🔒:Tor (anonymisation réseau):check_tor_installed:tor/install_tor.sh:install_tor"
    "tor-browser:torbrowser,tor-browser:🌐:Tor Browser (navigateur anonyme):check_tor_browser_installed:tor/install_tor_browser.sh:install_tor_browser"
    "tor-navigation:tor-nav,tor-navigation:🔐:Navigation Tor (avec/sans navigateur):check_tor_navigation_installed:tor/install_tor_navigation.sh:install_tor_navigation"
    "wine::🍷:Wine (compatibilité Windows):check_wine_installed:wine/install_wine.sh:install_wine"
    "portproton:portproton,pp:🎮:PortProton (jeux Windows):check_portproton_installed:portproton/install_portproton.sh:install_portproton"
    "protonmail:proton-mail,protonmail:📧:Proton Mail (Bridge):check_protonmail_installed:protonmail/install_protonmail.sh:install_protonmail"
    "bluemail:bluemail,bluemail:📬:BlueMail:check_bluemail_installed:bluemail/install_bluemail.sh:install_bluemail"
    "snap:snapd,snap:📦:Snap (snapd):check_snap_installed:snap/install_snap.sh:install_snap"
    "nextcloud:nextcloud-client,sync-nextcloud:☁️:Nextcloud (synchronisation):check_nextcloud_installed:nextcloud/install_nextcloud.sh:install_nextcloud"
    "db-browser:sqlitebrowser,db-browser:🗄️:DB Browser for SQLite:check_db_browser_installed:db-browser/install_db_browser.sh:install_db_browser"
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

    # Statut + versions (installée et/ou dernière disponible) pour le menu principal
    get_install_status_with_versions() {
        local tool_check="$1"
        local tool_name="$2"
        local install_status=$($tool_check 2>/dev/null)
        local current="" latest="" version_info=""
        if [ "$install_status" = "installed" ]; then
            current=$(get_current_version "$tool_name" 2>/dev/null || echo "unknown")
            if [ -n "$current" ] && [ "$current" != "unknown" ] && [ "$current" != "not_installed" ]; then
                version_info=" ${CYAN}$current${RESET}"
            fi
            echo -e "${GREEN}[✓ Installé]${RESET}$version_info"
        else
            latest=$(get_latest_version "$tool_name" 2>/dev/null || echo "unknown")
            if [ -n "$latest" ] && [ "$latest" != "unknown" ] && [ "$latest" != "latest" ]; then
                version_info=" ${RESET}(dernière: ${CYAN}$latest${RESET})"
            fi
            echo -e "${YELLOW}[✗ Non installé]${RESET}$version_info"
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
    
    # =============================================================================
    # FONCTIONS DE GESTION DE PAQUETS
    # =============================================================================
    
    # DESC: Menu de gestion des paquets
    show_package_manager_menu() {
        show_header
        echo -e "${YELLOW}📦 GESTIONNAIRES DE PAQUETS${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        local available_managers=($(detect_package_managers))
        local distro=$(detect_distro)
        
        echo -e "${CYAN}Distribution:${RESET} ${BOLD}$distro${RESET}"
        echo -e "${CYAN}Gestionnaires:${RESET} ${available_managers[*]}"
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
        read -r choice
        
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
        echo -e "${YELLOW}🔍 RECHERCHE${RESET}\n"
        printf "Paquet: "
        read -r pkg
        [ -z "$pkg" ] && { show_package_manager_menu; return; }
        echo ""
        search_package "$pkg"
        echo ""
        read -p "Appuyez sur Entrée..."
        show_package_manager_menu
    }
    
    package_install_interactive() {
        show_header
        echo -e "${YELLOW}📥 INSTALLATION${RESET}\n"
        printf "Paquet: "
        read -r pkg
        [ -z "$pkg" ] && { show_package_manager_menu; return; }
        echo ""
        if install_package "$pkg" "auto"; then
            echo -e "${GREEN}✅ Installé!${RESET}"
        else
            echo -e "${RED}❌ Échec${RESET}"
        fi
        echo ""
        read -p "Appuyez sur Entrée..."
        show_package_manager_menu
    }
    
    package_remove_interactive() {
        show_header
        echo -e "${YELLOW}🗑️  SUPPRESSION${RESET}\n"
        printf "Paquet: "
        read -r pkg
        [ -z "$pkg" ] && { show_package_manager_menu; return; }
        echo ""
        read -p "Confirmer? (o/N): " confirm
        [[ "$confirm" =~ ^[oO]$ ]] && remove_package "$pkg" "auto"
        echo ""
        read -p "Appuyez sur Entrée..."
        show_package_manager_menu
    }
    
    package_list_interactive() {
        show_header
        echo -e "${YELLOW}📋 PAQUETS INSTALLÉS${RESET}\n"
        list_installed_packages "all" | less -R
        show_package_manager_menu
    }
    
    package_info_interactive() {
        show_header
        echo -e "${YELLOW}ℹ️  INFORMATIONS${RESET}\n"
        printf "Paquet: "
        read -r pkg
        [ -z "$pkg" ] && { show_package_manager_menu; return; }
        echo ""
        get_package_info "$pkg" "auto" | less -R
        show_package_manager_menu
    }
    
    install_package_managers() {
        show_header
        echo -e "${YELLOW}🔧 INSTALLATION GESTIONNAIRES${RESET}\n"
        local script="$DOTFILES_DIR/scripts/install/system/package_managers.sh"
        [ -f "$script" ] && bash "$script" || echo -e "${RED}Script non trouvé${RESET}"
        echo ""
        read -p "Appuyez sur Entrée..."
        show_package_manager_menu
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
    
    # Liste des outils installman (ligne de commande : installman list / installman help)
    print_installman_tools_catalog() {
        echo -e "${CYAN}${BOLD}INSTALLMAN - Outils disponibles:${RESET}"
        echo ""
        for tool_def in "${TOOLS[@]}"; do
            IFS=':' read -rA tool_parts <<< "$tool_def"
            local tool_name="${tool_parts[1]}"
            local tool_emoji="${tool_parts[3]}"
            local tool_desc="${tool_parts[4]}"
            echo "  ${GREEN}$tool_name${RESET} $tool_emoji - $tool_desc"
        done
    }
    
    # Ordre d'affichage du menu (par catégorie) — utilisé pour la numérotation
    build_menu_order() {
        local order_names=(
            "flutter" "dotnet" "emacs" "java8" "java11" "java17" "java21" "java25"
            "android-studio" "android-tools" "docker" "cmake" "gdb" "c-tools" "cpp-tools"
            "brave" "chrome" "cursor" "handbrake" "db-browser"
            "wine" "portproton"
            "protonmail" "bluemail"
            "snap" "nextcloud"
            "android-licenses" "network-tools" "qemu" "ssh-config"
            "tor" "tor-browser" "tor-navigation"
        )
        local menu_list=()
        for name in "${order_names[@]}"; do
            for tool_def in "${TOOLS[@]}"; do
                local parts=("${(@s/:/)tool_def}")
                [ ${#parts[@]} -lt 7 ] && continue
                if [ "${parts[1]}" = "$name" ]; then
                    menu_list+=("$tool_def")
                    break
                fi
            done
        done
        # Ajouter tout outil non encore dans la liste
        for tool_def in "${TOOLS[@]}"; do
            local parts=("${(@s/:/)tool_def}")
            [ ${#parts[@]} -lt 7 ] && continue
            local name="${parts[1]}"
            if [[ " ${order_names[*]} " != *" $name "* ]]; then
                menu_list+=("$tool_def")
            fi
        done
        echo "${(F)menu_list}"
    }
    
    # Fonction pour installer un outil (avec log)
    install_tool_from_def() {
        local tool_def="$1"
        IFS=':' read -rA tool_parts <<< "$tool_def"
        local tool_name="${tool_parts[1]}"
        local tool_desc="${tool_parts[4]}"
        local module_file="${tool_parts[6]}"
        local install_func="${tool_parts[7]}"
        local full_module_path="$INSTALLMAN_MODULES_DIR/$module_file"
        if [ "$tool_name" = "network-tools" ]; then
            if [ -f "$INSTALLMAN_MODULES_DIR/network-tools/install_network_tools.sh" ]; then
                source "$INSTALLMAN_MODULES_DIR/network-tools/install_network_tools.sh"
                install_network_tools_menu
            else
                echo -e "${RED}❌ Module réseau introuvable${RESET}"
            fi
            return 0
        fi
        if [ -f "$full_module_path" ]; then
            source "$full_module_path"
            $install_func
            local ret=$?
            if type log_installman_action &>/dev/null; then
                [ $ret -eq 0 ] && log_installman_action "install" "$tool_name" "success" "" || log_installman_action "install" "$tool_name" "failed" "exit code $ret"
            fi
        else
            echo -e "${RED}❌ Module $tool_desc non disponible: $full_module_path${RESET}"
            type log_installman_action &>/dev/null && log_installman_action "install" "$tool_name" "failed" "module not found"
            sleep 2
        fi
    }
    
    # Menu principal adaptatif (pagination si terminal petit)
    show_main_menu() {
        local menu_order=("${(@f)$(build_menu_order)}")
        menu_order=("${(@)menu_order:#}")
        local total=${#menu_order[@]}
        local per_page=15
        if type tui_menu_height &>/dev/null; then
            per_page=$(tui_menu_height 14)
            [ -z "$per_page" ] || [ "$per_page" -lt 5 ] && per_page=15
        fi
        local total_pages=$(( (total + per_page - 1) / per_page ))
        local page=0
        
        while true; do
            show_header
            echo -e "${YELLOW}📦 INSTALLATION D'OUTILS ET APPLICATIONS${RESET}"
            echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
            
            local start=$(( page * per_page + 1 ))
            local end=$(( (page + 1) * per_page ))
            [ $end -gt $total ] && end=$total
            
            for (( i = start; i <= end; i++ )); do
                local tool_def="${menu_order[$i]}"
                local parts=("${(@s/:/)tool_def}")
                [ ${#parts[@]} -lt 7 ] && continue
                local tool_name="${parts[1]}" tool_emoji="${parts[3]}" tool_desc="${parts[4]}" tool_check="${parts[5]}"
                if [ "$tool_name" = "tor" ]; then
                    echo ""
                    echo -e "${BOLD}🔒 Suite Tor${RESET} (anonymisation, navigateur dédié, navigation)"
                fi
                local install_status=$(get_install_status_with_versions "$tool_check" "$tool_name")
                printf "  %-3s %s %-30s %s\n" "$i." "$tool_emoji" "$tool_desc" "$install_status"
            done
            
            echo ""
            echo -e "${BOLD}  u.${RESET} Mise à jour   ${BOLD}ua.${RESET} Mise à jour tout   ${BOLD}p.${RESET} Paquets   ${BOLD}list${RESET} outils   ${BOLD}pl${RESET} paquets   ${BOLD}check-urls${RESET}   ${BOLD}logs${RESET}"
            echo -e "  ${BOLD}0.${RESET} Quitter"
            if [ $total_pages -gt 1 ]; then
                echo -e "${CYAN}  --- Page $((page+1))/$total_pages (n=suivant p=précédant) ---${RESET}"
            fi
            echo ""
            printf "Choix: "
            read -r choice
            choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
            choice="${choice%%.}"
            
            if [ "$choice" = "n" ] && [ $total_pages -gt 1 ]; then
                page=$(( page + 1 ))
                [ $page -ge $total_pages ] && page=$(( total_pages - 1 ))
                continue
            fi
            if [ "$choice" = "p" ] && [ $total_pages -gt 1 ]; then
                page=$(( page - 1 ))
                [ $page -lt 0 ] && page=0
                continue
            fi
            
            if [ -z "$choice" ] || [ "$choice" = "0" ] || [ "$choice" = "quit" ] || [ "$choice" = "exit" ] || [ "$choice" = "q" ]; then
                return 0
            fi
            if [ "$choice" = "u" ] || [ "$choice" = "update" ]; then
                show_update_menu
                return 0
            fi
            if [ "$choice" = "ua" ] || [ "$choice" = "update-all" ]; then
                update_all_tools
                return 0
            fi
            if [ "$choice" = "p" ] || [ "$choice" = "packages" ]; then
                show_package_manager_menu
                return 0
            fi
            if [ "$choice" = "ps" ] || [ "$choice" = "search" ]; then
                package_search_interactive
                return 0
            fi
            if [ "$choice" = "pi" ] || [ "$choice" = "install" ]; then
                package_install_interactive
                return 0
            fi
            if [ "$choice" = "pr" ] || [ "$choice" = "remove" ]; then
                package_remove_interactive
                return 0
            fi
            if [ "$choice" = "list" ] || [ "$choice" = "ls" ] || [ "$choice" = "tools" ]; then
                print_installman_tools_catalog
                echo ""
                read "?Appuyez sur Entrée pour revenir au menu..."
                continue
            fi
            if [ "$choice" = "pl" ]; then
                package_list_interactive
                return 0
            fi
            if [ "$choice" = "check-urls" ] || [ "$choice" = "urls" ] || [ "$choice" = "checkurls" ]; then
                url_script="$DOTFILES_DIR/scripts/install/check_download_urls.sh"
                if [ -f "$url_script" ]; then
                    if bash "$url_script" 2>&1; then
                        type log_installman_action &>/dev/null && log_installman_action "check-urls" "" "success" ""
                    else
                        type log_installman_action &>/dev/null && log_installman_action "check-urls" "" "failed" "script exit non-zero"
                    fi
                else
                    echo -e "${RED}Script introuvable${RESET}"
                    type log_installman_action &>/dev/null && log_installman_action "check-urls" "" "failed" "script not found"
                fi
                echo ""
                read "?Appuyez sur Entrée pour continuer..."
                continue
            fi
            if [ "$choice" = "logs" ]; then
                type show_installman_logs &>/dev/null && show_installman_logs 80 || true
                echo ""
                read "?Appuyez sur Entrée pour continuer..."
                continue
            fi
            
            if [[ "$choice" =~ ^[0-9]+$ ]]; then
                local tool_index=$((choice))
                if [ $tool_index -ge 1 ] && [ $tool_index -le $total ]; then
                    install_tool_from_def "${menu_order[$tool_index]}"
                else
                    echo -e "${RED}❌ Numéro invalide: $choice${RESET}"
                    sleep 2
                    continue
                fi
            else
                local found_tool=$(find_tool "$choice")
                if [ -n "$found_tool" ]; then
                    install_tool_from_def "$found_tool"
                else
                    echo -e "${RED}❌ Outil non trouvé: '$choice'${RESET}"
                    echo ""
                    for tool_def in "${TOOLS[@]}"; do
                        IFS=':' read -rA tool_parts <<< "$tool_def"
                        echo "  - ${tool_parts[1]}"
                    done
                    echo ""
                    sleep 2
                    continue
                fi
            fi
            echo ""
            read "?Appuyez sur Entrée pour revenir au menu..."
        done
    }
    
    # Fonction pour installer un outil (utilisée par les arguments en ligne de commande)
    install_tool() {
        local tool_desc="$1"
        local module_file="$2"
        local install_func="$3"
        local tool_name="${4:-}"  # optionnel, pour le log
        
        if [ -f "$module_file" ]; then
            source "$module_file"
            $install_func
            local ret=$?
            if type log_installman_action &>/dev/null && [ -n "$tool_name" ]; then
                [ $ret -eq 0 ] && log_installman_action "install" "$tool_name" "success" "" || log_installman_action "install" "$tool_name" "failed" "exit $ret"
            fi
            return $ret
        else
            echo -e "${RED}❌ Module $tool_desc non disponible${RESET}"
            type log_installman_action &>/dev/null && log_installman_action "install" "$tool_name" "failed" "module not found"
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
        
        if [ "$tool_arg" = "packages" ] || [ "$tool_arg" = "p" ]; then
            show_package_manager_menu
            return 0
        fi
        
        if [ "$tool_arg" = "search" ] || [ "$tool_arg" = "ps" ]; then
            if [ -n "$2" ]; then
                package_search_interactive "$2"
            else
                package_search_interactive
            fi
            return 0
        fi
        
        if [ "$tool_arg" = "install" ] || [ "$tool_arg" = "pi" ]; then
            if [ -n "$2" ]; then
                package_install_interactive "$2"
            else
                package_install_interactive
            fi
            return 0
        fi
        
        if [ "$tool_arg" = "remove" ] || [ "$tool_arg" = "pr" ]; then
            if [ -n "$2" ]; then
                package_remove_interactive "$2"
            else
                package_remove_interactive
            fi
            return 0
        fi
        
        # pl = liste des paquets système (less + sous-menu paquets), pas confondre avec installman list
        if [ "$tool_arg" = "pl" ]; then
            package_list_interactive
            return 0
        fi
        
        if [ "$tool_arg" = "check-urls" ] || [ "$tool_arg" = "urls" ] || [ "$tool_arg" = "checkurls" ]; then
            local url_script="$DOTFILES_DIR/scripts/install/check_download_urls.sh"
            if [ -f "$url_script" ]; then
                if bash "$url_script" 2>&1; then
                    type log_installman_action &>/dev/null && log_installman_action "check-urls" "" "success" ""
                else
                    type log_installman_action &>/dev/null && log_installman_action "check-urls" "" "failed" "script exit non-zero"
                fi
            else
                echo -e "${RED}Script introuvable: $url_script${RESET}"
                type log_installman_action &>/dev/null && log_installman_action "check-urls" "" "failed" "script not found"
            fi
            return 0
        fi
        
        # Rechercher l'outil
        local found_tool=$(find_tool "$tool_arg")
        if [ -n "$found_tool" ]; then
            IFS=':' read -rA tool_parts <<< "$found_tool"
            local tool_name="${tool_parts[1]}"
            local tool_desc="${tool_parts[4]}"
            local module_file="${tool_parts[6]}"
            local install_func="${tool_parts[7]}"
            local full_module_path="$INSTALLMAN_MODULES_DIR/$module_file"
            install_tool "$tool_desc" "$full_module_path" "$install_func" "$tool_name"
        elif [ "$tool_arg" = "list" ] || [ "$tool_arg" = "help" ] || [ "$tool_arg" = "--help" ] || [ "$tool_arg" = "-h" ]; then
            print_installman_tools_catalog
            if [ "$tool_arg" = "list" ]; then
                echo ""
                echo -e "${YELLOW}Astuce:${RESET} installman help pour l’usage complet ; installman pl pour les paquets système (less)."
                return 0
            fi
            echo ""
            echo -e "${YELLOW}Usage:${RESET}"
            echo "  installman [tool-name]     - Installer directement un outil"
            echo "  installman                 - Menu interactif"
            echo "  installman list            - Liste des outils installman (sans menu)"
            echo "  installman update          - Menu de mise à jour"
            echo "  installman update-all      - Mettre à jour tous les outils"
            echo "  installman pl              - Paquets installés (less, puis menu paquets)"
            echo "  installman check-urls      - Vérifier les URLs de téléchargement (sans installer)"
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
            echo "   ou: installman list (outils)   ou: installman pl (paquets système)"
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
