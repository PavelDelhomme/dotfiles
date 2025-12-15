#!/bin/zsh
# =============================================================================
# PACKAGE MANAGER UTILS - Utilitaires pour gérer les gestionnaires de paquets
# =============================================================================
# Description: Fonctions pour détecter et utiliser différents gestionnaires de paquets
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# =============================================================================
# DÉTECTION DU SYSTÈME ET GESTIONNAIRES DISPONIBLES
# =============================================================================

# DESC: Détecte la distribution Linux
# USAGE: detect_distro
# RETURNS: arch|debian|ubuntu|fedora|gentoo|unknown
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            arch|manjaro|endeavouros)
                echo "arch"
                ;;
            debian)
                echo "debian"
                ;;
            ubuntu)
                echo "ubuntu"
                ;;
            fedora|rhel|centos)
                echo "fedora"
                ;;
            gentoo)
                echo "gentoo"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    else
        echo "unknown"
    fi
}

# DESC: Détecte les gestionnaires de paquets disponibles
# USAGE: detect_package_managers
# RETURNS: Liste des gestionnaires disponibles (pacman,yay,snap,flatpak,apt,dpkg,dnf,rpm)
detect_package_managers() {
    local managers=()
    local distro=$(detect_distro)
    
    # Gestionnaires universels
    if command -v snap &>/dev/null; then
        managers+=("snap")
    fi
    
    if command -v flatpak &>/dev/null; then
        managers+=("flatpak")
    fi
    
    if command -v npm &>/dev/null; then
        managers+=("npm")
    fi
    
    # Gestionnaires spécifiques à la distribution
    case "$distro" in
        arch)
            if command -v pacman &>/dev/null; then
                managers+=("pacman")
            fi
            if command -v yay &>/dev/null; then
                managers+=("yay")
            fi
            if command -v pamac &>/dev/null; then
                managers+=("pamac")
            fi
            ;;
        debian|ubuntu)
            if command -v apt &>/dev/null; then
                managers+=("apt")
            fi
            if command -v dpkg &>/dev/null; then
                managers+=("dpkg")
            fi
            if command -v apt-get &>/dev/null; then
                managers+=("apt-get")
            fi
            ;;
        fedora)
            if command -v dnf &>/dev/null; then
                managers+=("dnf")
            fi
            if command -v rpm &>/dev/null; then
                managers+=("rpm")
            fi
            if command -v yum &>/dev/null; then
                managers+=("yum")
            fi
            ;;
        gentoo)
            if command -v emerge &>/dev/null; then
                managers+=("emerge")
            fi
            ;;
    esac
    
    echo "${managers[@]}"
}

# DESC: Vérifie si un gestionnaire est disponible
# USAGE: is_package_manager_available <manager>
# RETURNS: 0 si disponible, 1 sinon
is_package_manager_available() {
    local manager="$1"
    case "$manager" in
        pacman|yay|pamac|snap|flatpak|apt|apt-get|dpkg|dnf|rpm|yum|emerge|npm)
            command -v "$manager" &>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# =============================================================================
# FONCTIONS DE RECHERCHE
# =============================================================================

# DESC: Recherche un paquet dans tous les gestionnaires disponibles
# USAGE: search_package <package_name>
# RETURNS: Liste des résultats avec gestionnaire et statut
search_package() {
    local package="$1"
    local results=()
    
    # Pacman (Arch)
    if is_package_manager_available "pacman"; then
        if pacman -Ss "$package" 2>/dev/null | grep -q "$package"; then
            results+=("pacman:$package:available")
        fi
    fi
    
    # Yay (AUR)
    if is_package_manager_available "yay"; then
        if yay -Ss "$package" 2>/dev/null | grep -q "$package"; then
            results+=("yay:$package:available")
        fi
    fi
    
    # Snap
    if is_package_manager_available "snap"; then
        if snap search "$package" 2>/dev/null | grep -q "$package"; then
            results+=("snap:$package:available")
        fi
    fi
    
    # Flatpak
    if is_package_manager_available "flatpak"; then
        if flatpak search "$package" 2>/dev/null | grep -q "$package"; then
            results+=("flatpak:$package:available")
        fi
    fi
    
    # Apt (Debian/Ubuntu)
    if is_package_manager_available "apt"; then
        if apt search "$package" 2>/dev/null | grep -q "$package"; then
            results+=("apt:$package:available")
        fi
    fi
    
    # DNF (Fedora)
    if is_package_manager_available "dnf"; then
        if dnf search "$package" 2>/dev/null | grep -q "$package"; then
            results+=("dnf:$package:available")
        fi
    fi
    
    # NPM
    if is_package_manager_available "npm"; then
        if npm search "$package" 2>/dev/null | grep -q "$package"; then
            results+=("npm:$package:available")
        fi
    fi
    
    echo "${results[@]}"
}

# =============================================================================
# FONCTIONS DE VÉRIFICATION D'INSTALLATION
# =============================================================================

# DESC: Vérifie si un paquet est installé
# USAGE: is_package_installed <package_name> [manager]
# RETURNS: installed|not_installed|unknown
is_package_installed() {
    local package="$1"
    local manager="${2:-auto}"
    
    # Auto-détection du gestionnaire
    if [ "$manager" = "auto" ]; then
        # Essayer tous les gestionnaires
        if is_package_installed "$package" "pacman"; then
            echo "installed"
            return 0
        fi
        if is_package_installed "$package" "yay"; then
            echo "installed"
            return 0
        fi
        if is_package_installed "$package" "snap"; then
            echo "installed"
            return 0
        fi
        if is_package_installed "$package" "flatpak"; then
            echo "installed"
            return 0
        fi
        if is_package_installed "$package" "apt"; then
            echo "installed"
            return 0
        fi
        if is_package_installed "$package" "dnf"; then
            echo "installed"
            return 0
        fi
        if is_package_installed "$package" "npm"; then
            echo "installed"
            return 0
        fi
        echo "not_installed"
        return 1
    fi
    
    # Vérification spécifique par gestionnaire
    case "$manager" in
        pacman)
            pacman -Q "$package" &>/dev/null && echo "installed" || echo "not_installed"
            ;;
        yay)
            yay -Q "$package" &>/dev/null && echo "installed" || echo "not_installed"
            ;;
        snap)
            snap list "$package" &>/dev/null && echo "installed" || echo "not_installed"
            ;;
        flatpak)
            flatpak list | grep -q "$package" && echo "installed" || echo "not_installed"
            ;;
        apt|apt-get)
            dpkg -l | grep -q "^ii.*$package" && echo "installed" || echo "not_installed"
            ;;
        dnf|yum)
            rpm -q "$package" &>/dev/null && echo "installed" || echo "not_installed"
            ;;
        npm)
            npm list -g "$package" &>/dev/null && echo "installed" || echo "not_installed"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# =============================================================================
# FONCTIONS D'INSTALLATION
# =============================================================================

# DESC: Installe un paquet via le gestionnaire spécifié
# USAGE: install_package <package_name> <manager>
# RETURNS: 0 si succès, 1 si échec
install_package() {
    local package="$1"
    local manager="${2:-auto}"
    
    # Auto-détection du gestionnaire
    if [ "$manager" = "auto" ]; then
        local distro=$(detect_distro)
        case "$distro" in
            arch)
                if is_package_manager_available "yay"; then
                    manager="yay"
                elif is_package_manager_available "pacman"; then
                    manager="pacman"
                fi
                ;;
            debian|ubuntu)
                manager="apt"
                ;;
            fedora)
                manager="dnf"
                ;;
            *)
                manager="snap"  # Fallback universel
                ;;
        esac
    fi
    
    case "$manager" in
        pacman)
            sudo pacman -S --noconfirm "$package"
            ;;
        yay)
            yay -S --noconfirm "$package"
            ;;
        snap)
            sudo snap install "$package"
            ;;
        flatpak)
            flatpak install -y flathub "$package"
            ;;
        apt|apt-get)
            sudo apt-get update && sudo apt-get install -y "$package"
            ;;
        dnf)
            sudo dnf install -y "$package"
            ;;
        npm)
            npm install -g "$package"
            ;;
        *)
            echo "❌ Gestionnaire non supporté: $manager"
            return 1
            ;;
    esac
}

# =============================================================================
# FONCTIONS DE SUPPRESSION
# =============================================================================

# DESC: Supprime un paquet via le gestionnaire spécifié
# USAGE: remove_package <package_name> <manager>
# RETURNS: 0 si succès, 1 si échec
remove_package() {
    local package="$1"
    local manager="${2:-auto}"
    
    # Auto-détection du gestionnaire
    if [ "$manager" = "auto" ]; then
        # Essayer de trouver où le paquet est installé
        if is_package_installed "$package" "pacman"; then
            manager="pacman"
        elif is_package_installed "$package" "yay"; then
            manager="yay"
        elif is_package_installed "$package" "snap"; then
            manager="snap"
        elif is_package_installed "$package" "flatpak"; then
            manager="flatpak"
        elif is_package_installed "$package" "apt"; then
            manager="apt"
        elif is_package_installed "$package" "dnf"; then
            manager="dnf"
        elif is_package_installed "$package" "npm"; then
            manager="npm"
        else
            echo "❌ Paquet non trouvé: $package"
            return 1
        fi
    fi
    
    case "$manager" in
        pacman)
            sudo pacman -Rns --noconfirm "$package"
            ;;
        yay)
            yay -Rns --noconfirm "$package"
            ;;
        snap)
            sudo snap remove "$package"
            ;;
        flatpak)
            flatpak uninstall -y "$package"
            ;;
        apt|apt-get)
            sudo apt-get remove -y "$package"
            ;;
        dnf)
            sudo dnf remove -y "$package"
            ;;
        npm)
            npm uninstall -g "$package"
            ;;
        *)
            echo "❌ Gestionnaire non supporté: $manager"
            return 1
            ;;
    esac
}

# =============================================================================
# FONCTIONS D'INFORMATION
# =============================================================================

# DESC: Obtient des informations sur un paquet
# USAGE: get_package_info <package_name> [manager]
# RETURNS: Informations du paquet
get_package_info() {
    local package="$1"
    local manager="${2:-auto}"
    
    if [ "$manager" = "auto" ]; then
        # Essayer tous les gestionnaires
        for mgr in pacman yay snap flatpak apt dnf npm; do
            if is_package_installed "$package" "$mgr" | grep -q "installed"; then
                manager="$mgr"
                break
            fi
        done
    fi
    
    case "$manager" in
        pacman)
            pacman -Qi "$package" 2>/dev/null || echo "Paquet non installé"
            ;;
        yay)
            yay -Qi "$package" 2>/dev/null || echo "Paquet non installé"
            ;;
        snap)
            snap info "$package" 2>/dev/null || echo "Paquet non installé"
            ;;
        flatpak)
            flatpak info "$package" 2>/dev/null || echo "Paquet non installé"
            ;;
        apt)
            apt show "$package" 2>/dev/null || echo "Paquet non installé"
            ;;
        dnf)
            dnf info "$package" 2>/dev/null || echo "Paquet non installé"
            ;;
        npm)
            npm info "$package" 2>/dev/null || echo "Paquet non installé"
            ;;
        *)
            echo "Gestionnaire non supporté"
            ;;
    esac
}

# DESC: Liste tous les paquets installés pour un gestionnaire
# USAGE: list_installed_packages [manager]
# RETURNS: Liste des paquets installés
list_installed_packages() {
    local manager="${1:-all}"
    
    if [ "$manager" = "all" ]; then
        echo "=== Paquets installés ==="
        for mgr in pacman yay snap flatpak apt dnf npm; do
            if is_package_manager_available "$mgr"; then
                echo ""
                echo "--- $mgr ---"
                list_installed_packages "$mgr"
            fi
        done
        return 0
    fi
    
    case "$manager" in
        pacman)
            pacman -Q
            ;;
        yay)
            yay -Q
            ;;
        snap)
            snap list
            ;;
        flatpak)
            flatpak list
            ;;
        apt)
            dpkg -l | grep "^ii"
            ;;
        dnf)
            rpm -qa
            ;;
        npm)
            npm list -g --depth=0
            ;;
        *)
            echo "Gestionnaire non supporté"
            ;;
    esac
}

