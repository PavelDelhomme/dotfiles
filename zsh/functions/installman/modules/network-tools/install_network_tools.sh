#!/bin/zsh
# =============================================================================
# INSTALLATION NETWORK TOOLS - Module installman
# =============================================================================
# Description: Installation des outils réseau essentiels (nslookup, dig, traceroute, etc.)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
RESET='\033[0m'

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
    
    # Fonction pour installer un outil avec confirmation
    install_tool_with_confirm() {
        local tool_name="$1"
        local package_name="$2"
        local description="$3"
        
        # Vérifier si déjà installé
        if command -v "$tool_name" &>/dev/null; then
            log_skip "$tool_name déjà installé"
            return 0
        fi
        
        # Demander confirmation
        echo ""
        printf "${YELLOW}Installer $tool_name${RESET}"
        [ -n "$description" ] && printf " ($description)"
        printf "? (O/n): "
        read -r confirm
        confirm=${confirm:-O}
        
        if [[ ! "$confirm" =~ ^[oO]$ ]]; then
            log_skip "$tool_name ignoré par l'utilisateur"
            return 0
        fi
        
        # Installer selon la distribution
        local install_success=false
        case "$distro" in
            arch|manjaro)
                log_info "Installation de $tool_name ($package_name)..."
                if sudo pacman -S --noconfirm "$package_name" 2>/dev/null; then
                    install_success=true
                    log_info "$tool_name installé avec succès"
                else
                    log_warn "Impossible d'installer $package_name"
                    log_info "Vous pouvez l'installer manuellement: sudo pacman -S $package_name"
                fi
                ;;
            debian|ubuntu)
                log_info "Installation de $tool_name ($package_name)..."
                if sudo apt update -qq && sudo apt install -y "$package_name" 2>/dev/null; then
                    install_success=true
                    log_info "$tool_name installé avec succès"
                else
                    log_warn "Impossible d'installer $package_name"
                    log_info "Vous pouvez l'installer manuellement: sudo apt install $package_name"
                fi
                ;;
            fedora)
                log_info "Installation de $tool_name ($package_name)..."
                if sudo dnf install -y "$package_name" 2>/dev/null; then
                    install_success=true
                    log_info "$tool_name installé avec succès"
                else
                    log_warn "Impossible d'installer $package_name"
                    log_info "Vous pouvez l'installer manuellement: sudo dnf install $package_name"
                fi
                ;;
        esac
        
        return 0
    }
    
    # Liste des outils à installer selon la distribution
    case "$distro" in
        arch|manjaro)
            log_info "Installation des outils réseau pour Arch/Manjaro..."
            echo ""
            echo -e "${CYAN}📦 Outils DNS:${RESET}"
            install_tool_with_confirm "nslookup" "bind-utils" "requis avec dig"
            install_tool_with_confirm "dig" "bind-utils" "requis avec nslookup"
            
            echo ""
            echo -e "${CYAN}🔍 Outils de diagnostic réseau:${RESET}"
            install_tool_with_confirm "traceroute" "traceroute" "traceroute réseau"
            install_tool_with_confirm "whois" "whois" "informations domaine"
            
            echo ""
            echo -e "${CYAN}🛡️  Outils d'analyse réseau:${RESET}"
            install_tool_with_confirm "nmap" "nmap" "scanner réseau"
            install_tool_with_confirm "tcpdump" "tcpdump" "analyse paquets"
            install_tool_with_confirm "iftop" "iftop" "monitoring trafic"
            install_tool_with_confirm "nc" "gnu-netcat" "netcat (nc)"
            install_tool_with_confirm "lsof" "lsof" "list open files"
            
            # Wireshark (optionnel, interface graphique)
            if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
                echo ""
                echo -e "${CYAN}🖥️  Outils graphiques (optionnel):${RESET}"
                install_tool_with_confirm "wireshark" "wireshark-qt" "analyseur réseau graphique"
            fi
            ;;
            
        debian|ubuntu)
            log_info "Installation des outils réseau pour Debian/Ubuntu..."
            echo ""
            echo -e "${CYAN}📦 Outils DNS:${RESET}"
            install_tool_with_confirm "nslookup" "bind9-dnsutils" "requis avec dig"
            install_tool_with_confirm "dig" "bind9-dnsutils" "requis avec nslookup"
            
            echo ""
            echo -e "${CYAN}🔍 Outils de diagnostic réseau:${RESET}"
            install_tool_with_confirm "traceroute" "traceroute" "traceroute réseau"
            install_tool_with_confirm "whois" "whois" "informations domaine"
            
            echo ""
            echo -e "${CYAN}🛡️  Outils d'analyse réseau:${RESET}"
            install_tool_with_confirm "nmap" "nmap" "scanner réseau"
            install_tool_with_confirm "tcpdump" "tcpdump" "analyse paquets"
            install_tool_with_confirm "iftop" "iftop" "monitoring trafic"
            install_tool_with_confirm "nc" "netcat" "netcat (nc)"
            install_tool_with_confirm "lsof" "lsof" "list open files"
            
            # Wireshark (optionnel)
            if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
                echo ""
                echo -e "${CYAN}🖥️  Outils graphiques (optionnel):${RESET}"
                install_tool_with_confirm "wireshark" "wireshark" "analyseur réseau graphique"
            fi
            ;;
            
        fedora)
            log_info "Installation des outils réseau pour Fedora..."
            echo ""
            echo -e "${CYAN}📦 Outils DNS:${RESET}"
            install_tool_with_confirm "nslookup" "bind-utils" "requis avec dig"
            install_tool_with_confirm "dig" "bind-utils" "requis avec nslookup"
            
            echo ""
            echo -e "${CYAN}🔍 Outils de diagnostic réseau:${RESET}"
            install_tool_with_confirm "traceroute" "traceroute" "traceroute réseau"
            install_tool_with_confirm "whois" "whois" "informations domaine"
            
            echo ""
            echo -e "${CYAN}🛡️  Outils d'analyse réseau:${RESET}"
            install_tool_with_confirm "nmap" "nmap" "scanner réseau"
            install_tool_with_confirm "tcpdump" "tcpdump" "analyse paquets"
            install_tool_with_confirm "iftop" "iftop" "monitoring trafic"
            install_tool_with_confirm "nc" "nc" "netcat (nc)"
            install_tool_with_confirm "lsof" "lsof" "list open files"
            
            # Wireshark (optionnel)
            if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
                echo ""
                echo -e "${CYAN}🖥️  Outils graphiques (optionnel):${RESET}"
                install_tool_with_confirm "wireshark" "wireshark" "analyseur réseau graphique"
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
    
    echo ""
    log_info "Installation des outils réseau terminée!"
    echo ""
    log_info "Résumé des outils:"
    local tools_summary=(
        "nslookup:$(command -v nslookup &>/dev/null && echo '✓' || echo '✗')"
        "dig:$(command -v dig &>/dev/null && echo '✓' || echo '✗')"
        "traceroute:$(command -v traceroute &>/dev/null && echo '✓' || echo '✗')"
        "whois:$(command -v whois &>/dev/null && echo '✓' || echo '✗')"
        "nmap:$(command -v nmap &>/dev/null && echo '✓' || echo '✗')"
        "tcpdump:$(command -v tcpdump &>/dev/null && echo '✓' || echo '✗')"
        "iftop:$(command -v iftop &>/dev/null && echo '✓' || echo '✗')"
        "netcat:$(command -v nc &>/dev/null || command -v netcat &>/dev/null && echo '✓' || echo '✗')"
        "lsof:$(command -v lsof &>/dev/null && echo '✓' || echo '✗')"
    )
    
    for tool_status in "${tools_summary[@]}"; do
        local tool=$(echo "$tool_status" | cut -d: -f1)
        local status=$(echo "$tool_status" | cut -d: -f2)
        if [ "$status" = "✓" ]; then
            log_info "  - $tool: ${GREEN}✓${NC}"
        else
            log_info "  - $tool: ${RED}✗${NC}"
        fi
    done
    
    if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        local wireshark_status=$(command -v wireshark &>/dev/null && echo '✓' || echo '✗')
        if [ "$wireshark_status" = "✓" ]; then
            log_info "  - wireshark: ${GREEN}✓${NC} (optionnel)"
        else
            log_info "  - wireshark: ${RED}✗${NC} (optionnel)"
        fi
    fi
    
    echo ""
    return 0
}

