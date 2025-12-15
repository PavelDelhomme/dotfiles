#!/bin/zsh
# =============================================================================
# DISTRO DETECT - Détection de la distribution Linux
# =============================================================================
# Description: Fonction pour détecter la distribution Linux
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# =============================================================================
# DÉTECTION DE LA DISTRIBUTION
# =============================================================================
# DESC: Détecte la distribution Linux actuelle
# USAGE: detect_distro
# EXAMPLE: distro=$(detect_distro)
detect_distro() {
    # Détection basée sur /etc/os-release (méthode standard)
    if [ -f /etc/os-release ]; then
        local id=$(grep -E '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
        local id_like=$(grep -E '^ID_LIKE=' /etc/os-release | cut -d'=' -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]' || echo "")
        
        # Manjaro (basé sur Arch)
        if [ "$id" = "manjaro" ] || echo "$id_like" | grep -q "manjaro"; then
            echo "manjaro"
            return 0
        fi
        
        # Arch Linux
        if [ "$id" = "arch" ] || [ "$id" = "archlinux" ] || echo "$id_like" | grep -q "arch"; then
            echo "arch"
            return 0
        fi
        
        # Debian/Ubuntu
        if [ "$id" = "debian" ] || [ "$id" = "ubuntu" ] || echo "$id_like" | grep -q "debian"; then
            echo "$id"
            return 0
        fi
        
        # Fedora
        if [ "$id" = "fedora" ] || echo "$id_like" | grep -q "fedora"; then
            echo "fedora"
            return 0
        fi
        
        # Gentoo
        if [ "$id" = "gentoo" ]; then
            echo "gentoo"
            return 0
        fi
        
        # Alpine
        if [ "$id" = "alpine" ]; then
            echo "alpine"
            return 0
        fi
        
        # openSUSE
        if [ "$id" = "opensuse-leap" ] || [ "$id" = "opensuse-tumbleweed" ] || echo "$id" | grep -q "opensuse"; then
            echo "opensuse"
            return 0
        fi
        
        # CentOS
        if [ "$id" = "centos" ]; then
            echo "centos"
            return 0
        fi
    fi
    
    # Fallback: détection basée sur les fichiers de release
    if [ -f /etc/arch-release ]; then
        # Vérifier si c'est Manjaro
        if [ -f /etc/manjaro-release ] || grep -q "Manjaro" /etc/arch-release 2>/dev/null; then
            echo "manjaro"
        else
            echo "arch"
        fi
    elif [ -f /etc/debian_version ]; then
        if [ -f /etc/lsb-release ]; then
            local distro_id=$(grep DISTRIB_ID /etc/lsb-release | cut -d'=' -f2 | tr '[:upper:]' '[:lower:]')
            if [ "$distro_id" = "ubuntu" ]; then
                echo "ubuntu"
            else
                echo "debian"
            fi
        else
            echo "debian"
        fi
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    elif [ -f /etc/gentoo-release ]; then
        echo "gentoo"
    elif [ -f /etc/alpine-release ]; then
        echo "alpine"
    elif [ -f /etc/SuSE-release ] || [ -f /etc/os-release ] && grep -q "SUSE" /etc/os-release 2>/dev/null; then
        echo "opensuse"
    elif [ -f /etc/centos-release ]; then
        echo "centos"
    else
        echo "unknown"
    fi
}

