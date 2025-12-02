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
    if [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    else
        echo "unknown"
    fi
}

