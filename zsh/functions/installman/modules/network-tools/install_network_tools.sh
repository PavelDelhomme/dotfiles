#!/bin/zsh
# =============================================================================
# INSTALLATION NETWORK TOOLS - Module installman
# =============================================================================
# Description: Installation des outils réseau essentiels (nslookup, dig, traceroute, etc.)
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

# =============================================================================
# INSTALLATION NETWORK TOOLS
# =============================================================================
# DESC: Installe les outils réseau essentiels
# USAGE: install_network_tools
# EXAMPLE: install_network_tools
install_network_tools() {
    log_step "Installation des outils réseau..."
    
    # Détecter la distribution
    local distro=$(detect_distro 2>/dev/null || echo "arch")
    
    # Liste des outils à installer selon la distribution
    case "$distro" in
        arch|manjaro)
            log_info "Installation des outils réseau pour Arch/Manjaro..."
            
            # Outils DNS
            if ! command -v nslookup &>/dev/null; then
                log_info "Installation de nslookup (bind-utils)..."
                sudo pacman -S --noconfirm bind-utils || log_warn "Impossible d'installer bind-utils"
            else
                log_skip "nslookup déjà installé"
            fi
            
            if ! command -v dig &>/dev/null; then
                log_info "Installation de dig (bind-utils)..."
                sudo pacman -S --noconfirm bind-utils || log_warn "Impossible d'installer bind-utils"
            else
                log_skip "dig déjà installé"
            fi
            
            # Outils de diagnostic réseau
            if ! command -v traceroute &>/dev/null; then
                log_info "Installation de traceroute..."
                sudo pacman -S --noconfirm traceroute || log_warn "Impossible d'installer traceroute"
            else
                log_skip "traceroute déjà installé"
            fi
            
            if ! command -v whois &>/dev/null; then
                log_info "Installation de whois..."
                sudo pacman -S --noconfirm whois || log_warn "Impossible d'installer whois"
            else
                log_skip "whois déjà installé"
            fi
            
            # Outils d'analyse réseau
            if ! command -v nmap &>/dev/null; then
                log_info "Installation de nmap..."
                sudo pacman -S --noconfirm nmap || log_warn "Impossible d'installer nmap"
            else
                log_skip "nmap déjà installé"
            fi
            
            if ! command -v tcpdump &>/dev/null; then
                log_info "Installation de tcpdump..."
                sudo pacman -S --noconfirm tcpdump || log_warn "Impossible d'installer tcpdump"
            else
                log_skip "tcpdump déjà installé"
            fi
            
            if ! command -v iftop &>/dev/null; then
                log_info "Installation de iftop..."
                sudo pacman -S --noconfirm iftop || log_warn "Impossible d'installer iftop"
            else
                log_skip "iftop déjà installé"
            fi
            
            if ! command -v netcat &>/dev/null && ! command -v nc &>/dev/null; then
                log_info "Installation de netcat (gnu-netcat)..."
                sudo pacman -S --noconfirm gnu-netcat || log_warn "Impossible d'installer gnu-netcat"
            else
                log_skip "netcat déjà installé"
            fi
            
            if ! command -v lsof &>/dev/null; then
                log_info "Installation de lsof..."
                sudo pacman -S --noconfirm lsof || log_warn "Impossible d'installer lsof"
            else
                log_skip "lsof déjà installé"
            fi
            
            # Wireshark (optionnel, interface graphique)
            if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
                if ! command -v wireshark &>/dev/null; then
                    log_info "Interface graphique détectée, installation de Wireshark (optionnel)..."
                    read "?Installer Wireshark? (o/N): " install_wireshark
                    if [[ "$install_wireshark" =~ ^[oO]$ ]]; then
                        sudo pacman -S --noconfirm wireshark-qt || log_warn "Impossible d'installer wireshark"
                    fi
                else
                    log_skip "wireshark déjà installé"
                fi
            fi
            ;;
            
        debian|ubuntu)
            log_info "Installation des outils réseau pour Debian/Ubuntu..."
            
            # Outils DNS
            if ! command -v nslookup &>/dev/null || ! command -v dig &>/dev/null; then
                log_info "Installation de bind9-dnsutils (nslookup, dig)..."
                sudo apt update && sudo apt install -y bind9-dnsutils || log_warn "Impossible d'installer bind9-dnsutils"
            else
                log_skip "nslookup/dig déjà installés"
            fi
            
            # Outils de diagnostic réseau
            if ! command -v traceroute &>/dev/null; then
                log_info "Installation de traceroute..."
                sudo apt install -y traceroute || log_warn "Impossible d'installer traceroute"
            else
                log_skip "traceroute déjà installé"
            fi
            
            if ! command -v whois &>/dev/null; then
                log_info "Installation de whois..."
                sudo apt install -y whois || log_warn "Impossible d'installer whois"
            else
                log_skip "whois déjà installé"
            fi
            
            # Outils d'analyse réseau
            if ! command -v nmap &>/dev/null; then
                log_info "Installation de nmap..."
                sudo apt install -y nmap || log_warn "Impossible d'installer nmap"
            else
                log_skip "nmap déjà installé"
            fi
            
            if ! command -v tcpdump &>/dev/null; then
                log_info "Installation de tcpdump..."
                sudo apt install -y tcpdump || log_warn "Impossible d'installer tcpdump"
            else
                log_skip "tcpdump déjà installé"
            fi
            
            if ! command -v iftop &>/dev/null; then
                log_info "Installation de iftop..."
                sudo apt install -y iftop || log_warn "Impossible d'installer iftop"
            else
                log_skip "iftop déjà installé"
            fi
            
            if ! command -v netcat &>/dev/null && ! command -v nc &>/dev/null; then
                log_info "Installation de netcat..."
                sudo apt install -y netcat || log_warn "Impossible d'installer netcat"
            else
                log_skip "netcat déjà installé"
            fi
            
            if ! command -v lsof &>/dev/null; then
                log_info "Installation de lsof..."
                sudo apt install -y lsof || log_warn "Impossible d'installer lsof"
            else
                log_skip "lsof déjà installé"
            fi
            
            # Wireshark (optionnel)
            if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
                if ! command -v wireshark &>/dev/null; then
                    log_info "Interface graphique détectée, installation de Wireshark (optionnel)..."
                    read "?Installer Wireshark? (o/N): " install_wireshark
                    if [[ "$install_wireshark" =~ ^[oO]$ ]]; then
                        sudo apt install -y wireshark || log_warn "Impossible d'installer wireshark"
                    fi
                else
                    log_skip "wireshark déjà installé"
                fi
            fi
            ;;
            
        fedora)
            log_info "Installation des outils réseau pour Fedora..."
            
            # Outils DNS
            if ! command -v nslookup &>/dev/null || ! command -v dig &>/dev/null; then
                log_info "Installation de bind-utils (nslookup, dig)..."
                sudo dnf install -y bind-utils || log_warn "Impossible d'installer bind-utils"
            else
                log_skip "nslookup/dig déjà installés"
            fi
            
            # Outils de diagnostic réseau
            if ! command -v traceroute &>/dev/null; then
                log_info "Installation de traceroute..."
                sudo dnf install -y traceroute || log_warn "Impossible d'installer traceroute"
            else
                log_skip "traceroute déjà installé"
            fi
            
            if ! command -v whois &>/dev/null; then
                log_info "Installation de whois..."
                sudo dnf install -y whois || log_warn "Impossible d'installer whois"
            else
                log_skip "whois déjà installé"
            fi
            
            # Outils d'analyse réseau
            if ! command -v nmap &>/dev/null; then
                log_info "Installation de nmap..."
                sudo dnf install -y nmap || log_warn "Impossible d'installer nmap"
            else
                log_skip "nmap déjà installé"
            fi
            
            if ! command -v tcpdump &>/dev/null; then
                log_info "Installation de tcpdump..."
                sudo dnf install -y tcpdump || log_warn "Impossible d'installer tcpdump"
            else
                log_skip "tcpdump déjà installé"
            fi
            
            if ! command -v iftop &>/dev/null; then
                log_info "Installation de iftop..."
                sudo dnf install -y iftop || log_warn "Impossible d'installer iftop"
            else
                log_skip "iftop déjà installé"
            fi
            
            if ! command -v netcat &>/dev/null && ! command -v nc &>/dev/null; then
                log_info "Installation de netcat (nc)..."
                sudo dnf install -y nc || log_warn "Impossible d'installer nc"
            else
                log_skip "netcat déjà installé"
            fi
            
            if ! command -v lsof &>/dev/null; then
                log_info "Installation de lsof..."
                sudo dnf install -y lsof || log_warn "Impossible d'installer lsof"
            else
                log_skip "lsof déjà installé"
            fi
            
            # Wireshark (optionnel)
            if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
                if ! command -v wireshark &>/dev/null; then
                    log_info "Interface graphique détectée, installation de Wireshark (optionnel)..."
                    read "?Installer Wireshark? (o/N): " install_wireshark
                    if [[ "$install_wireshark" =~ ^[oO]$ ]]; then
                        sudo dnf install -y wireshark || log_warn "Impossible d'installer wireshark"
                    fi
                else
                    log_skip "wireshark déjà installé"
                fi
            fi
            ;;
            
        *)
            log_warn "Distribution non supportée: $distro"
            log_info "Installez manuellement les outils réseau:"
            log_info "  - nslookup, dig (bind-utils ou bind9-dnsutils)"
            log_info "  - traceroute"
            log_info "  - whois"
            log_info "  - nmap"
            log_info "  - tcpdump"
            log_info "  - iftop"
            log_info "  - netcat (nc)"
            log_info "  - lsof"
            return 1
            ;;
    esac
    
    log_info "✓ Installation des outils réseau terminée!"
    log_info ""
    log_info "Outils installés:"
    log_info "  - nslookup: $(command -v nslookup &>/dev/null && echo '✓' || echo '✗')"
    log_info "  - dig: $(command -v dig &>/dev/null && echo '✓' || echo '✗')"
    log_info "  - traceroute: $(command -v traceroute &>/dev/null && echo '✓' || echo '✗')"
    log_info "  - whois: $(command -v whois &>/dev/null && echo '✓' || echo '✗')"
    log_info "  - nmap: $(command -v nmap &>/dev/null && echo '✓' || echo '✗')"
    log_info "  - tcpdump: $(command -v tcpdump &>/dev/null && echo '✓' || echo '✗')"
    log_info "  - iftop: $(command -v iftop &>/dev/null && echo '✓' || echo '✗')"
    log_info "  - netcat: $(command -v nc &>/dev/null || command -v netcat &>/dev/null && echo '✓' || echo '✗')"
    log_info "  - lsof: $(command -v lsof &>/dev/null && echo '✓' || echo '✗')"
    if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        log_info "  - wireshark: $(command -v wireshark &>/dev/null && echo '✓' || echo '✗ (optionnel)')"
    fi
    
    return 0
}

