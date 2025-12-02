#!/bin/zsh
# =============================================================================
# INSTALLATION ANDROID STUDIO - Module installman
# =============================================================================
# Description: Installation d'Android Studio (tous systèmes)
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

# =============================================================================
# INSTALLATION ANDROID STUDIO
# =============================================================================
# DESC: Installe Android Studio selon la distribution
# USAGE: install_android_studio
# EXAMPLE: install_android_studio
install_android_studio() {
    log_step "Installation d'Android Studio..."
    
    # Détection de la distribution
    local distro=$(detect_distro)
    
    # Vérifier si déjà installé
    if command -v android-studio &>/dev/null || [ -f /opt/android-studio/bin/studio.sh ]; then
        log_info "Android Studio est déjà installé"
        read -p "Réinstaller? (o/N): " reinstall
        if [[ ! "$reinstall" =~ ^[oO]$ ]]; then
            return 0
        fi
    fi
    
    case "$distro" in
        arch)
            log_step "Installation Android Studio (Arch Linux)..."
            
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
                    log_error "yay est requis pour installer Android Studio sur Arch Linux"
                    return 1
                fi
            fi
            
            log_step "Installation d'Android Studio via yay..."
            yay -S --noconfirm android-studio || {
                log_error "Échec de l'installation d'Android Studio"
                return 1
            }
            ;;
        debian)
            log_step "Installation Android Studio (Debian/Ubuntu)..."
            
            # Télécharger depuis le site officiel
            log_step "Téléchargement d'Android Studio..."
            cd /tmp
            local studio_url="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.3.1.18/android-studio-2023.3.1.18-linux.tar.gz"
            wget -q --show-progress "$studio_url" -O android-studio.tar.gz || {
                log_error "Échec du téléchargement"
                return 1
            }
            
            log_step "Extraction dans /opt/android-studio..."
            sudo mkdir -p /opt
            sudo tar -xf android-studio.tar.gz -C /opt/ || {
                log_error "Échec de l'extraction"
                rm -f android-studio.tar.gz
                return 1
            }
            
            sudo chown -R "$USER:$USER" /opt/android-studio
            
            # Créer un lien symbolique
            sudo ln -sf /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio
            
            rm -f android-studio.tar.gz
            ;;
        fedora)
            log_step "Installation Android Studio (Fedora)..."
            
            # Télécharger depuis le site officiel
            log_step "Téléchargement d'Android Studio..."
            cd /tmp
            local studio_url="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.3.1.18/android-studio-2023.3.1.18-linux.tar.gz"
            wget -q --show-progress "$studio_url" -O android-studio.tar.gz || {
                log_error "Échec du téléchargement"
                return 1
            }
            
            log_step "Extraction dans /opt/android-studio..."
            sudo mkdir -p /opt
            sudo tar -xf android-studio.tar.gz -C /opt/ || {
                log_error "Échec de l'extraction"
                rm -f android-studio.tar.gz
                return 1
            }
            
            sudo chown -R "$USER:$USER" /opt/android-studio
            
            # Créer un lien symbolique
            sudo ln -sf /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio
            
            rm -f android-studio.tar.gz
            ;;
        *)
            log_error "Distribution non supportée: $distro"
            log_info "Voir: https://developer.android.com/studio"
            return 1
            ;;
    esac
    
    log_info "✓ Android Studio installé avec succès!"
    log_info "💡 Lancez Android Studio avec: android-studio"
    return 0
}

