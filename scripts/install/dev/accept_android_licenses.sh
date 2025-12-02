#!/bin/bash

################################################################################
# Accepter les licences Android SDK
# Description: Accepte automatiquement toutes les licences Android SDK
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if [ -f "$SCRIPT_DIR/lib/common.sh" ]; then
    source "$SCRIPT_DIR/lib/common.sh"
else
    # Fonctions de base si common.sh n'existe pas
    log_info() { echo "ℹ️  $1"; }
    log_error() { echo "❌ $1" >&2; }
    log_success() { echo "✅ $1"; }
    log_warn() { echo "⚠️  $1"; }
fi

log_section "Acceptation des licences Android SDK"

# Détecter ANDROID_HOME
if [ -z "$ANDROID_HOME" ]; then
    if [ -d "$HOME/Android/Sdk" ]; then
        export ANDROID_HOME="$HOME/Android/Sdk"
        export ANDROID_SDK_ROOT="$ANDROID_HOME"
    else
        log_error "ANDROID_HOME non défini et $HOME/Android/Sdk non trouvé"
        log_info "Définissez ANDROID_HOME ou installez Android SDK"
        exit 1
    fi
fi

log_info "ANDROID_HOME: $ANDROID_HOME"

# Trouver sdkmanager
SDKMANAGER=""
if [ -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
    SDKMANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
elif [ -f "$ANDROID_HOME/tools/bin/sdkmanager" ]; then
    SDKMANAGER="$ANDROID_HOME/tools/bin/sdkmanager"
elif [ -f "$ANDROID_HOME/platform-tools/sdkmanager" ]; then
    SDKMANAGER="$ANDROID_HOME/platform-tools/sdkmanager"
else
    log_error "sdkmanager non trouvé dans $ANDROID_HOME"
    log_info "Installation des command-line tools requise"
    log_info "Téléchargez depuis: https://developer.android.com/studio#command-tools"
    exit 1
fi

log_info "sdkmanager trouvé: $SDKMANAGER"

# Accepter toutes les licences
log_info "Acceptation de toutes les licences Android SDK..."
yes | "$SDKMANAGER" --licenses > /tmp/android_licenses.log 2>&1 || {
    log_warn "Certaines licences n'ont pas pu être acceptées automatiquement"
    log_info "Tentative manuelle..."
    
    # Essayer d'accepter chaque licence individuellement
    "$SDKMANAGER" --licenses <<EOF
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
y
EOF
}

# Vérifier que les licences sont acceptées
if [ -d "$ANDROID_HOME/licenses" ]; then
    LICENSE_COUNT=$(find "$ANDROID_HOME/licenses" -name "*.txt" 2>/dev/null | wc -l)
    if [ "$LICENSE_COUNT" -gt 0 ]; then
        log_success "$LICENSE_COUNT licence(s) acceptée(s)"
    else
        log_warn "Aucune licence trouvée dans $ANDROID_HOME/licenses"
    fi
fi

# Installer les composants requis pour Flutter
log_info "Installation des composants Android SDK requis..."

# Plateformes et build-tools couramment utilisés
PLATFORMS="platforms;android-34 platforms;android-33 platforms;android-32 platforms;android-31"
BUILD_TOOLS="build-tools;34.0.0 build-tools;33.0.2 build-tools;32.0.0"

for platform in $PLATFORMS; do
    log_info "Installation de $platform..."
    "$SDKMANAGER" "$platform" > /tmp/android_sdk_install.log 2>&1 || log_warn "Échec installation $platform"
done

for build_tool in $BUILD_TOOLS; do
    log_info "Installation de $build_tool..."
    "$SDKMANAGER" "$build_tool" > /tmp/android_sdk_install.log 2>&1 || log_warn "Échec installation $build_tool"
done

log_success "Licences Android SDK acceptées et composants installés"

