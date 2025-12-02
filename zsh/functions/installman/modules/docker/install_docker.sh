#!/bin/zsh
# =============================================================================
# INSTALLATION DOCKER - Module installman
# =============================================================================
# Description: Installation de Docker & Docker Compose avec Buildx
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger les utilitaires
INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"

# Charger les fonctions utilitaires
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/distro_detect.sh" ] && source "$INSTALLMAN_UTILS_DIR/distro_detect.sh"

# Chemins
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"
INSTALL_SCRIPT="$SCRIPTS_DIR/install/dev/install_docker.sh"

# =============================================================================
# INSTALLATION DOCKER
# =============================================================================
# DESC: Installe Docker & Docker Compose avec Buildx
# USAGE: install_docker
# EXAMPLE: install_docker
install_docker() {
    log_step "Installation de Docker & Docker Compose..."
    
    # Vérifier si déjà installé
    if command -v docker &>/dev/null; then
        log_info "Docker est déjà installé: $(docker --version)"
        read -p "Réinstaller? (o/N): " reinstall
        if [[ ! "$reinstall" =~ ^[oO]$ ]]; then
            return 0
        fi
    fi
    
    if [ -f "$INSTALL_SCRIPT" ]; then
        bash "$INSTALL_SCRIPT" || {
            log_error "Échec de l'installation de Docker"
            return 1
        }
    else
        log_error "Script d'installation Docker introuvable: $INSTALL_SCRIPT"
        return 1
    fi
    
    log_info "✓ Docker installé et configuré avec succès!"
    log_info "💡 Vérifiez avec: docker --version"
    return 0
}

