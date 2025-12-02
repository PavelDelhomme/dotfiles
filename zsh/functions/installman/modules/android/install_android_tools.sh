#!/bin/zsh
# =============================================================================
# INSTALLATION OUTILS ANDROID - Module installman
# =============================================================================
# Description: Installation des outils Android (ADB, SDK, build-tools)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger les utilitaires
INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"

# Charger les fonctions utilitaires
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/path_utils.sh" ] && source "$INSTALLMAN_UTILS_DIR/path_utils.sh"
[ -f "$INSTALLMAN_UTILS_DIR/distro_detect.sh" ] && source "$INSTALLMAN_UTILS_DIR/distro_detect.sh"

# Chemins
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"
ENV_FILE="$DOTFILES_DIR/zsh/env.sh"

# =============================================================================
# INSTALLATION OUTILS ANDROID (ADB, etc.)
# =============================================================================
# DESC: Installe les outils Android (ADB, SDK, build-tools) avec configuration automatique
# USAGE: install_android_tools
# EXAMPLE: install_android_tools
install_android_tools() {
    log_step "Installation des outils Android (ADB, SDK, etc.)..."
    
    # Détection de la distribution
    local distro=$(detect_distro)
    
    case "$distro" in
        arch)
            log_step "Installation outils Android (Arch Linux)..."
            
            # Vérifier si yay est installé
            if ! command -v yay &>/dev/null; then
                log_warn "yay n'est pas installé. Installation nécessaire..."
                read -p "Installer yay maintenant? (o/n): " install_yay
                if [[ "$install_yay" =~ ^[oO]$ ]]; then
                    bash "$SCRIPTS_DIR/install/tools/install_yay.sh" || {
                        log_error "Échec de l'installation de yay"
                        return 1
                    }
                else
                    log_error "yay est requis pour installer les outils Android sur Arch Linux"
                    return 1
                fi
            fi
            
            log_step "Installation des outils Android via yay..."
            yay -S --noconfirm android-sdk android-sdk-platform-tools android-sdk-build-tools android-tools || {
                log_error "Échec de l'installation des outils Android"
                return 1
            }
            
            # Ajouter les outils Android au PATH
            local android_sdk="/opt/android-sdk"
            local platform_tools="$android_sdk/platform-tools"
            local build_tools="$android_sdk/build-tools"
            
            if [ -d "$platform_tools" ]; then
                add_path_to_env "$platform_tools" "Android Platform Tools (ADB)"
            fi
            
            if [ -d "$build_tools" ]; then
                # Ajouter la dernière version de build-tools
                local latest_build_tools=$(ls -td "$build_tools"/*/ 2>/dev/null | head -1)
                if [ -n "$latest_build_tools" ]; then
                    add_path_to_env "${latest_build_tools%/}" "Android Build Tools"
                fi
            fi
            ;;
        debian)
            log_step "Installation outils Android (Debian/Ubuntu)..."
            
            sudo apt update
            sudo apt install -y android-tools-adb android-tools-fastboot || {
                log_error "Échec de l'installation des outils Android"
                return 1
            }
            
            # Les outils sont généralement dans /usr/bin
            log_info "✓ Outils Android installés (adb, fastboot)"
            ;;
        fedora)
            log_step "Installation outils Android (Fedora)..."
            
            sudo dnf install -y android-tools || {
                log_error "Échec de l'installation des outils Android"
                return 1
            }
            
            # Les outils sont généralement dans /usr/bin
            log_info "✓ Outils Android installés (adb, fastboot)"
            ;;
        *)
            log_error "Distribution non supportée: $distro"
            return 1
            ;;
    esac
    
    log_info "✓ Outils Android installés et configurés avec succès!"
    
    # Proposer d'accepter les licences Android SDK
    echo ""
    log_step "Acceptation des licences Android SDK..."
    read -p "Accepter automatiquement toutes les licences Android SDK maintenant? (O/n): " accept_licenses
    accept_licenses=${accept_licenses:-O}
    
    if [[ "$accept_licenses" =~ ^[oO]$ ]]; then
        # Charger le module d'acceptation des licences
        if [ -f "$INSTALLMAN_DIR/modules/android/accept_android_licenses.sh" ]; then
            source "$INSTALLMAN_DIR/modules/android/accept_android_licenses.sh"
            accept_android_licenses || {
                log_warn "Échec de l'acceptation automatique des licences"
                log_info "Vous pouvez accepter les licences manuellement avec: installman android-licenses"
            }
        else
            log_warn "Module d'acceptation des licences non disponible"
            log_info "Acceptez les licences manuellement avec: sdkmanager --licenses"
        fi
    fi
    
    log_info "💡 Vérifiez avec: adb version"
    log_info "💡 Pour accepter les licences plus tard: installman android-licenses"
    return 0
}

