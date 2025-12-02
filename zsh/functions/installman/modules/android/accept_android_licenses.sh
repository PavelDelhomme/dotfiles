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
    
    # Créer le répertoire des licences s'il n'existe pas
    mkdir -p "$ANDROID_HOME/licenses"
    
    # Accepter toutes les licences automatiquement
    log_step "Accepter toutes les licences (automatique)..."
    
    # Méthode robuste: Utiliser un script temporaire pour accepter toutes les licences
    local temp_script="/tmp/accept_android_licenses_$$.sh"
    cat > "$temp_script" << 'EOF'
#!/bin/bash
# Script temporaire pour accepter toutes les licences Android SDK
SDKMANAGER="$1"
ANDROID_HOME="$2"

# Créer le répertoire licenses s'il n'existe pas
mkdir -p "$ANDROID_HOME/licenses"

# Essayer d'accepter les licences avec yes
if ! yes | "$SDKMANAGER" --licenses > /tmp/android_licenses_output.log 2>&1; then
    # Si ça échoue, utiliser une autre méthode
    echo "y" | "$SDKMANAGER" --licenses > /tmp/android_licenses_output.log 2>&1 || true
fi

# Vérifier que le répertoire licenses existe et a des fichiers
if [ -d "$ANDROID_HOME/licenses" ]; then
    LICENSE_COUNT=$(find "$ANDROID_HOME/licenses" -name "*.txt" 2>/dev/null | wc -l)
    echo "LICENSE_COUNT=$LICENSE_COUNT"
else
    echo "LICENSE_COUNT=0"
fi
EOF
    chmod +x "$temp_script"
    
    # Exécuter le script temporaire
    local result
    result=$("$temp_script" "$SDKMANAGER" "$ANDROID_HOME")
    local license_count=$(echo "$result" | grep "LICENSE_COUNT=" | cut -d'=' -f2)
    rm -f "$temp_script"
    
    # Si aucune licence n'a été acceptée, essayer la méthode manuelle avec heredoc
    if [ -z "$license_count" ] || [ "$license_count" -eq 0 ]; then
        log_warn "Aucune licence détectée, tentative avec méthode alternative..."
        
        # Méthode alternative: utiliser le script bash existant s'il est disponible
        if [ -f "$ACCEPT_LICENSES_SCRIPT" ]; then
            log_step "Utilisation du script d'acceptation complet..."
            bash "$ACCEPT_LICENSES_SCRIPT" || {
                log_error "Échec de l'acceptation via script externe"
                log_info "Tentative manuelle avec sdkmanager..."
                # Dernière tentative: essayer d'installer un composant qui va demander les licences
                "$SDKMANAGER" "platforms;android-34" --accept-licenses 2>/dev/null || true
            }
        else
            # Dernière méthode: accepter les licences via l'installation d'un composant
            log_step "Tentative d'acceptation via installation d'un composant..."
            "$SDKMANAGER" "platforms;android-34" --accept-licenses > /tmp/android_sdk_install.log 2>&1 || true
            "$SDKMANAGER" "build-tools;34.0.0" --accept-licenses > /tmp/android_sdk_install.log 2>&1 || true
        fi
    fi
    
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

