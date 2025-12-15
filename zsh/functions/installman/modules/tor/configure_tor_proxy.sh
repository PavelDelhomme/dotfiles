#!/bin/zsh
# =============================================================================
# CONFIGURATION TOR PROXY - Module installman
# =============================================================================
# Description: Configuration du proxy Tor pour navigation
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger les utilitaires
INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"

# Charger les fonctions utilitaires
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"

# =============================================================================
# CONFIGURATION TOR PROXY
# =============================================================================
# DESC: Configure le proxy Tor pour navigation
# USAGE: configure_tor_proxy
# EXAMPLE: configure_tor_proxy
configure_tor_proxy() {
    log_step "Configuration du proxy Tor pour navigation..."
    
    # Vérifier que Tor est installé
    if ! command -v tor &>/dev/null; then
        log_error "❌ Tor n'est pas installé"
        log_info "💡 Installez-le d'abord avec: installman tor"
        return 1
    fi
    
    # Vérifier que Tor est démarré
    if ! systemctl is-active --quiet tor 2>/dev/null && ! pgrep -x tor >/dev/null; then
        log_warn "⚠️  Tor n'est pas démarré"
        log_info "🔄 Démarrage de Tor..."
        if command -v systemctl &>/dev/null; then
            sudo systemctl start tor 2>/dev/null || true
        else
            log_warn "💡 Démarrez Tor manuellement: sudo tor"
        fi
    fi
    
    # Créer un script helper pour navigation via Tor
    local tor_proxy_script="$HOME/.local/bin/tor-curl"
    mkdir -p "$HOME/.local/bin"
    
    cat > "$tor_proxy_script" <<'EOF'
#!/bin/bash
# Navigation via Tor (curl avec proxy SOCKS5)
curl --socks5-hostname 127.0.0.1:9050 "$@"
EOF
    chmod +x "$tor_proxy_script"
    log_info "✅ Script tor-curl créé: $tor_proxy_script"
    
    # Créer un script pour wget via Tor
    local tor_wget_script="$HOME/.local/bin/tor-wget"
    cat > "$tor_wget_script" <<'EOF'
#!/bin/bash
# Navigation via Tor (wget avec proxy SOCKS5)
wget --proxy=on --proxy-type=socks5 --proxy-host=127.0.0.1 --proxy-port=9050 "$@"
EOF
    chmod +x "$tor_wget_script"
    log_info "✅ Script tor-wget créé: $tor_wget_script"
    
    # Créer un fichier de configuration pour Firefox
    local firefox_config="$HOME/.mozilla/firefox/tor-proxy-config.txt"
    mkdir -p "$HOME/.mozilla/firefox" 2>/dev/null || true
    cat > "$firefox_config" <<'EOF'
# Configuration proxy Tor pour Firefox
# 
# Dans Firefox:
# 1. Menu → Paramètres → Général → Réseau → Paramètres
# 2. Configuration manuelle du proxy
# 3. SOCKS v5: 127.0.0.1 Port: 9050
# 4. Cochez "Proxy DNS lors de l'utilisation de SOCKS v5"
# 5. Pas de proxy pour: localhost, 127.0.0.1
#
# Ou utilisez l'extension FoxyProxy pour basculer facilement
EOF
    log_info "✅ Guide Firefox créé: $firefox_config"
    
    # Test de connexion
    log_info ""
    log_info "🧪 Test de connexion Tor..."
    if curl --socks5-hostname 127.0.0.1:9050 -s https://check.torproject.org/api/ip 2>/dev/null | grep -q "IsTor.*true"; then
        log_info "✅ Connexion Tor fonctionnelle!"
    else
        log_warn "⚠️  Tor ne semble pas fonctionner"
        log_info "💡 Vérifiez avec: sudo systemctl status tor"
        log_info "💡 Ou: curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org"
    fi
    
    log_info ""
    log_info "✅ Configuration terminée!"
    log_info "💡 Utilisez: tor-curl <url> pour naviguer via Tor"
    log_info "💡 Ou: tor-wget <url> pour télécharger via Tor"
    log_info "💡 Vérifiez votre IP: tor-curl https://api.ipify.org"
    
    return 0
}

