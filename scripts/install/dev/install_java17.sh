#!/bin/bash

################################################################################
# Installation Java 17 OpenJDK
# Support: Arch Linux, Debian/Ubuntu, Fedora
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Installation Java 17 OpenJDK"

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
if command -v java &> /dev/null; then
    CURRENT_VERSION=$(java -version 2>&1 | head -n1 || echo "unknown")
    log_info "Java est déjà installé: $CURRENT_VERSION"
    
    # Vérifier si c'est Java 17
    if echo "$CURRENT_VERSION" | grep -q "17"; then
        log_info "Java 17 est déjà installé"
        read -p "Réinstaller quand même? (o/N): " reinstall_choice
        if [[ ! "$reinstall_choice" =~ ^[oO]$ ]]; then
            log_info "Installation ignorée"
            exit 0
        fi
    else
        log_warn "Version Java différente détectée"
        read -p "Installer Java 17 (l'ancienne version sera conservée)? (o/N): " install_choice
        if [[ ! "$install_choice" =~ ^[oO]$ ]]; then
            log_info "Installation ignorée"
            exit 0
        fi
    fi
fi

################################################################################
# INSTALLATION SELON LA DISTRO
################################################################################
case "$DISTRO" in
    arch)
        log_section "Installation Java 17 OpenJDK (Arch Linux)"
        log_info "Installation de jdk17-openjdk..."
        sudo pacman -S --noconfirm jdk17-openjdk || {
            log_error "Échec de l'installation"
            exit 1
        }
        
        # Configurer JAVA_HOME
        JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk"
        if [ -d "$JAVA_HOME_PATH" ]; then
            log_info "JAVA_HOME sera configuré dans env.sh: $JAVA_HOME_PATH"
        fi
        ;;
    debian)
        log_section "Installation Java 17 OpenJDK (Debian/Ubuntu)"
        log_info "Installation de openjdk-17-jdk..."
        sudo apt update
        sudo apt install -y openjdk-17-jdk || {
            log_error "Échec de l'installation"
            exit 1
        }
        
        # Configurer JAVA_HOME
        JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk"
        if [ -d "$JAVA_HOME_PATH" ]; then
            log_info "JAVA_HOME sera configuré dans env.sh: $JAVA_HOME_PATH"
        else
            # Chercher le chemin réel
            JAVA_HOME_PATH=$(update-alternatives --list java 2>/dev/null | head -n1 | sed 's|/bin/java||' || echo "/usr/lib/jvm/java-17-openjdk")
            log_info "JAVA_HOME sera configuré dans env.sh: $JAVA_HOME_PATH"
        fi
        ;;
    fedora)
        log_section "Installation Java 17 OpenJDK (Fedora)"
        log_info "Installation de java-17-openjdk-devel..."
        sudo dnf install -y java-17-openjdk-devel || {
            log_error "Échec de l'installation"
            exit 1
        }
        
        # Configurer JAVA_HOME
        JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk"
        if [ -d "$JAVA_HOME_PATH" ]; then
            log_info "JAVA_HOME sera configuré dans env.sh: $JAVA_HOME_PATH"
        fi
        ;;
    *)
        log_error "Distribution non supportée: $DISTRO"
        log_info "Installation manuelle requise"
        exit 1
        ;;
esac

################################################################################
# VÉRIFICATION ET CONFIGURATION
################################################################################
if command -v java &> /dev/null; then
    INSTALLED_VERSION=$(java -version 2>&1 | head -n1)
    log_info "✓ Java installé: $INSTALLED_VERSION"
    
    # Vérifier le chemin Java
    JAVA_BIN_PATH=$(which java)
    log_info "Java binaire: $JAVA_BIN_PATH"
    
    # Trouver JAVA_HOME
    if [ -d "/usr/lib/jvm/java-17-openjdk" ]; then
        JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk"
    elif [ -d "/usr/lib/jvm/java-17-openjdk-amd64" ]; then
        JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk-amd64"
    else
        # Chercher dans les alternatives
        JAVA_HOME_PATH=$(readlink -f "$JAVA_BIN_PATH" | sed 's|/bin/java||')
    fi
    
    if [ -d "$JAVA_HOME_PATH/bin" ]; then
        log_info "JAVA_HOME détecté: $JAVA_HOME_PATH"
        log_info "Ce chemin sera ajouté au PATH dans env.sh: $JAVA_HOME_PATH/bin"
    else
        log_warn "JAVA_HOME n'a pas pu être détecté automatiquement"
        log_info "Vous devrez le configurer manuellement dans env.sh"
    fi
else
    log_error "Java n'a pas pu être installé correctement"
    exit 1
fi

log_info "✓ Installation Java 17 terminée"

