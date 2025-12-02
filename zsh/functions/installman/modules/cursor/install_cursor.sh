#!/bin/zsh
# =============================================================================
# INSTALLATION CURSOR - Module installman
# =============================================================================
# Description: Installation de Cursor IDE
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
INSTALL_SCRIPT="$SCRIPTS_DIR/install/apps/install_cursor.sh"

# =============================================================================
# INSTALLATION CURSOR
# =============================================================================
# DESC: Installe Cursor IDE
# USAGE: install_cursor
# EXAMPLE: install_cursor
install_cursor() {
    log_step "Installation de Cursor IDE..."
    
    # Vérifier si déjà installé
    if command -v cursor &>/dev/null; then
        log_info "Cursor est déjà installé"
        read -p "Réinstaller? (o/N): " reinstall
        if [[ ! "$reinstall" =~ ^[oO]$ ]]; then
            return 0
        fi
    fi
    
    if [ -f "$INSTALL_SCRIPT" ]; then
        bash "$INSTALL_SCRIPT" || {
            log_error "Échec de l'installation de Cursor"
            return 1
        }
    else
        log_error "Script d'installation Cursor introuvable: $INSTALL_SCRIPT"
        return 1
    fi
    
    log_info "✓ Cursor installé avec succès!"
    return 0
}

