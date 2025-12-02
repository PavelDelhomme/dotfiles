#!/bin/zsh
# =============================================================================
# INSTALLATION FLUTTER - Module installman
# =============================================================================
# Description: Installation de Flutter SDK dans /opt/flutter/bin
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
INSTALL_DIR="$SCRIPTS_DIR/install/dev"
ENV_FILE="$DOTFILES_DIR/zsh/env.sh"

# =============================================================================
# INSTALLATION FLUTTER
# =============================================================================
# DESC: Installe Flutter SDK dans /opt/flutter/bin avec configuration automatique
# USAGE: install_flutter
# EXAMPLE: install_flutter
install_flutter() {
    log_step "Installation de Flutter dans /opt/flutter/bin..."
    
    local flutter_bin="/opt/flutter/bin"
    local flutter_dir="/opt/flutter"
    
    # Vérifier si déjà installé
    if [ -d "$flutter_bin" ] && [ -f "$flutter_bin/flutter" ]; then
        log_info "Flutter est déjà installé dans $flutter_dir"
        log_step "Vérification de la version..."
        "$flutter_bin/flutter" --version | head -n1 || true
        read -p "Réinstaller/mettre à jour? (o/N): " reinstall
        if [[ ! "$reinstall" =~ ^[oO]$ ]]; then
            # Vérifier si déjà dans env.sh
            if ! grep -q "$flutter_bin" "$ENV_FILE" 2>/dev/null; then
                log_step "Ajout au PATH dans env.sh..."
                add_path_to_env "$flutter_bin" "Flutter SDK"
            fi
            log_info "Installation ignorée"
            return 0
        else
            log_step "Suppression de l'installation existante..."
            sudo rm -rf "$flutter_dir"
        fi
    fi
    
    # Détection de la distribution
    local distro=$(detect_distro)
    log_step "Distribution détectée: $distro"
    
    # Installation selon la distribution
    case "$distro" in
        arch)
            log_step "Installation Flutter (Arch Linux) dans /opt/flutter..."
            
            # Vérifier les dépendances
            if ! command -v wget &>/dev/null; then
                log_warn "wget non trouvé, installation..."
                sudo pacman -S --noconfirm wget || {
                    log_error "Impossible d'installer wget"
                    return 1
                }
            fi
            
            # Télécharger et installer Flutter directement dans /opt/flutter
            log_step "Téléchargement de Flutter SDK..."
            cd /tmp
            local flutter_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz"
            wget -q --show-progress "$flutter_url" -O flutter.tar.xz || {
                log_error "Échec du téléchargement de Flutter"
                return 1
            }
            
            log_step "Extraction dans /opt/flutter..."
            sudo mkdir -p /opt
            sudo tar -xf flutter.tar.xz -C /opt/ || {
                log_error "Échec de l'extraction"
                rm -f flutter.tar.xz
                return 1
            }
            
            # Configurer les permissions
            sudo chown -R "$USER:$USER" "$flutter_dir" || {
                log_warn "Impossible de changer le propriétaire, utilisation de sudo pour les permissions..."
            }
            
            rm -f flutter.tar.xz
            ;;
        debian|fedora)
            # Utiliser le script d'installation existant pour Debian/Fedora
            local flutter_script="$INSTALL_DIR/install_flutter.sh"
            if [ -f "$flutter_script" ]; then
                bash "$flutter_script" || {
                    log_error "Échec de l'installation de Flutter"
                    return 1
                }
            else
                log_error "Script d'installation non trouvé: $flutter_script"
                return 1
            fi
            ;;
        *)
            log_error "Distribution non supportée: $distro"
            log_info "Voir: https://docs.flutter.dev/get-started/install/linux"
            return 1
            ;;
    esac
    
    # Vérifier l'installation
    if [ -d "$flutter_bin" ] && [ -f "$flutter_bin/flutter" ]; then
        log_info "✓ Flutter installé dans $flutter_dir"
        
        # Ajouter au PATH dans env.sh
        add_path_to_env "$flutter_bin" "Flutter SDK"
        
        # Ajouter au PATH de la session actuelle
        if [[ ":$PATH:" != *":$flutter_bin:"* ]]; then
            export PATH="$flutter_bin:$PATH"
        fi
        
        # Exécuter flutter doctor
        log_step "Exécution de 'flutter doctor'..."
        "$flutter_bin/flutter" doctor || true
        
        log_info "✓ Flutter installé et configuré avec succès!"
        log_info "💡 Rechargez votre shell (zshrc) pour utiliser Flutter partout"
        return 0
    else
        log_error "Flutter n'a pas pu être installé correctement"
        log_info "Vérifiez les permissions sur /opt/flutter"
        return 1
    fi
}

