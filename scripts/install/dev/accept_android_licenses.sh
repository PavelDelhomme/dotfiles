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

# Créer le répertoire des licences s'il n'existe pas
mkdir -p "$ANDROID_HOME/licenses"

# Accepter toutes les licences
log_info "Acceptation de toutes les licences Android SDK..."

# Méthode 1: Utiliser yes pour répondre automatiquement
if ! yes | "$SDKMANAGER" --licenses > /tmp/android_licenses.log 2>&1; then
    log_warn "Méthode automatique échouée, tentative alternative..."
    
    # Méthode 2: Créer les fichiers de licence directement
    log_info "Création des fichiers de licence directement..."
    
    # Créer les fichiers de licence standard avec leurs hash
    LICENSE_DIR="$ANDROID_HOME/licenses"
    
    # android-sdk-license (hash standard accepté)
    echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > "$LICENSE_DIR/android-sdk-license" 2>/dev/null || true
    echo "601085b94cd77f0b54ff86406957099ebe79c4d6" >> "$LICENSE_DIR/android-sdk-license" 2>/dev/null || true
    
    # android-sdk-preview-license
    echo "84831b9409646a918e30573bab4c9c91346d8abd" > "$LICENSE_DIR/android-sdk-preview-license" 2>/dev/null || true
    
    # google-gdk-license
    echo "33b6a2b64607f11b759f320ef9dff4ae5c47d97a" > "$LICENSE_DIR/google-gdk-license" 2>/dev/null || true
    
    # intel-android-extra-license
    echo "d975f751698a77b662f1254ddbeed3901e976f5a" > "$LICENSE_DIR/intel-android-extra-license" 2>/dev/null || true
    
    # mips-android-sysimage-license
    echo "e9acab5b5fbb560a72cfaecce8946896ff6aab9d" > "$LICENSE_DIR/mips-android-sysimage-license" 2>/dev/null || true
    
    # google-gdk-license (alternatif)
    echo "601085b94cd77f0b54ff86406957099ebe79c4d6" > "$LICENSE_DIR/google-gdk-license" 2>/dev/null || true
    
    log_info "Fichiers de licence créés, nouvelle tentative avec sdkmanager..."
    
    # Méthode 3: Essayer d'accepter chaque licence individuellement
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
    # Utiliser --accept-licenses pour éviter les prompts
    "$SDKMANAGER" "$platform" --accept-licenses > /tmp/android_sdk_install.log 2>&1 || {
        # Si --accept-licenses n'est pas supporté, essayer sans
        "$SDKMANAGER" "$platform" > /tmp/android_sdk_install.log 2>&1 || log_warn "Échec installation $platform (peut déjà être installé)"
    }
done

for build_tool in $BUILD_TOOLS; do
    log_info "Installation de $build_tool..."
    # Utiliser --accept-licenses pour éviter les prompts
    "$SDKMANAGER" "$build_tool" --accept-licenses > /tmp/android_sdk_install.log 2>&1 || {
        # Si --accept-licenses n'est pas supporté, essayer sans
        "$SDKMANAGER" "$build_tool" > /tmp/android_sdk_install.log 2>&1 || log_warn "Échec installation $build_tool (peut déjà être installé)"
    }
done

# Vérification finale
if [ -d "$ANDROID_HOME/licenses" ]; then
    LICENSE_COUNT=$(find "$ANDROID_HOME/licenses" -name "*.txt" -o -name "android-*" 2>/dev/null | wc -l)
    if [ "$LICENSE_COUNT" -gt 0 ]; then
        log_success "$LICENSE_COUNT licence(s) acceptée(s)"
        log_info "Fichiers de licence dans: $ANDROID_HOME/licenses"
        ls -la "$ANDROID_HOME/licenses" | head -10
    else
        log_warn "Aucune licence trouvée dans $ANDROID_HOME/licenses"
        log_info "Les licences peuvent être créées automatiquement lors de la première utilisation"
    fi
fi

log_success "Licences Android SDK acceptées et composants installés"

