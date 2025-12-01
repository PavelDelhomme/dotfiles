#!/bin/bash

################################################################################
# Installation Emacs et Doom Emacs
# Support: Arch Linux, Debian/Ubuntu, Fedora
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Installation Emacs et Doom Emacs"

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
if command -v emacs &> /dev/null; then
    CURRENT_VERSION=$(emacs --version 2>/dev/null | head -n1 || echo "unknown")
    log_info "Emacs est déjà installé: $CURRENT_VERSION"
    read -p "Réinstaller/mettre à jour? (o/N): " reinstall_choice
    if [[ ! "$reinstall_choice" =~ ^[oO]$ ]]; then
        log_info "Installation ignorée"
        exit 0
    fi
fi

################################################################################
# INSTALLATION SELON LA DISTRO
################################################################################
case "$DISTRO" in
    arch)
        log_section "Installation Emacs (Arch Linux)"
        log_info "Installation de Emacs..."
        sudo pacman -S --noconfirm emacs || {
            log_error "Échec de l'installation"
            exit 1
        }
        ;;
    debian)
        log_section "Installation Emacs (Debian/Ubuntu)"
        log_info "Installation de Emacs..."
        sudo apt update
        sudo apt install -y emacs || {
            log_error "Échec de l'installation"
            exit 1
        }
        ;;
    fedora)
        log_section "Installation Emacs (Fedora)"
        log_info "Installation de Emacs..."
        sudo dnf install -y emacs || {
            log_error "Échec de l'installation"
            exit 1
        }
        ;;
    *)
        log_error "Distribution non supportée: $DISTRO"
        log_info "Installation manuelle requise"
        exit 1
        ;;
esac

################################################################################
# INSTALLATION DOOM EMACS (OPTIONNEL)
################################################################################
if command -v emacs &> /dev/null; then
    EMACS_VERSION=$(emacs --version 2>/dev/null | head -n1)
    log_info "✓ Emacs installé: $EMACS_VERSION"
    
    echo ""
    log_info "Souhaitez-vous installer Doom Emacs ?"
    log_info "Doom Emacs est une configuration Emacs moderne et performante"
    read -p "Installer Doom Emacs? (o/N): " install_doom
    
    if [[ "$install_doom" =~ ^[oO]$ ]]; then
        log_section "Installation Doom Emacs"
        
        EMACS_DIR="$HOME/.emacs.d"
        DOOM_DIR="$HOME/.doom.d"
        
        # Vérifier si Doom est déjà installé
        if [ -d "$EMACS_DIR" ] && [ -f "$EMACS_DIR/bin/doom" ]; then
            log_info "Doom Emacs est déjà installé"
            read -p "Réinstaller? (o/N): " reinstall_doom
            if [[ ! "$reinstall_doom" =~ ^[oO]$ ]]; then
                log_info "Installation Doom ignorée"
            else
                rm -rf "$EMACS_DIR" "$DOOM_DIR"
            fi
        fi
        
        if [ ! -d "$EMACS_DIR" ] || [ ! -f "$EMACS_DIR/bin/doom" ]; then
            log_info "Clonage de Doom Emacs..."
            git clone --depth 1 https://github.com/doomemacs/doomemacs "$EMACS_DIR" || {
                log_error "Échec du clonage"
                exit 1
            }
            
            log_info "Installation de Doom..."
            "$EMACS_DIR/bin/doom" install --yes || {
                log_warn "Installation Doom terminée avec des avertissements"
            }
            
            log_info "Répertoire Doom: $EMACS_DIR/bin"
            log_info "Ce répertoire sera ajouté au PATH dans env.sh"
        fi
    fi
else
    log_error "Emacs n'a pas pu être installé correctement"
    exit 1
fi

log_info "✓ Installation Emacs terminée"

