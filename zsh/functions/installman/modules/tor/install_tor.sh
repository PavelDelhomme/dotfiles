#!/bin/zsh
# =============================================================================
# INSTALLATION TOR - Module installman
# =============================================================================
# Description: Installation de Tor (anonymisation réseau) - multi-distributions
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
# INSTALLATION TOR
# =============================================================================
# DESC: Installe Tor (service d'anonymisation réseau)
# USAGE: install_tor
# EXAMPLE: install_tor
install_tor() {
    log_step "Installation de Tor (anonymisation réseau)..."
    
    # Vérifier si déjà installé
    if command -v tor &>/dev/null; then
        log_info "Tor est déjà installé: $(tor --version 2>/dev/null | head -n1 || echo "version inconnue")"
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
            if sudo pacman -S --noconfirm tor 2>/dev/null; then
                install_success=true
            else
                log_warn "Échec installation via pacman, essai avec yay..."
                if command -v yay &>/dev/null; then
                    yay -S --noconfirm tor && install_success=true
                fi
            fi
            ;;
        debian|ubuntu)
            log_step "Installation via apt (Debian/Ubuntu)..."
            # Ajouter le dépôt Tor si nécessaire
            if ! grep -q "deb.torproject.org" /etc/apt/sources.list.d/tor.list 2>/dev/null; then
                log_info "Ajout du dépôt Tor..."
                echo "deb https://deb.torproject.org/torproject.org $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/tor.list 2>/dev/null || true
                curl -s https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | sudo apt-key add - 2>/dev/null || true
            fi
            sudo apt-get update && sudo apt-get install -y tor deb.torproject.org-keyring && install_success=true
            ;;
        fedora)
            log_step "Installation via dnf (Fedora)..."
            sudo dnf install -y tor && install_success=true
            ;;
        alpine)
            log_step "Installation via apk (Alpine)..."
            sudo apk add --no-cache tor && install_success=true
            ;;
        gentoo)
            log_step "Installation via emerge (Gentoo)..."
            sudo emerge -q net-misc/tor && install_success=true
            ;;
        opensuse)
            log_step "Installation via zypper (openSUSE)..."
            sudo zypper install -y tor && install_success=true
            ;;
        centos)
            log_step "Installation via yum (CentOS)..."
            sudo yum install -y tor && install_success=true
            ;;
        *)
            log_warn "Distribution non reconnue: $distro"
            log_info "Tentative d'installation générique..."
            if install_package "tor" "auto"; then
                install_success=true
            fi
            ;;
    esac
    
    if [ "$install_success" = true ]; then
        # Vérifier l'installation
        if command -v tor &>/dev/null; then
            local tor_version=$(tor --version 2>/dev/null | head -n1 || echo "version inconnue")
            log_info "✅ Tor installé avec succès!"
            log_info "   Version: $tor_version"
            log_info "💡 Vérifiez avec: tor --version"
            log_info "💡 Démarrez avec: sudo systemctl start tor"
            log_info "💡 Activez au démarrage: sudo systemctl enable tor"
            return 0
        else
            log_error "❌ Tor installé mais non trouvé dans PATH"
            log_warn "   Essayez de recharger votre shell ou vérifiez le PATH"
            return 1
        fi
    else
        log_error "❌ Échec de l'installation de Tor"
        log_warn "💡 Installez manuellement:"
        case "$distro" in
            arch) echo "   sudo pacman -S tor" ;;
            debian|ubuntu) echo "   sudo apt-get install tor" ;;
            fedora) echo "   sudo dnf install tor" ;;
            alpine) echo "   sudo apk add tor" ;;
            gentoo) echo "   sudo emerge tor" ;;
            opensuse) echo "   sudo zypper install tor" ;;
            centos) echo "   sudo yum install tor" ;;
            *) echo "   Utilisez le gestionnaire de paquets de votre distribution" ;;
        esac
        return 1
    fi
}

