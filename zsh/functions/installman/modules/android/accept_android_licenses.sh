#!/bin/zsh
# =============================================================================
# ACCEPTATION LICENCES ANDROID SDK - Module installman
# =============================================================================
# Description: Accepter automatiquement les licences Android SDK
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
SCRIPTS_DIR="$DOTFILES_DIR/scripts"
ACCEPT_LICENSES_SCRIPT="$SCRIPTS_DIR/install/dev/accept_android_licenses.sh"

# =============================================================================
# ACCEPTATION LICENCES ANDROID SDK
# =============================================================================
# DESC: Accepte automatiquement toutes les licences Android SDK
# USAGE: accept_android_licenses
# EXAMPLE: accept_android_licenses
accept_android_licenses() {
    log_step "Acceptation des licences Android SDK..."
    
    # Détecter ANDROID_HOME
    local ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
    if [ ! -d "$ANDROID_HOME" ]; then
        log_error "ANDROID_HOME non trouvé: $ANDROID_HOME"
        log_info "Installez d'abord Android SDK avec: installman android-tools"
        return 1
    fi
    
    export ANDROID_HOME
    export ANDROID_SDK_ROOT="$ANDROID_HOME"
    
    # Trouver sdkmanager
    local SDKMANAGER=""
    if [ -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
        SDKMANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
    elif [ -f "$ANDROID_HOME/tools/bin/sdkmanager" ]; then
        SDKMANAGER="$ANDROID_HOME/tools/bin/sdkmanager"
    elif command -v sdkmanager &>/dev/null; then
        SDKMANAGER=$(command -v sdkmanager)
    else
        log_error "sdkmanager non trouvé dans $ANDROID_HOME"
        log_info "Installez d'abord Android SDK avec: installman android-tools"
        return 1
    fi
    
    log_step "Acceptation des licences avec sdkmanager..."
    log_info "sdkmanager trouvé: $SDKMANAGER"
    
    # Accepter toutes les licences automatiquement
    log_step "Accepter toutes les licences (automatique)..."
    
    # Méthode 1: Utiliser yes pour répondre automatiquement à toutes les questions
    local license_output
    license_output=$(yes | "$SDKMANAGER" --licenses 2>&1) || {
        log_warn "Méthode automatique échouée, tentative alternative..."
        
        # Méthode 2: Utiliser un heredoc pour accepter toutes les licences
        # On accepte jusqu'à 50 licences (suffisant pour tous les composants)
        local yes_answers=""
        for i in {1..50}; do
            yes_answers="${yes_answers}y\n"
        done
        
        printf "%b" "$yes_answers" | "$SDKMANAGER" --licenses > /tmp/android_licenses.log 2>&1 || {
            log_error "Échec de l'acceptation des licences"
            log_info "Essayez manuellement: sdkmanager --licenses"
            log_info "Ou utilisez le script: bash $SCRIPTS_DIR/install/dev/accept_android_licenses.sh"
            return 1
        }
    }
    
    log_info "✓ Licences acceptées"
    
    # Vérifier que les licences sont acceptées
    if [ -d "$ANDROID_HOME/licenses" ]; then
        local license_count=$(find "$ANDROID_HOME/licenses" -name "*.txt" 2>/dev/null | wc -l)
        if [ "$license_count" -gt 0 ]; then
            log_info "✓ $license_count licence(s) acceptée(s)"
        else
            log_warn "Aucune licence trouvée dans $ANDROID_HOME/licenses"
        fi
    fi
    
    # Installer les composants requis (platforms et build-tools)
    log_step "Installation des composants Android SDK requis..."
    local platforms=("platforms;android-34" "platforms;android-33" "platforms;android-32")
    local build_tools=("build-tools;34.0.0" "build-tools;33.0.2")
    
    for platform in "${platforms[@]}"; do
        log_step "Installation de $platform..."
        "$SDKMANAGER" "$platform" > /tmp/android_sdk_install.log 2>&1 || log_warn "Échec installation $platform (peut déjà être installé)"
    done
    
    for build_tool in "${build_tools[@]}"; do
        log_step "Installation de $build_tool..."
        "$SDKMANAGER" "$build_tool" > /tmp/android_sdk_install.log 2>&1 || log_warn "Échec installation $build_tool (peut déjà être installé)"
    done
    
    log_info "✓ Toutes les licences Android SDK sont acceptées!"
    log_info "💡 Vous pouvez maintenant compiler vos projets Flutter/Android"
    log_info "💡 Pour vérifier: flutter doctor"
    return 0
}

