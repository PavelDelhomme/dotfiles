#!/bin/zsh
# =============================================================================
# INSTALLATION CMAKE - Module installman
# =============================================================================
# Description: Installation de CMake (multi-distributions)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger les utilitaires
INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"

# Charger les fonctions utilitaires
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/distro_detect.sh" ] && source "$INSTALLMAN_UTILS_DIR/distro_detect.sh"
[ -f "$INSTALLMAN_UTILS_DIR/package_manager.sh" ] && source "$INSTALLMAN_UTILS_DIR/package_manager.sh"

# Chemins
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"
INSTALL_DIR="$SCRIPTS_DIR/install/dev"
ENV_FILE="$DOTFILES_DIR/zsh/env.sh"

# =============================================================================
# INSTALLATION CMAKE
# =============================================================================
# DESC: Installe CMake via le gestionnaire de paquets approprié
# USAGE: install_cmake
# EXAMPLE: install_cmake
install_cmake() {
    log_step "Installation de CMake..."
    
    # Vérifier si déjà installé
    if command -v cmake &>/dev/null; then
        log_info "CMake est déjà installé: $(cmake --version | head -n1)"
        read -p "Réinstaller/mettre à jour? (o/N): " reinstall
        if [[ ! "$reinstall" =~ ^[oO]$ ]]; then
            log_info "Installation ignorée"
            return 0
        fi
    fi
    
    # Détecter la distribution
    local distro=$(detect_distro)
    local install_success=false
    
    case "$distro" in
        arch)
            log_step "Installation via pacman (Arch Linux)..."
            if sudo pacman -S --noconfirm cmake 2>/dev/null; then
                install_success=true
            else
                log_warn "Échec installation via pacman, essai avec yay..."
                if command -v yay &>/dev/null; then
                    yay -S --noconfirm cmake && install_success=true
                fi
            fi
            ;;
        debian|ubuntu)
            log_step "Installation via apt (Debian/Ubuntu)..."
            sudo apt-get update && sudo apt-get install -y cmake && install_success=true
            ;;
        fedora)
            log_step "Installation via dnf (Fedora)..."
            sudo dnf install -y cmake && install_success=true
            ;;
        alpine)
            log_step "Installation via apk (Alpine)..."
            sudo apk add --no-cache cmake && install_success=true
            ;;
        gentoo)
            log_step "Installation via emerge (Gentoo)..."
            sudo emerge -q cmake && install_success=true
            ;;
        *)
            log_warn "Distribution non reconnue: $distro"
            log_info "Tentative d'installation générique..."
            # Essayer avec le système de gestion de paquets
            if install_package "cmake" "auto"; then
                install_success=true
            fi
            ;;
    esac
    
    if [ "$install_success" = true ]; then
        # Vérifier l'installation
        if command -v cmake &>/dev/null; then
            local cmake_version=$(cmake --version | head -n1)
            log_info "✅ CMake installé avec succès!"
            log_info "   Version: $cmake_version"
            log_info "💡 Vérifiez avec: cmake --version"
            return 0
        else
            log_error "❌ CMake installé mais non trouvé dans PATH"
            log_warn "   Essayez de recharger votre shell ou vérifiez le PATH"
            return 1
        fi
    else
        log_error "❌ Échec de l'installation de CMake"
        log_warn "💡 Installez manuellement:"
        case "$distro" in
            arch) echo "   sudo pacman -S cmake" ;;
            debian|ubuntu) echo "   sudo apt-get install cmake" ;;
            fedora) echo "   sudo dnf install cmake" ;;
            alpine) echo "   sudo apk add cmake" ;;
            gentoo) echo "   sudo emerge cmake" ;;
            *) echo "   Utilisez le gestionnaire de paquets de votre distribution" ;;
        esac
        return 1
    fi
}

