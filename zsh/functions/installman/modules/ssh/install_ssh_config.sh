#!/bin/bash
# =============================================================================
# INSTALL SSH CONFIG - Module installman
# =============================================================================
# Description: Configure automatiquement SSH avec mot de passe depuis .env
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger les utilitaires
INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"

# Charger les fonctions utilitaires
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"

# Chemins
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SSHMAN_MODULES_DIR="$DOTFILES_DIR/zsh/functions/sshman/modules"
CONFIGMAN_MODULES_DIR="$DOTFILES_DIR/zsh/functions/configman/modules/ssh"

# =============================================================================
# CONFIGURATION SSH AUTOMATIQUE
# =============================================================================
# DESC: Configure automatiquement SSH avec mot de passe depuis .env
# USAGE: install_ssh_config
# EXAMPLE: install_ssh_config
install_ssh_config() {
    log_step "Configuration SSH automatique..."
    
    # Essayer d'abord sshman, puis configman en fallback
    local script_path="$SSHMAN_MODULES_DIR/ssh_auto_setup.sh"
    
    if [ ! -f "$script_path" ]; then
        script_path="$CONFIGMAN_MODULES_DIR/ssh_auto_setup.sh"
    fi
    
    if [ -f "$script_path" ]; then
        log_info "Lancement de la configuration SSH automatique..."
        bash "$script_path"
        if [ $? -eq 0 ]; then
            log_success "✓ Configuration SSH terminée avec succès!"
            log_info "💡 Utilisez 'sshman' pour gérer vos connexions SSH"
            return 0
        else
            log_error "Échec de la configuration SSH"
            return 1
        fi
    else
        log_error "Script ssh_auto_setup.sh non trouvé"
        log_info "Vérifiez votre installation dotfiles"
        return 1
    fi
}

