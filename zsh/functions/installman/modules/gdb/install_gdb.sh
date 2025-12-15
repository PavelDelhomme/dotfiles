#!/bin/zsh
# =============================================================================
# INSTALLATION GDB - Module installman
# =============================================================================
# Description: Installation de GDB (GNU Debugger) - multi-distributions
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

# =============================================================================
# INSTALLATION GDB
# =============================================================================
# DESC: Installe GDB (GNU Debugger) via le gestionnaire de paquets approprié
# USAGE: install_gdb
# EXAMPLE: install_gdb
install_gdb() {
    log_step "Installation de GDB (GNU Debugger)..."
    
    # Vérifier si déjà installé
    if command -v gdb &>/dev/null; then
        log_info "GDB est déjà installé: $(gdb --version | head -n1)"
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
            if sudo pacman -S --noconfirm gdb 2>/dev/null; then
                install_success=true
            else
                log_warn "Échec installation via pacman, essai avec yay..."
                if command -v yay &>/dev/null; then
                    yay -S --noconfirm gdb && install_success=true
                fi
            fi
            ;;
        debian|ubuntu)
            log_step "Installation via apt (Debian/Ubuntu)..."
            sudo apt-get update && sudo apt-get install -y gdb && install_success=true
            ;;
        fedora)
            log_step "Installation via dnf (Fedora)..."
            sudo dnf install -y gdb && install_success=true
            ;;
        alpine)
            log_step "Installation via apk (Alpine)..."
            sudo apk add --no-cache gdb && install_success=true
            ;;
        gentoo)
            log_step "Installation via emerge (Gentoo)..."
            sudo emerge -q gdb && install_success=true
            ;;
        opensuse)
            log_step "Installation via zypper (openSUSE)..."
            sudo zypper install -y gdb && install_success=true
            ;;
        centos)
            log_step "Installation via yum (CentOS)..."
            sudo yum install -y gdb && install_success=true
            ;;
        *)
            log_warn "Distribution non reconnue: $distro"
            log_info "Tentative d'installation générique..."
            if install_package "gdb" "auto"; then
                install_success=true
            fi
            ;;
    esac
    
    if [ "$install_success" = true ]; then
        # Vérifier l'installation
        if command -v gdb &>/dev/null; then
            local gdb_version=$(gdb --version | head -n1)
            log_info "✅ GDB installé avec succès!"
            log_info "   Version: $gdb_version"
            log_info "💡 Vérifiez avec: gdb --version"
            log_info "💡 Utilisez avec: gdb <programme>"
            return 0
        else
            log_error "❌ GDB installé mais non trouvé dans PATH"
            log_warn "   Essayez de recharger votre shell ou vérifiez le PATH"
            return 1
        fi
    else
        log_error "❌ Échec de l'installation de GDB"
        log_warn "💡 Installez manuellement:"
        case "$distro" in
            arch) echo "   sudo pacman -S gdb" ;;
            debian|ubuntu) echo "   sudo apt-get install gdb" ;;
            fedora) echo "   sudo dnf install gdb" ;;
            alpine) echo "   sudo apk add gdb" ;;
            gentoo) echo "   sudo emerge gdb" ;;
            opensuse) echo "   sudo zypper install gdb" ;;
            centos) echo "   sudo yum install gdb" ;;
            *) echo "   Utilisez le gestionnaire de paquets de votre distribution" ;;
        esac
        return 1
    fi
}

