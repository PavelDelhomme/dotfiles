#!/bin/zsh
# =============================================================================
# INSTALLATION TOR NAVIGATION - Module installman
# =============================================================================
# Description: Installation de la navigation Tor (avec ou sans navigateur)
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
# INSTALLATION TOR NAVIGATION
# =============================================================================
# DESC: Installe Tor + navigation (avec ou sans navigateur)
# USAGE: install_tor_navigation [with-browser|without-browser]
# EXAMPLE: install_tor_navigation with-browser
# EXAMPLE: install_tor_navigation without-browser
install_tor_navigation() {
    local mode="${1:-interactive}"
    
    log_step "Installation de la navigation Tor..."
    
    # Mode interactif si non spécifié
    if [ "$mode" = "interactive" ]; then
        echo ""
        echo "Choisissez le mode d'installation:"
        echo "  1) Tor uniquement (navigation via proxy, sans navigateur)"
        echo "  2) Tor + Tor Browser (navigateur anonyme complet)"
        echo "  3) Les deux"
        echo ""
        read -p "Choix [défaut: 1]: " choice
        choice=${choice:-1}
        
        case "$choice" in
            1) mode="without-browser" ;;
            2) mode="with-browser" ;;
            3) mode="both" ;;
            *) mode="without-browser" ;;
        esac
    fi
    
    local tor_installed=false
    local browser_installed=false
    
    # Installer Tor
    if [ "$mode" = "without-browser" ] || [ "$mode" = "both" ]; then
        log_step "Installation de Tor..."
        if install_tor; then
            tor_installed=true
        fi
    fi
    
    # Installer Tor Browser
    if [ "$mode" = "with-browser" ] || [ "$mode" = "both" ]; then
        log_step "Installation de Tor Browser..."
        if install_tor_browser; then
            browser_installed=true
        fi
    fi
    
    # Proposer la configuration du proxy
    if [ "$tor_installed" = true ]; then
        echo ""
        read -p "Configurer le proxy Tor pour navigation? (O/n): " configure_proxy
        configure_proxy=${configure_proxy:-O}
        if [[ "$configure_proxy" =~ ^[oO]$ ]]; then
            INSTALLMAN_MODULES_DIR="$INSTALLMAN_DIR/modules"
            [ -f "$INSTALLMAN_MODULES_DIR/tor/configure_tor_proxy.sh" ] && source "$INSTALLMAN_MODULES_DIR/tor/configure_tor_proxy.sh"
            configure_tor_proxy
        fi
    fi
    
    # Résumé
    echo ""
    log_info "📊 Résumé de l'installation:"
    if [ "$tor_installed" = true ]; then
        log_info "✅ Tor installé"
        log_info ""
        log_info "💡 Navigation via Tor (sans navigateur):"
        log_info "   - Proxy SOCKS5: 127.0.0.1:9050"
        log_info "   - Test: curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org"
        log_info "   - wget: wget --proxy=on --proxy-type=socks5 --proxy-host=127.0.0.1 --proxy-port=9050 http://example.com"
        log_info "   - Scripts: tor-curl et tor-wget créés dans ~/.local/bin"
        log_info ""
        log_info "💡 Configuration navigateur (Firefox/Chrome):"
        log_info "   - Type: SOCKS5"
        log_info "   - Hôte: 127.0.0.1"
        log_info "   - Port: 9050"
        log_info "   - DNS via proxy: Activé (pour Firefox)"
    fi
    if [ "$browser_installed" = true ]; then
        log_info "✅ Tor Browser installé"
        log_info "💡 Lancez avec: tor-browser ou torbrowser-launcher"
        log_info "💡 Tor Browser inclut Tor intégré, navigation anonyme complète"
    fi
    
    if [ "$tor_installed" = true ] || [ "$browser_installed" = true ]; then
        return 0
    else
        log_error "❌ Aucune installation réussie"
        return 1
    fi
}

# Charger les fonctions d'installation
INSTALLMAN_MODULES_DIR="$INSTALLMAN_DIR/modules"
[ -f "$INSTALLMAN_MODULES_DIR/tor/install_tor.sh" ] && source "$INSTALLMAN_MODULES_DIR/tor/install_tor.sh"
[ -f "$INSTALLMAN_MODULES_DIR/tor/install_tor_browser.sh" ] && source "$INSTALLMAN_MODULES_DIR/tor/install_tor_browser.sh"

