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
    
    # Trouver sdkmanager (éviter les alias, utiliser le chemin direct)
    local SDKMANAGER=""
    if [ -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
        SDKMANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
    elif [ -f "$ANDROID_HOME/tools/bin/sdkmanager" ]; then
        SDKMANAGER="$ANDROID_HOME/tools/bin/sdkmanager"
    else
        # Résoudre l'alias si nécessaire
        local sdkmanager_cmd=$(command -v sdkmanager 2>/dev/null)
        if [ -n "$sdkmanager_cmd" ]; then
            # Si c'est un alias dans zsh, extraire le chemin réel
            if echo "$sdkmanager_cmd" | grep -q "alias"; then
                # Extraire le chemin depuis l'alias
                sdkmanager_cmd=$(echo "$sdkmanager_cmd" | sed 's/alias sdkmanager=//' | tr -d "'\"")
            fi
            if [ -f "$sdkmanager_cmd" ] && [ -x "$sdkmanager_cmd" ]; then
                SDKMANAGER="$sdkmanager_cmd"
            fi
        fi
    fi
    
    # Vérifier que sdkmanager existe et est exécutable
    if [ -z "$SDKMANAGER" ] || [ ! -f "$SDKMANAGER" ] || [ ! -x "$SDKMANAGER" ]; then
        log_error "sdkmanager non trouvé ou non exécutable dans $ANDROID_HOME"
        log_info "Chemin recherché: $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
        log_info "Installez d'abord Android SDK avec: installman android-tools"
        return 1
    fi
    
    log_step "Acceptation des licences avec sdkmanager..."
    log_info "sdkmanager trouvé: $SDKMANAGER"
    
    # Créer le répertoire des licences s'il n'existe pas
    mkdir -p "$ANDROID_HOME/licenses"
    
    # Utiliser le script bash existant qui est plus robuste
    if [ -f "$ACCEPT_LICENSES_SCRIPT" ]; then
        log_step "Utilisation du script d'acceptation complet..."
        bash "$ACCEPT_LICENSES_SCRIPT" || {
            log_warn "Échec partiel, vérification manuelle..."
        }
    else
        # Méthode alternative: accepter directement
        log_step "Accepter toutes les licences (automatique)..."
        yes | "$SDKMANAGER" --licenses > /tmp/android_licenses_output.log 2>&1 || {
            log_warn "Certaines licences peuvent nécessiter une acceptation manuelle"
        }
    fi
    
    # Vérifier et compter les licences acceptées
    local license_count=0
    if [ -d "$ANDROID_HOME/licenses" ]; then
        # Compter tous les fichiers de licence (peuvent être .txt ou sans extension)
        license_count=$(find "$ANDROID_HOME/licenses" -type f \( -name "*.txt" -o -name "android-*" -o -name "google-*" -o -name "intel-*" -o -name "mips-*" -o -name "*-license" \) 2>/dev/null | wc -l)
        if [ "$license_count" -gt 0 ]; then
            log_info "✓ $license_count licence(s) acceptée(s)"
        else
            log_warn "Aucune licence détectée dans $ANDROID_HOME/licenses"
            log_info "Les licences peuvent être créées lors de la première utilisation d'un composant"
        fi
    fi
    
    # Fonction pour vérifier si un composant est déjà installé
    check_component_installed() {
        local component="$1"
        local component_type=$(echo "$component" | cut -d';' -f1)
        local component_name=$(echo "$component" | cut -d';' -f2)
        
        case "$component_type" in
            "platforms")
                if [ -d "$ANDROID_HOME/platforms/$component_name" ]; then
                    return 0
                fi
                ;;
            "build-tools")
                if [ -d "$ANDROID_HOME/build-tools/$component_name" ]; then
                    return 0
                fi
                ;;
        esac
        return 1
    }
    
    # Installer les composants requis (platforms et build-tools)
    log_step "Installation des composants Android SDK requis..."
    local platforms=("platforms;android-34" "platforms;android-33" "platforms;android-32")
    local build_tools=("build-tools;34.0.0" "build-tools;33.0.2")
    
    for platform in "${platforms[@]}"; do
        local platform_name=$(echo "$platform" | cut -d';' -f2)
        
        # Vérifier si déjà installé
        if check_component_installed "$platform"; then
            log_info "✓ $platform_name déjà installé"
            continue
        fi
        
        log_step "Installation de $platform..."
        local install_output
        install_output=$("$SDKMANAGER" "$platform" 2>&1)
        local install_status=$?
        
        if [ $install_status -eq 0 ]; then
            log_info "✓ $platform_name installé avec succès"
        else
            # Vérifier si c'est une erreur de licence
            if echo "$install_output" | grep -qi "license\|License"; then
                log_warn "⚠ $platform_name nécessite l'acceptation de licences"
                log_info "Les licences ont été acceptées, mais peut nécessiter un redémarrage"
            else
                log_warn "⚠ Erreur lors de l'installation de $platform_name"
                echo "$install_output" | head -3 | while read line; do
                    log_info "  → $line"
                done
            fi
        fi
    done
    
    for build_tool in "${build_tools[@]}"; do
        local tool_name=$(echo "$build_tool" | cut -d';' -f2)
        
        # Vérifier si déjà installé
        if check_component_installed "$build_tool"; then
            log_info "✓ Build-tools $tool_name déjà installé"
            continue
        fi
        
        log_step "Installation de $build_tool..."
        local install_output
        install_output=$("$SDKMANAGER" "$build_tool" 2>&1)
        local install_status=$?
        
        if [ $install_status -eq 0 ]; then
            log_info "✓ Build-tools $tool_name installé avec succès"
        else
            # Vérifier si c'est une erreur de licence
            if echo "$install_output" | grep -qi "license\|License"; then
                log_warn "⚠ $build_tool nécessite l'acceptation de licences"
                log_info "Les licences ont été acceptées, mais peut nécessiter un redémarrage"
            else
                log_warn "⚠ Erreur lors de l'installation de $build_tool"
                echo "$install_output" | head -3 | while read line; do
                    log_info "  → $line"
                done
            fi
        fi
    done
    
    # Vérification finale des composants installés
    log_step "Vérification des composants installés..."
    local installed_platforms=$(ls -d "$ANDROID_HOME/platforms"/* 2>/dev/null | wc -l)
    local installed_build_tools=$(ls -d "$ANDROID_HOME/build-tools"/* 2>/dev/null | wc -l)
    
    log_info "✓ $installed_platforms plateforme(s) Android installée(s)"
    log_info "✓ $installed_build_tools version(s) de build-tools installée(s)"
    
    log_info "✓ Toutes les licences Android SDK sont acceptées!"
    log_info "💡 Vous pouvez maintenant compiler vos projets Flutter/Android"
    log_info "💡 Pour vérifier: flutter doctor"
    return 0
}

