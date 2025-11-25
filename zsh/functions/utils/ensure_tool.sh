#!/bin/bash
################################################################################
# UTILITAIRE: ensure_tool - Vérifie et installe des outils si nécessaire
# Usage: source ensure_tool.sh
#        ensure_tool <tool_name> [package_name]
#
# Description:
#   Vérifie si un outil est installé et propose de l'installer si absent.
#   Détecte automatiquement la distribution (Arch, Debian, Fedora, Gentoo).
#   Supporte les mapping d'outils vers leurs noms de paquets.
################################################################################

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Détection de la distribution
# DESC: Détecte automatiquement la distribution Linux en cours d'exécution (Arch, Debian, Fedora, etc.).
# USAGE: detect_distro
# EXAMPLE: detect_distro
detect_distro() {
    if [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    elif [ -f /etc/gentoo-release ] || [ -f /etc/portage/make.conf ]; then
        echo "gentoo"
    else
        echo "unknown"
    fi
}

# Mapping outils -> paquets pour chaque distribution
get_package_name() {
    local tool="$1"
    local distro="$2"
    local package_name="$3"  # Si fourni explicitement, l'utiliser
    
    # Si un nom de paquet est fourni, l'utiliser
    if [ -n "$package_name" ]; then
        echo "$package_name"
        return 0
    fi
    
    # Mapping par défaut selon l'outil
    case "$distro" in
        arch)
            case "$tool" in
                arpspoof) echo "dsniff" ;;
                hydra) echo "hydra" ;;
                nmap) echo "nmap" ;;
                nikto) echo "nikto" ;;
                dnsenum) echo "dnsenum" ;;
                gobuster) echo "gobuster" ;;
                dirb) echo "dirb" ;;
                sqlmap) echo "sqlmap" ;;
                metasploit) echo "metasploit-framework" ;;
                tcpdump) echo "tcpdump" ;;
                wireshark) echo "wireshark-cli" ;;
                aircrack-ng) echo "aircrack-ng" ;;
                hashcat) echo "hashcat" ;;
                john) echo "john" ;;
                tor) echo "tor" ;;
                proxychains) echo "proxychains-ng" ;;
                *) echo "$tool" ;;
            esac
            ;;
        debian)
            case "$tool" in
                arpspoof) echo "dsniff" ;;
                hydra) echo "hydra" ;;
                nmap) echo "nmap" ;;
                nikto) echo "nikto" ;;
                dnsenum) echo "dnsenum" ;;
                gobuster) echo "gobuster" ;;
                dirb) echo "dirb" ;;
                sqlmap) echo "sqlmap" ;;
                metasploit) echo "metasploit-framework" ;;
                tcpdump) echo "tcpdump" ;;
                wireshark) echo "wireshark-cli" ;;
                aircrack-ng) echo "aircrack-ng" ;;
                hashcat) echo "hashcat" ;;
                john) echo "john" ;;
                tor) echo "tor" ;;
                proxychains) echo "proxychains4" ;;
                *) echo "$tool" ;;
            esac
            ;;
        fedora)
            case "$tool" in
                arpspoof) echo "dsniff" ;;
                hydra) echo "hydra" ;;
                nmap) echo "nmap" ;;
                nikto) echo "nikto" ;;
                dnsenum) echo "dnsenum" ;;
                gobuster) echo "gobuster" ;;
                dirb) echo "dirb" ;;
                sqlmap) echo "sqlmap" ;;
                metasploit) echo "metasploit-framework" ;;
                tcpdump) echo "tcpdump" ;;
                wireshark) echo "wireshark-cli" ;;
                aircrack-ng) echo "aircrack-ng" ;;
                hashcat) echo "hashcat" ;;
                john) echo "john" ;;
                tor) echo "tor" ;;
                proxychains) echo "proxychains-ng" ;;
                *) echo "$tool" ;;
            esac
            ;;
        gentoo)
            case "$tool" in
                arpspoof) echo "net-analyzer/dsniff" ;;
                hydra) echo "net-analyzer/hydra" ;;
                nmap) echo "net-analyzer/nmap" ;;
                nikto) echo "www-apps/nikto" ;;
                dnsenum) echo "net-dns/dnsenum" ;;
                gobuster) echo "net-analyzer/gobuster" ;;
                dirb) echo "net-analyzer/dirb" ;;
                sqlmap) echo "net-analyzer/sqlmap" ;;
                metasploit) echo "dev-ruby/metasploit-framework" ;;
                tcpdump) echo "net-analyzer/tcpdump" ;;
                wireshark) echo "net-analyzer/wireshark" ;;
                aircrack-ng) echo "net-wireless/aircrack-ng" ;;
                hashcat) echo "app-crypt/hashcat" ;;
                john) echo "app-crypt/john" ;;
                tor) echo "net-vpn/tor" ;;
                proxychains) echo "net-proxy/proxychains" ;;
                *) echo "$tool" ;;
            esac
            ;;
        *)
            echo "$tool"
            ;;
    esac
}

# Installation d'un paquet selon la distribution
# DESC: Installe un paquet en utilisant le gestionnaire de paquets approprié selon la distribution.
# USAGE: install_package <package_name>
# EXAMPLE: install_package docker
install_package() {
    local package="$1"
    local distro="$2"
    
    case "$distro" in
        arch)
            log_info "Installation via pacman: $package"
            sudo pacman -S --noconfirm "$package" 2>/dev/null || {
                log_warn "Paquet non trouvé dans les repos officiels"
                if command -v yay &>/dev/null; then
                    log_info "Tentative avec yay (AUR)..."
                    yay -S --noconfirm "$package" 2>/dev/null || {
                        log_error "Échec de l'installation de $package"
                        return 1
                    }
                else
                    log_error "yay non disponible. Installez $package manuellement."
                    return 1
                fi
            }
            ;;
        debian)
            log_info "Installation via apt: $package"
            sudo apt-get update -qq && sudo apt-get install -y "$package" || {
                log_error "Échec de l'installation de $package"
                return 1
            }
            ;;
        fedora)
            log_info "Installation via dnf: $package"
            sudo dnf install -y "$package" || {
                log_error "Échec de l'installation de $package"
                return 1
            }
            ;;
        gentoo)
            log_info "Installation via emerge: $package"
            sudo emerge -av "$package" || {
                log_error "Échec de l'installation de $package"
                return 1
            }
            ;;
        *)
            log_error "Distribution non supportée pour l'installation automatique"
            log_warn "Installez $package manuellement pour votre distribution"
            return 1
            ;;
    esac
}

# Fonction principale: ensure_tool
# DESC: Vérifie si un outil est installé et propose de l'installer automatiquement si absent.
# USAGE: ensure_tool <tool_name> [package_name]
# EXAMPLE: ensure_tool docker
ensure_tool() {
    local tool="$1"
    local package_name="$2"  # Nom de paquet optionnel (si différent du nom de l'outil)
    
    if [ -z "$tool" ]; then
        log_error "Usage: ensure_tool <tool_name> [package_name]"
        return 1
    fi
    
    # Vérifier si l'outil est déjà installé
    if command -v "$tool" &>/dev/null; then
        return 0
    fi
    
    # Détecter la distribution
    local distro=$(detect_distro)
    
    if [ "$distro" = "unknown" ]; then
        log_warn "Distribution non détectée. Impossible d'installer automatiquement $tool"
        log_info "Veuillez installer $tool manuellement"
        return 1
    fi
    
    # Obtenir le nom du paquet
    local package=$(get_package_name "$tool" "$distro" "$package_name")
    
    # Afficher une proposition d'installation
    log_warn "L'outil '$tool' n'est pas installé"
    log_info "Paquet requis: $package (distribution: $distro)"
    echo ""
    printf "${CYAN}Voulez-vous installer $tool maintenant? (o/n) [défaut: o]: ${NC}"
    read -r install_choice
    install_choice=${install_choice:-o}
    
    if [[ ! "$install_choice" =~ ^[oO]$ ]]; then
        log_warn "Installation annulée. L'outil $tool est requis pour continuer."
        return 1
    fi
    
    # Installer le paquet
    if install_package "$package" "$distro"; then
        log_info "✅ $tool installé avec succès"
        return 0
    else
        log_error "❌ Échec de l'installation de $tool"
        return 1
    fi
}

# Fonction pour vérifier plusieurs outils en une fois
# DESC: Vérifie et installe plusieurs outils en une seule commande.
# USAGE: ensure_tools <tool1> <tool2> ...
# EXAMPLE: ensure_tools docker git
ensure_tools() {
    local tools=("$@")
    local failed=0
    
    for tool in "${tools[@]}"; do
        if ! ensure_tool "$tool"; then
            ((failed++))
        fi
    done
    
    return $failed
}

# Alias pour compatibilité
check_and_install_tool() {
    ensure_tool "$@"
}

# Exporter les fonctions pour utilisation dans d'autres scripts
# Note: export -f ne fonctionne qu'en Bash, en Zsh on utilise des alias ou on source le fichier
if [ -n "$BASH_VERSION" ]; then
    export -f ensure_tool
    export -f ensure_tools
    export -f detect_distro
    export -f get_package_name
    export -f install_package
else
    # En Zsh/Fish, les fonctions sont déjà disponibles après le source
    # Pas besoin d'export -f
    :
fi

