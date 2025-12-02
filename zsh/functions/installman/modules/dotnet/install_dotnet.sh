#!/bin/zsh
# =============================================================================
# INSTALLATION DOTNET - Module installman
# =============================================================================
# Description: Installation de .NET SDK avec configuration automatique
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger les utilitaires
INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"

# Charger les fonctions utilitaires
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/path_utils.sh" ] && source "$INSTALLMAN_UTILS_DIR/path_utils.sh"

# Chemins
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"
INSTALL_DIR="$SCRIPTS_DIR/install/dev"
ENV_FILE="$DOTFILES_DIR/zsh/env.sh"

# =============================================================================
# INSTALLATION DOTNET
# =============================================================================
# DESC: Installe .NET SDK avec configuration automatique du PATH
# USAGE: install_dotnet
# EXAMPLE: install_dotnet
install_dotnet() {
    log_step "Installation de .NET SDK..."
    
    local dotnet_script="$INSTALL_DIR/install_dotnet.sh"
    
    if [ ! -f "$dotnet_script" ]; then
        log_error "Script d'installation .NET introuvable: $dotnet_script"
        return 1
    fi
    
    bash "$dotnet_script" || {
        log_error "Échec de l'installation de .NET"
        return 1
    }
    
    # Ajouter .NET tools au PATH
    local dotnet_tools="$HOME/.dotnet/tools"
    if [ -d "$dotnet_tools" ]; then
        add_path_to_env "$dotnet_tools" ".NET Tools"
        log_info "✓ .NET installé et configuré avec succès!"
        log_info "💡 Rechargez votre shell (zshrc) pour utiliser .NET"
        return 0
    fi
    
    return 1
}

