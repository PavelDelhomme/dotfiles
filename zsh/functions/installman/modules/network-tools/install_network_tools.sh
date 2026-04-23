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
    
    # Vérifier les droits sudo au début
    echo ""
    log_info "Vérification des droits d'administration..."
    if ! sudo -v 2>/dev/null; then
        log_error "Impossible d'obtenir les droits sudo"
        log_info "Veuillez vous assurer d'avoir les droits d'administration"
        log_info "Vous pouvez installer les outils manuellement avec les commandes appropriées"
        return 1
    fi
    log_info "Droits sudo confirmés"
    echo ""
    
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
                # Rafraîchir le timestamp sudo si nécessaire
                sudo -v 2>/dev/null
                if sudo pacman -S --noconfirm "$package_name"; then
                    install_success=true
                    log_info "$tool_name installé avec succès"
                else
                    local exit_code=$?
                    log_warn "Impossible d'installer $package_name (code: $exit_code)"
                    
                    # Essayer des alternatives pour certains outils
                    local alternative_package=""
                    case "$package_name" in
                        bind)
                            # bind contient nslookup et dig, mais si ça échoue, essayer bind-tools
                            alternative_package="bind-tools"
                            ;;
                    esac
                    
                    if [ -n "$alternative_package" ]; then
                        log_info "Tentative avec le paquet alternatif: $alternative_package"
                        if sudo pacman -S --noconfirm "$alternative_package"; then
                            install_success=true
                            log_info "$tool_name installé avec succès (via $alternative_package)"
                        else
                            log_warn "Échec également avec $alternative_package"
                            log_info "Vous pouvez l'installer manuellement: sudo pacman -S $package_name"
                        fi
                    else
                        log_info "Vous pouvez l'installer manuellement: sudo pacman -S $package_name"
                    fi
                fi
                ;;
            debian|ubuntu)
                log_info "Installation de $tool_name ($package_name)..."
                # Rafraîchir le timestamp sudo si nécessaire
                sudo -v 2>/dev/null
                if sudo apt update -qq && sudo apt install -y "$package_name"; then
                    install_success=true
                    log_info "$tool_name installé avec succès"
                else
                    local exit_code=$?
                    log_warn "Impossible d'installer $package_name (code: $exit_code)"
                    log_info "Vous pouvez l'installer manuellement: sudo apt install $package_name"
                fi
                ;;
            fedora)
                log_info "Installation de $tool_name ($package_name)..."
                # Rafraîchir le timestamp sudo si nécessaire
                sudo -v 2>/dev/null
                if sudo dnf install -y "$package_name"; then
                    install_success=true
                    log_info "$tool_name installé avec succès"
                else
                    local exit_code=$?
                    log_warn "Impossible d'installer $package_name (code: $exit_code)"
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
            # bind contient à la fois nslookup et dig, donc on l'installe une seule fois
            if ! command -v nslookup &>/dev/null && ! command -v dig &>/dev/null; then
                echo ""
                printf "${YELLOW}Installer nslookup et dig (bind)${RESET} (contient les deux outils)? (O/n): "
                read -r confirm
                confirm=${confirm:-O}
                if [[ "$confirm" =~ ^[oO]$ ]]; then
                    log_info "Installation de bind (contient nslookup et dig)..."
                    sudo -v 2>/dev/null
                    if sudo pacman -S --noconfirm bind; then
                        log_info "bind installé avec succès (nslookup et dig disponibles)"
                    else
                        log_warn "Impossible d'installer bind"
                        log_info "Vous pouvez l'installer manuellement: sudo pacman -S bind"
                    fi
                else
                    log_skip "bind ignoré par l'utilisateur"
                fi
            elif ! command -v nslookup &>/dev/null; then
                install_tool_with_confirm "nslookup" "bind" "contient nslookup et dig"
            elif ! command -v dig &>/dev/null; then
                install_tool_with_confirm "dig" "bind" "contient nslookup et dig"
            else
                log_skip "nslookup et dig déjà installés"
            fi
            
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
        local tool_status_value=$(echo "$tool_status" | cut -d: -f2)
        if [ "$tool_status_value" = "✓" ]; then
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

# DESC: Sous-menu outils réseau (liste + raccourcis paquets ; 1 = flux complet)
# USAGE: install_network_tools_menu
install_network_tools_menu() {
    echo ""
    echo -e "${YELLOW}🌐 Outils réseau — détail${RESET}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
    echo ""
    echo "  1) Flux complet installman (bind, traceroute, nmap, …)"
    echo "  2) bind (nslookup + dig)     Arch: bind     Debian: bind9-dnsutils"
    echo "  3) traceroute               Arch/Deb: traceroute"
    echo "  4) whois                    Arch/Deb: whois"
    echo "  5) nmap                     Arch/Deb: nmap"
    echo "  6) tcpdump                  Arch/Deb: tcpdump"
    echo "  7) iftop                    Arch/Deb: iftop"
    echo "  8) netcat                   Arch: gnu-netcat   Debian: netcat"
    echo "  9) lsof                     Arch/Deb: lsof"
    echo " 10) wireshark                Arch: wireshark-qt   Debian: wireshark"
    echo ""
    echo -e "${CYAN}Dépôts sécurité (BlackArch, Kali, etc.) :${RESET} à configurer sur la distro ;"
    echo "  paquets ensuite via pacman/apt — voir wiki du dépôt (hors installman pour l’instant)."
    echo ""
    echo "  0) Retour"
    echo ""
    printf "Choix: "
    read -r ntch
    ntch=$(echo "$ntch" | tr -d '[:space:]')
    case "$ntch" in
        0 | "") return 0 ;;
        1) install_network_tools ;;
        2) log_info "Arch: sudo pacman -S bind   Debian/Ubuntu: sudo apt install bind9-dnsutils" ;;
        3) log_info "sudo pacman -S traceroute   ou   sudo apt install traceroute" ;;
        4) log_info "sudo pacman -S whois   ou   sudo apt install whois" ;;
        5) log_info "sudo pacman -S nmap   ou   sudo apt install nmap" ;;
        6) log_info "sudo pacman -S tcpdump   ou   sudo apt install tcpdump" ;;
        7) log_info "sudo pacman -S iftop   ou   sudo apt install iftop" ;;
        8) log_info "Arch: sudo pacman -S gnu-netcat   Debian: sudo apt install netcat-openbsd" ;;
        9) log_info "sudo pacman -S lsof   ou   sudo apt install lsof" ;;
        10) log_info "Arch: sudo pacman -S wireshark-qt   Debian: sudo apt install wireshark" ;;
        *) log_warn "Choix invalide" ;;
    esac
    echo ""
    read -r "?Entrée pour revenir…"
}

