#!/bin/bash

################################################################################
# Installation Flutter SDK
# Support: Arch Linux, Debian/Ubuntu, Fedora
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Installation Flutter SDK"

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
if command -v flutter &> /dev/null; then
    CURRENT_VERSION=$(flutter --version 2>/dev/null | head -n1 || echo "unknown")
    log_info "Flutter est déjà installé: $CURRENT_VERSION"
    # Mode non-interactif: ne pas réinstaller si déjà présent
    if [ -z "$NON_INTERACTIVE" ]; then
        read -p "Réinstaller/mettre à jour? (o/N): " reinstall_choice
        if [[ ! "$reinstall_choice" =~ ^[oO]$ ]]; then
            log_info "Installation ignorée"
            exit 0
        fi
    else
        log_info "Mode non-interactif: Flutter déjà installé, passage à la suite"
        exit 0
    fi
fi

################################################################################
# INSTALLATION SELON LA DISTRO
################################################################################
case "$DISTRO" in
    arch)
        log_section "Installation Flutter (Arch Linux)"
        
        # Vérifier si yay est installé
        if ! command -v yay &> /dev/null; then
            log_warn "yay n'est pas installé. Installation nécessaire..."
            read -p "Installer yay maintenant? (o/n): " install_yay
            if [[ "$install_yay" =~ ^[oO]$ ]]; then
                bash "$SCRIPT_DIR/install/tools/install_yay.sh"
            else
                log_error "yay est requis pour installer Flutter sur Arch Linux"
                exit 1
            fi
        fi
        
        log_info "Installation de Flutter via yay..."
        yay -S --noconfirm flutter || {
            log_error "Échec de l'installation"
            exit 1
        }
        
        # Configurer les permissions
        log_info "Configuration des permissions Flutter..."
        sudo groupadd flutterusers 2>/dev/null || true
        sudo gpasswd -a $USER flutterusers 2>/dev/null || true
        if [ -d "/opt/flutter" ]; then
            sudo chown -R :flutterusers /opt/flutter 2>/dev/null || true
            sudo chmod -R g+w /opt/flutter/ 2>/dev/null || true
        fi
        ;;
    debian)
        log_section "Installation Flutter (Debian/Ubuntu)"
        
        FLUTTER_DIR="/opt/flutter"
        
        if [ -d "$FLUTTER_DIR" ]; then
            log_warn "Flutter existe déjà dans $FLUTTER_DIR"
            read -p "Supprimer et réinstaller? (o/N): " reinstall_choice
            if [[ "$reinstall_choice" =~ ^[oO]$ ]]; then
                sudo rm -rf "$FLUTTER_DIR"
            else
                log_info "Installation ignorée"
                exit 0
            fi
        fi
        
        log_info "Téléchargement de Flutter..."
        cd /tmp
        wget -q --show-progress https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz -O flutter.tar.xz || {
            log_error "Échec du téléchargement"
            exit 1
        }
        
        log_info "Extraction de Flutter..."
        sudo tar -xf flutter.tar.xz -C /opt/
        sudo chown -R $USER:$USER /opt/flutter
        
        rm flutter.tar.xz
        ;;
    fedora)
        log_section "Installation Flutter (Fedora)"
        
        FLUTTER_DIR="/opt/flutter"
        
        if [ -d "$FLUTTER_DIR" ]; then
            log_warn "Flutter existe déjà dans $FLUTTER_DIR"
            read -p "Supprimer et réinstaller? (o/N): " reinstall_choice
            if [[ "$reinstall_choice" =~ ^[oO]$ ]]; then
                sudo rm -rf "$FLUTTER_DIR"
            else
                log_info "Installation ignorée"
                exit 0
            fi
        fi
        
        log_info "Téléchargement de Flutter..."
        cd /tmp
        wget -q --show-progress https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz -O flutter.tar.xz || {
            log_error "Échec du téléchargement"
            exit 1
        }
        
        log_info "Extraction de Flutter..."
        sudo tar -xf flutter.tar.xz -C /opt/
        sudo chown -R $USER:$USER /opt/flutter
        
        rm flutter.tar.xz
        ;;
    *)
        log_error "Distribution non supportée: $DISTRO"
        log_info "Installation manuelle requise"
        log_info "Voir: https://docs.flutter.dev/get-started/install/linux"
        exit 1
        ;;
esac

################################################################################
# VÉRIFICATION ET CONFIGURATION
################################################################################
FLUTTER_BIN="/opt/flutter/bin/flutter"
if [ -f "$FLUTTER_BIN" ] || command -v flutter &> /dev/null; then
    log_info "✓ Flutter installé avec succès"
    
    # Exécuter flutter doctor
    log_info "Exécution de 'flutter doctor'..."
    "$FLUTTER_BIN" doctor || flutter doctor || true
    
    log_info "Répertoire Flutter: /opt/flutter/bin"
    log_info "Ce répertoire sera ajouté au PATH dans env.sh"
    
    # Créer le répertoire pub-cache
    PUB_CACHE_DIR="$HOME/.pub-cache/bin"
    mkdir -p "$PUB_CACHE_DIR"
    log_info "Répertoire pub-cache: $PUB_CACHE_DIR"
else
    log_error "Flutter n'a pas pu être installé correctement"
    exit 1
fi

log_info "✓ Installation Flutter terminée"

