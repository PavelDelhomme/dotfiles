#!/bin/zsh
# =============================================================================
# INSTALLATION JAVA 17 - Module installman
# =============================================================================
# Description: Installation de Java 17 OpenJDK avec configuration automatique
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
# INSTALLATION JAVA 17
# =============================================================================
# DESC: Installe Java 17 OpenJDK avec configuration automatique du PATH
# USAGE: install_java17
# EXAMPLE: install_java17
install_java17() {
    log_step "Installation de Java 17 OpenJDK..."
    
    local java_script="$INSTALL_DIR/install_java17.sh"
    
    if [ ! -f "$java_script" ]; then
        log_error "Script d'installation Java 17 introuvable: $java_script"
        return 1
    fi
    
    bash "$java_script" || {
        log_error "Échec de l'installation de Java 17"
        return 1
    }
    
    # Java est généralement installé dans /usr/lib/jvm/
    local java_path="/usr/lib/jvm/java-17-openjdk/bin"
    if [ -d "$java_path" ]; then
        add_path_to_env "$java_path" "Java 17 OpenJDK"
        log_info "✓ Java 17 installé et configuré avec succès!"
        log_info "💡 Rechargez votre shell (zshrc) pour utiliser Java 17"
        return 0
    fi
    
    return 1
}

