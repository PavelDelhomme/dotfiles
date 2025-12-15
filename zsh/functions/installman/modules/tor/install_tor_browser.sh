#!/bin/zsh
# =============================================================================
# INSTALLATION TOR BROWSER - Module installman
# =============================================================================
# Description: Installation de Tor Browser (navigateur anonyme) - multi-distributions
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
TOR_BROWSER_DIR="$HOME/.local/share/tor-browser"

# =============================================================================
# INSTALLATION TOR BROWSER
# =============================================================================
# DESC: Installe Tor Browser (navigateur anonyme)
# USAGE: install_tor_browser
# EXAMPLE: install_tor_browser
install_tor_browser() {
    log_step "Installation de Tor Browser (navigateur anonyme)..."
    
    # Vérifier si déjà installé
    if [ -f "$TOR_BROWSER_DIR/Browser/start-tor-browser" ] || command -v tor-browser &>/dev/null; then
        log_info "Tor Browser est déjà installé"
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
        arch|manjaro)
            log_step "Installation via pacman/yay/pamac (Arch Linux/Manjaro)..."
            if sudo pacman -S --noconfirm torbrowser-launcher 2>/dev/null; then
                install_success=true
            elif command -v yay &>/dev/null; then
                yay -S --noconfirm torbrowser-launcher && install_success=true
            elif command -v pamac &>/dev/null; then
                sudo pamac install --no-confirm torbrowser-launcher && install_success=true
            else
                log_warn "Installation manuelle nécessaire..."
                install_tor_browser_manual
                return $?
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
            sudo apt-get update && sudo apt-get install -y torbrowser-launcher deb.torproject.org-keyring && install_success=true
            ;;
        fedora)
            log_step "Installation via dnf (Fedora)..."
            sudo dnf install -y torbrowser-launcher && install_success=true
            ;;
        alpine)
            log_warn "Tor Browser non disponible via apk, installation manuelle..."
            install_tor_browser_manual
            return $?
            ;;
        gentoo)
            log_step "Installation via emerge (Gentoo)..."
            sudo emerge -q www-client/torbrowser-launcher && install_success=true
            ;;
        opensuse)
            log_step "Installation via zypper (openSUSE)..."
            sudo zypper install -y torbrowser-launcher && install_success=true
            ;;
        centos)
            log_warn "Tor Browser non disponible via yum, installation manuelle..."
            install_tor_browser_manual
            return $?
            ;;
        *)
            log_warn "Distribution non reconnue: $distro"
            log_info "Installation manuelle..."
            install_tor_browser_manual
            return $?
            ;;
    esac
    
    if [ "$install_success" = true ]; then
        log_info "✅ Tor Browser installé avec succès!"
        log_info "💡 Lancez avec: torbrowser-launcher"
        log_info "💡 Ou: tor-browser"
        return 0
    else
        log_error "❌ Échec de l'installation de Tor Browser"
        log_warn "💡 Tentative d'installation manuelle..."
        install_tor_browser_manual
        return $?
    fi
}

# Installation manuelle de Tor Browser
install_tor_browser_manual() {
    log_step "Installation manuelle de Tor Browser..."
    
    # Créer le répertoire
    mkdir -p "$TOR_BROWSER_DIR"
    cd "$TOR_BROWSER_DIR" || return 1
    
    # Détecter l'architecture
    local arch=$(uname -m)
    case "$arch" in
        x86_64) local torbrowser_arch="linux64" ;;
        i386|i686) local torbrowser_arch="linux32" ;;
        aarch64|arm64) local torbrowser_arch="linux-arm64" ;;
        *) log_error "Architecture non supportée: $arch"; return 1 ;;
    esac
    
    # Télécharger la dernière version
    log_info "Téléchargement de Tor Browser..."
    local latest_version=$(curl -s https://www.torproject.org/download/ | grep -oP 'torbrowser/[0-9.]+' | head -n1 | cut -d'/' -f2 || echo "13.0.16")
    local download_url="https://www.torproject.org/dist/torbrowser/${latest_version}/tor-browser-${torbrowser_arch}-${latest_version}.tar.xz"
    
    log_info "URL: $download_url"
    
    if command -v wget &>/dev/null; then
        wget -q --show-progress "$download_url" -O tor-browser.tar.xz || {
            log_error "Échec du téléchargement"
            return 1
        }
    elif command -v curl &>/dev/null; then
        curl -L --progress-bar "$download_url" -o tor-browser.tar.xz || {
            log_error "Échec du téléchargement"
            return 1
        }
    else
        log_error "wget ou curl requis pour le téléchargement"
        return 1
    fi
    
    # Extraire
    log_info "Extraction de Tor Browser..."
    tar -xf tor-browser.tar.xz || {
        log_error "Échec de l'extraction"
        return 1
    }
    
    # Déplacer le contenu
    if [ -d "tor-browser_${torbrowser_arch}" ]; then
        mv tor-browser_${torbrowser_arch}/* . 2>/dev/null || true
        rmdir tor-browser_${torbrowser_arch} 2>/dev/null || true
    fi
    
    # Nettoyer
    rm -f tor-browser.tar.xz
    
    # Créer un lien symbolique dans ~/.local/bin
    mkdir -p "$HOME/.local/bin"
    if [ -f "$TOR_BROWSER_DIR/Browser/start-tor-browser" ]; then
        cat > "$HOME/.local/bin/tor-browser" <<'EOF'
#!/bin/bash
cd "$HOME/.local/share/tor-browser/Browser" && ./start-tor-browser "$@"
EOF
        chmod +x "$HOME/.local/bin/tor-browser"
        log_info "✅ Lien symbolique créé: ~/.local/bin/tor-browser"
    fi
    
    log_info "✅ Tor Browser installé manuellement!"
    log_info "💡 Lancez avec: ~/.local/bin/tor-browser"
    log_info "💡 Ou: cd ~/.local/share/tor-browser/Browser && ./start-tor-browser"
    
    return 0
}

