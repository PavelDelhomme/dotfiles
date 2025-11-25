#!/bin/bash
# =============================================================================
# Installation complète des outils de cybersécurité pour cyberman
# =============================================================================

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SCRIPT_DIR="$DOTFILES_DIR/scripts"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${CYAN}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

# Détecter la distribution
detect_distro() {
    if [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    else
        echo "unknown"
    fi
}

DISTRO=$(detect_distro)

# Liste complète des outils cyber
declare -A CYBER_TOOLS=(
    # Scanning & Network
    ["nmap"]="nmap"
    ["dnsenum"]="dnsenum"
    ["gobuster"]="gobuster"
    
    # Vulnerability Assessment
    ["nikto"]="nikto"
    
    # Information Gathering
    ["theHarvester"]="theharvester"
    ["whois"]="whois"
    
    # Attacks & Exploitation
    ["hydra"]="hydra"
    ["arpspoof"]="dsniff"
    ["aireplay-ng"]="aircrack-ng"
    
    # Analysis & Monitoring
    ["tcpdump"]="tcpdump"
    ["wireshark"]="wireshark-cli"
    
    # Privacy & Anonymity
    ["tor"]="tor"
    ["proxychains"]="proxychains-ng"
    
    # Utilities
    ["jq"]="jq"
)

# Packages Arch Linux
declare -A ARCH_PACKAGES=(
    ["nmap"]="nmap"
    ["dnsenum"]="dnsenum"
    ["gobuster"]="gobuster"
    ["nikto"]="nikto"
    ["theHarvester"]="theharvester"
    ["whois"]="whois"
    ["hydra"]="hydra"
    ["arpspoof"]="dsniff"
    ["aireplay-ng"]="aircrack-ng"
    ["tcpdump"]="tcpdump"
    ["wireshark"]="wireshark-cli"
    ["tor"]="tor"
    ["proxychains"]="proxychains-ng"
    ["jq"]="jq"
)

# Packages Debian/Ubuntu
declare -A DEBIAN_PACKAGES=(
    ["nmap"]="nmap"
    ["dnsenum"]="dnsenum"
    ["gobuster"]="gobuster"
    ["nikto"]="nikto"
    ["theHarvester"]="theharvester"
    ["whois"]="whois"
    ["hydra"]="hydra"
    ["arpspoof"]="dsniff"
    ["aireplay-ng"]="aircrack-ng"
    ["tcpdump"]="tcpdump"
    ["wireshark"]="wireshark-cli"
    ["tor"]="tor"
    ["proxychains"]="proxychains-ng"
    ["jq"]="jq"
)

# Packages Fedora
declare -A FEDORA_PACKAGES=(
    ["nmap"]="nmap"
    ["dnsenum"]="dnsenum"
    ["gobuster"]="gobuster"
    ["nikto"]="nikto"
    ["theHarvester"]="theharvester"
    ["whois"]="whois"
    ["hydra"]="hydra"
    ["arpspoof"]="dsniff"
    ["aireplay-ng"]="aircrack-ng"
    ["tcpdump"]="tcpdump"
    ["wireshark"]="wireshark-cli"
    ["tor"]="tor"
    ["proxychains"]="proxychains-ng"
    ["jq"]="jq"
)

install_tool() {
    local tool="$1"
    local package=""
    
    case "$DISTRO" in
        arch)
            package="${ARCH_PACKAGES[$tool]}"
            if [ -z "$package" ]; then
                log_warn "Package non défini pour $tool sur Arch Linux"
                return 1
            fi
            
            if command -v "$tool" >/dev/null 2>&1; then
                log_info "$tool déjà installé"
                return 0
            fi
            
            log_info "Installation de $tool ($package)..."
            if command -v yay >/dev/null 2>&1; then
                yay -S --noconfirm "$package" 2>/dev/null || {
                    log_warn "Échec avec yay, tentative avec pacman..."
                    sudo pacman -S --noconfirm "$package"
                }
            else
                sudo pacman -S --noconfirm "$package"
            fi
            ;;
        debian)
            package="${DEBIAN_PACKAGES[$tool]}"
            if [ -z "$package" ]; then
                log_warn "Package non défini pour $tool sur Debian"
                return 1
            fi
            
            if command -v "$tool" >/dev/null 2>&1; then
                log_info "$tool déjà installé"
                return 0
            fi
            
            log_info "Installation de $tool ($package)..."
            sudo apt-get update -qq
            sudo apt-get install -y "$package"
            ;;
        fedora)
            package="${FEDORA_PACKAGES[$tool]}"
            if [ -z "$package" ]; then
                log_warn "Package non défini pour $tool sur Fedora"
                return 1
            fi
            
            if command -v "$tool" >/dev/null 2>&1; then
                log_info "$tool déjà installé"
                return 0
            fi
            
            log_info "Installation de $tool ($package)..."
            sudo dnf install -y "$package"
            ;;
        *)
            log_error "Distribution non supportée: $DISTRO"
            return 1
            ;;
    esac
    
    # Vérifier l'installation
    if command -v "$tool" >/dev/null 2>&1; then
        log_info "✅ $tool installé avec succès"
        return 0
    else
        log_error "❌ Échec de l'installation de $tool"
        return 1
    fi
}

install_all_cyber_tools() {
    log_section "Installation complète des outils de cybersécurité"
    
    echo ""
    echo "Les outils suivants seront installés:"
    echo ""
    echo "📡 Scanning & Network:"
    echo "  • nmap - Scanner de ports et réseau"
    echo "  • dnsenum - Énumération DNS"
    echo "  • gobuster - Énumération de répertoires web"
    echo ""
    echo "🛡️  Vulnerability Assessment:"
    echo "  • nikto - Scanner de vulnérabilités web"
    echo ""
    echo "🔍 Information Gathering:"
    echo "  • theHarvester - Collecte d'informations"
    echo "  • whois - Informations domaine"
    echo ""
    echo "⚔️  Attacks & Exploitation:"
    echo "  • hydra - Brute force"
    echo "  • dsniff (arpspoof) - Attaques réseau"
    echo "  • aircrack-ng (aireplay-ng) - Sécurité Wi-Fi"
    echo ""
    echo "📊 Analysis & Monitoring:"
    echo "  • tcpdump - Capture de trafic"
    echo "  • wireshark-cli - Analyse de paquets"
    echo ""
    echo "🔒 Privacy & Anonymity:"
    echo "  • tor - Anonymat"
    echo "  • proxychains-ng - Proxy chains"
    echo ""
    echo "🛠️  Utilities:"
    echo "  • jq - Traitement JSON (requis pour workflows/rapports)"
    echo ""
    
    printf "Continuer l'installation? (O/n): "
    read -r confirm
    if [ "$confirm" = "n" ] || [ "$confirm" = "N" ]; then
        log_warn "Installation annulée"
        return 1
    fi
    
    echo ""
    log_section "Installation en cours..."
    
    local installed=0
    local failed=0
    local skipped=0
    
    for tool in "${!CYBER_TOOLS[@]}"; do
        if install_tool "$tool"; then
            ((installed++))
        else
            ((failed++))
        fi
    done
    
    echo ""
    log_section "Résumé de l'installation"
    echo ""
    echo "✅ Installés: $installed"
    echo "❌ Échecs: $failed"
    echo ""
    
    if [ $failed -eq 0 ]; then
        log_info "🎉 Tous les outils ont été installés avec succès!"
        echo ""
        log_info "Vous pouvez maintenant utiliser cyberman:"
        echo "  cyberman"
        echo ""
        log_info "Ou installer les dépendances pour workflows/rapports:"
        echo "  bash $SCRIPT_DIR/tools/install_cyberman_deps.sh"
    else
        log_warn "Certains outils n'ont pas pu être installés"
        log_info "Vous pouvez réessayer l'installation manuellement"
    fi
    
    return 0
}

# Installation sélective
install_selective() {
    log_section "Installation sélective des outils cyber"
    
    echo ""
    echo "Sélectionnez les catégories à installer:"
    echo ""
    echo "1. 📡 Scanning & Network (nmap, dnsenum, gobuster)"
    echo "2. 🛡️  Vulnerability Assessment (nikto)"
    echo "3. 🔍 Information Gathering (theHarvester, whois)"
    echo "4. ⚔️  Attacks & Exploitation (hydra, dsniff, aircrack-ng)"
    echo "5. 📊 Analysis & Monitoring (tcpdump, wireshark-cli)"
    echo "6. 🔒 Privacy & Anonymity (tor, proxychains-ng)"
    echo "7. 🛠️  Utilities (jq)"
    echo "8. Tout installer"
    echo "0. Annuler"
    echo ""
    printf "Choix (séparés par des espaces, ex: 1 2 3): "
    read -r choices
    
    if [ -z "$choices" ] || [ "$choices" = "0" ]; then
        log_warn "Installation annulée"
        return 1
    fi
    
    declare -A categories=(
        ["1"]="nmap dnsenum gobuster"
        ["2"]="nikto"
        ["3"]="theHarvester whois"
        ["4"]="hydra arpspoof aireplay-ng"
        ["5"]="tcpdump wireshark"
        ["6"]="tor proxychains"
        ["7"]="jq"
    )
    
    local tools_to_install=()
    
    for choice in $choices; do
        if [ "$choice" = "8" ]; then
            install_all_cyber_tools
            return $?
        elif [ -n "${categories[$choice]}" ]; then
            for tool in ${categories[$choice]}; do
                tools_to_install+=("$tool")
            done
        fi
    done
    
    if [ ${#tools_to_install[@]} -eq 0 ]; then
        log_error "Aucun outil sélectionné"
        return 1
    fi
    
    echo ""
    log_section "Installation des outils sélectionnés..."
    
    local installed=0
    local failed=0
    
    for tool in "${tools_to_install[@]}"; do
        if install_tool "$tool"; then
            ((installed++))
        else
            ((failed++))
        fi
    done
    
    echo ""
    log_info "✅ Installés: $installed | ❌ Échecs: $failed"
    
    return 0
}

# Menu principal
main() {
    log_section "Installation des outils de cybersécurité"
    
    echo ""
    echo "Options:"
    echo "  1. Installation complète (tous les outils)"
    echo "  2. Installation sélective (choisir les catégories)"
    echo "  0. Annuler"
    echo ""
    printf "Choix: "
    read -r choice
    
    case "$choice" in
        1)
            install_all_cyber_tools
            ;;
        2)
            install_selective
            ;;
        0)
            log_warn "Installation annulée"
            return 0
            ;;
        *)
            log_error "Choix invalide"
            return 1
            ;;
    esac
}

# Exécution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi

