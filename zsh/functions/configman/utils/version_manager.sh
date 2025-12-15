#!/bin/zsh
# =============================================================================
# VERSION MANAGER - Gestionnaire de versions pour configman
# =============================================================================
# Description: Fonctions pour gérer les versions de Node, Python, Java, etc.
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# =============================================================================
# GESTION DE VERSIONS NODE/NPM
# =============================================================================

# DESC: Liste les versions Node disponibles
# USAGE: list_node_versions
list_node_versions() {
    if command -v nvm &>/dev/null; then
        nvm ls-remote --lts 2>/dev/null | tail -20
    elif command -v n &>/dev/null; then
        n ls 2>/dev/null || echo "Utilisez: n ls-remote pour voir les versions disponibles"
    else
        echo "⚠️  NVM ou n non installé"
        echo "💡 Installez avec: installman nvm"
    fi
}

# DESC: Installe une version spécifique de Node
# USAGE: install_node_version <version>
install_node_version() {
    local version="$1"
    if [ -z "$version" ]; then
        echo "❌ Version requise"
        return 1
    fi
    
    if command -v nvm &>/dev/null; then
        nvm install "$version"
        nvm use "$version"
        nvm alias default "$version"
    elif command -v n &>/dev/null; then
        n "$version"
    else
        echo "❌ NVM ou n non installé"
        return 1
    fi
}

# DESC: Active une version de Node
# USAGE: activate_node_version <version>
activate_node_version() {
    local version="$1"
    if [ -z "$version" ]; then
        echo "❌ Version requise"
        return 1
    fi
    
    if command -v nvm &>/dev/null; then
        nvm use "$version"
    elif command -v n &>/dev/null; then
        n "$version"
    else
        echo "❌ NVM ou n non installé"
        return 1
    fi
}

# DESC: Obtient la version Node actuelle
# USAGE: get_current_node_version
get_current_node_version() {
    if command -v node &>/dev/null; then
        node --version 2>/dev/null | sed 's/v//'
    else
        echo "not_installed"
    fi
}

# =============================================================================
# GESTION DE VERSIONS PYTHON
# =============================================================================

# DESC: Liste les versions Python disponibles
# USAGE: list_python_versions
list_python_versions() {
    if command -v pyenv &>/dev/null; then
        pyenv install --list 2>/dev/null | grep -E "^\s*[0-9]+\.[0-9]+\.[0-9]+$" | tail -20
    else
        echo "⚠️  pyenv non installé"
        echo "💡 Installez avec: installman pyenv"
    fi
}

# DESC: Installe une version spécifique de Python
# USAGE: install_python_version <version>
install_python_version() {
    local version="$1"
    if [ -z "$version" ]; then
        echo "❌ Version requise"
        return 1
    fi
    
    if command -v pyenv &>/dev/null; then
        pyenv install "$version"
        pyenv global "$version"
    else
        echo "❌ pyenv non installé"
        return 1
    fi
}

# DESC: Active une version de Python
# USAGE: activate_python_version <version>
activate_python_version() {
    local version="$1"
    if [ -z "$version" ]; then
        echo "❌ Version requise"
        return 1
    fi
    
    if command -v pyenv &>/dev/null; then
        pyenv global "$version"
    else
        echo "❌ pyenv non installé"
        return 1
    fi
}

# DESC: Obtient la version Python actuelle
# USAGE: get_current_python_version
get_current_python_version() {
    if command -v python3 &>/dev/null; then
        python3 --version 2>/dev/null | awk '{print $2}'
    elif command -v python &>/dev/null; then
        python --version 2>/dev/null | awk '{print $2}'
    else
        echo "not_installed"
    fi
}

# =============================================================================
# GESTION DE VERSIONS JAVA
# =============================================================================

# DESC: Liste les versions Java installées
# USAGE: list_java_versions
list_java_versions() {
    if command -v java &>/dev/null; then
        # Arch Linux avec archlinux-java
        if command -v archlinux-java &>/dev/null; then
            archlinux-java status 2>/dev/null
        # Alternatives système
        elif [ -d /usr/lib/jvm ]; then
            ls -1 /usr/lib/jvm 2>/dev/null | grep -E "java-[0-9]+|jdk-[0-9]+" || echo "Aucune version Java trouvée"
        else
            java -version 2>&1 | head -n1
        fi
    else
        echo "⚠️  Java non installé"
        echo "💡 Installez avec: installman java17 (ou java8, java11, java21, java25)"
    fi
}

# DESC: Active une version de Java
# USAGE: activate_java_version <version>
activate_java_version() {
    local version="$1"
    if [ -z "$version" ]; then
        echo "❌ Version requise"
        return 1
    fi
    
    # Arch Linux
    if command -v archlinux-java &>/dev/null; then
        archlinux-java set "java-$version-openjdk" 2>/dev/null || \
        archlinux-java set "jdk-$version-openjdk" 2>/dev/null || \
        echo "❌ Version Java $version non trouvée"
    # Alternatives système
    elif command -v update-alternatives &>/dev/null; then
        sudo update-alternatives --set java "/usr/lib/jvm/java-$version-openjdk/bin/java" 2>/dev/null || \
        echo "❌ Version Java $version non trouvée"
    else
        echo "❌ Système de gestion Java non disponible"
        return 1
    fi
}

# DESC: Obtient la version Java actuelle
# USAGE: get_current_java_version
get_current_java_version() {
    if command -v java &>/dev/null; then
        java -version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || \
        java -version 2>&1 | head -n1 | grep -oE '[0-9]+' | head -n1
    else
        echo "not_installed"
    fi
}

# =============================================================================
# FONCTION GÉNÉRIQUE DE GESTION DE VERSIONS
# =============================================================================

# DESC: Menu interactif de gestion de versions
# USAGE: version_manager_menu
version_manager_menu() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    while true; do
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║              GESTIONNAIRE DE VERSIONS                          ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        
        echo -e "${YELLOW}📊 Versions actuelles:${RESET}"
        echo -e "  Node.js:   ${GREEN}$(get_current_node_version)${RESET}"
        echo -e "  Python:    ${GREEN}$(get_current_python_version)${RESET}"
        echo -e "  Java:      ${GREEN}$(get_current_java_version)${RESET}"
        echo ""
        
        echo -e "${BOLD}Options:${RESET}"
        echo "1.  📦 Node.js - Gérer les versions"
        echo "2.  🐍 Python - Gérer les versions"
        echo "3.  ☕ Java - Gérer les versions"
        echo ""
        echo "0.  Retour"
        echo ""
        printf "Choix: "
        read -r choice
        
        case "$choice" in
            1)
                node_version_menu
                ;;
            2)
                python_version_menu
                ;;
            3)
                java_version_menu
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${RED}❌ Choix invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

# DESC: Menu de gestion Node.js
node_version_menu() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local CYAN='\033[0;36m'
    local RESET='\033[0m'
    
    while true; do
        clear
        echo -e "${CYAN}📦 GESTION DES VERSIONS NODE.JS${RESET}\n"
        echo -e "Version actuelle: ${GREEN}$(get_current_node_version)${RESET}"
        echo ""
        echo "1.  Lister les versions disponibles"
        echo "2.  Installer une version"
        echo "3.  Activer une version"
        echo ""
        echo "0.  Retour"
        echo ""
        printf "Choix: "
        read -r choice
        
        case "$choice" in
            1)
                echo ""
                list_node_versions
                echo ""
                read -p "Appuyez sur Entrée..."
                ;;
            2)
                echo ""
                printf "Version à installer (ex: 20.10.0): "
                read -r version
                install_node_version "$version"
                echo ""
                read -p "Appuyez sur Entrée..."
                ;;
            3)
                echo ""
                printf "Version à activer (ex: 20.10.0): "
                read -r version
                activate_node_version "$version"
                echo ""
                read -p "Appuyez sur Entrée..."
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${RED}❌ Choix invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

# DESC: Menu de gestion Python
python_version_menu() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local CYAN='\033[0;36m'
    local RESET='\033[0m'
    
    while true; do
        clear
        echo -e "${CYAN}🐍 GESTION DES VERSIONS PYTHON${RESET}\n"
        echo -e "Version actuelle: ${GREEN}$(get_current_python_version)${RESET}"
        echo ""
        echo "1.  Lister les versions disponibles"
        echo "2.  Installer une version"
        echo "3.  Activer une version"
        echo ""
        echo "0.  Retour"
        echo ""
        printf "Choix: "
        read -r choice
        
        case "$choice" in
            1)
                echo ""
                list_python_versions
                echo ""
                read -p "Appuyez sur Entrée..."
                ;;
            2)
                echo ""
                printf "Version à installer (ex: 3.12.0): "
                read -r version
                install_python_version "$version"
                echo ""
                read -p "Appuyez sur Entrée..."
                ;;
            3)
                echo ""
                printf "Version à activer (ex: 3.12.0): "
                read -r version
                activate_python_version "$version"
                echo ""
                read -p "Appuyez sur Entrée..."
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${RED}❌ Choix invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

# DESC: Menu de gestion Java
java_version_menu() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local CYAN='\033[0;36m'
    local RESET='\033[0m'
    
    while true; do
        clear
        echo -e "${CYAN}☕ GESTION DES VERSIONS JAVA${RESET}\n"
        echo -e "Version actuelle: ${GREEN}$(get_current_java_version)${RESET}"
        echo ""
        echo "1.  Lister les versions installées"
        echo "2.  Activer une version"
        echo ""
        echo "0.  Retour"
        echo ""
        printf "Choix: "
        read -r choice
        
        case "$choice" in
            1)
                echo ""
                list_java_versions
                echo ""
                read -p "Appuyez sur Entrée..."
                ;;
            2)
                echo ""
                printf "Version à activer (ex: 17, 21): "
                read -r version
                activate_java_version "$version"
                echo ""
                read -p "Appuyez sur Entrée..."
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${RED}❌ Choix invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

