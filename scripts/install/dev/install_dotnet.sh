#!/bin/bash

################################################################################
# Installation .NET SDK et outils
# Support: Arch Linux, Debian/Ubuntu, Fedora
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Installation .NET SDK et outils"

################################################################################
# DÉTECTION DE LA DISTRIBUTION
################################################################################
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

DISTRO=$(detect_distro)

################################################################################
# VÉRIFICATION SI DÉJÀ INSTALLÉ
################################################################################
if command -v dotnet &> /dev/null; then
    CURRENT_VERSION=$(dotnet --version 2>/dev/null || echo "unknown")
    log_info ".NET ${CURRENT_VERSION} est déjà installé"
    # Mode non-interactif: ne pas réinstaller si déjà présent
    if [ -z "$NON_INTERACTIVE" ]; then
        read -p "Réinstaller/mettre à jour? (o/N): " reinstall_choice
        if [[ ! "$reinstall_choice" =~ ^[oO]$ ]]; then
            log_info "Installation ignorée"
            exit 0
        fi
    else
        log_info "Mode non-interactif: .NET déjà installé, passage à la suite"
        exit 0
    fi
fi

################################################################################
# INSTALLATION SELON LA DISTRO
################################################################################
case "$DISTRO" in
    arch)
        log_section "Installation .NET (Arch Linux)"
        
        # Vérifier si yay est installé
        if ! command -v yay &> /dev/null; then
            log_warn "yay n'est pas installé. Installation nécessaire..."
            read -p "Installer yay maintenant? (o/n): " install_yay
            if [[ "$install_yay" =~ ^[oO]$ ]]; then
                bash "$SCRIPT_DIR/install/tools/install_yay.sh"
            else
                log_error "yay est requis pour installer .NET sur Arch Linux"
                exit 1
            fi
        fi
        
        log_info "Installation de .NET SDK via yay..."
        yay -S --noconfirm dotnet-sdk-bin dotnet-runtime-bin || {
            log_warn "Installation via yay échouée, tentative avec pacman..."
            sudo pacman -S --noconfirm dotnet-sdk dotnet-runtime || {
                log_error "Échec de l'installation"
                exit 1
            }
        }
        ;;
    debian)
        log_section "Installation .NET (Debian/Ubuntu)"
        
        # Ajouter le dépôt Microsoft
        log_info "Ajout du dépôt Microsoft..."
        wget https://packages.microsoft.com/config/debian/$(lsb_release -rs)/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
        sudo dpkg -i /tmp/packages-microsoft-prod.deb
        sudo apt update
        
        log_info "Installation de .NET SDK..."
        sudo apt install -y dotnet-sdk-8.0
        ;;
    fedora)
        log_section "Installation .NET (Fedora)"
        
        # Ajouter le dépôt Microsoft
        log_info "Ajout du dépôt Microsoft..."
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo dnf config-manager --add-repo https://packages.microsoft.com/config/fedora/$(rpm -E %fedora)/prod.repo
        
        log_info "Installation de .NET SDK..."
        sudo dnf install -y dotnet-sdk-8.0
        ;;
    *)
        log_error "Distribution non supportée: $DISTRO"
        log_info "Installation manuelle requise"
        log_info "Voir: https://dotnet.microsoft.com/download"
        exit 1
        ;;
esac

################################################################################
# VÉRIFICATION ET CONFIGURATION
################################################################################
if command -v dotnet &> /dev/null; then
    INSTALLED_VERSION=$(dotnet --version)
    log_info "✓ .NET ${INSTALLED_VERSION} installé avec succès"
    
    # Créer le répertoire pour les outils .NET
    DOTNET_TOOLS_DIR="$HOME/.dotnet/tools"
    mkdir -p "$DOTNET_TOOLS_DIR"
    
    log_info "Répertoire outils .NET: $DOTNET_TOOLS_DIR"
    log_info "Ce répertoire sera ajouté au PATH dans env.sh"
    
    # Afficher les informations
    echo ""
    log_info "Commandes utiles:"
    echo "  dotnet --version          # Version installée"
    echo "  dotnet --info             # Informations détaillées"
    echo "  dotnet tool list -g       # Outils globaux installés"
    echo "  dotnet tool install -g <tool>  # Installer un outil global"
else
    log_error ".NET n'a pas pu être installé correctement"
    exit 1
fi

log_info "✓ Installation .NET terminée"

