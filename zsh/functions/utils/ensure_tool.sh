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
BOLD='\033[1m'
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
# DESC: Retourne le nom du paquet approprié pour un outil selon la distribution détectée.
# USAGE: get_package_name <tool_name> <distro> [package_name]
# EXAMPLE: get_package_name docker arch
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
                whois) echo "whois" ;;
                theHarvester) echo "theharvester" ;;
                dig) echo "bind" ;;
                nslookup) echo "bind" ;;
                host) echo "bind" ;;
                traceroute) echo "traceroute" ;;
                curl) echo "curl" ;;
                wget) echo "wget" ;;
                sshpass) echo "sshpass" ;;
                python3) echo "python" ;;
                pip3) echo "python-pip" ;;
                go) echo "go" ;;
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
                whois) echo "whois" ;;
                theHarvester) echo "theharvester" ;;
                dig) echo "dnsutils" ;;
                nslookup) echo "dnsutils" ;;
                host) echo "dnsutils" ;;
                traceroute) echo "traceroute" ;;
                curl) echo "curl" ;;
                wget) echo "wget" ;;
                sshpass) echo "sshpass" ;;
                python3) echo "python3" ;;
                pip3) echo "python3-pip" ;;
                go) echo "golang" ;;
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
                whois) echo "whois" ;;
                theHarvester) echo "theharvester" ;;
                dig) echo "bind-utils" ;;
                nslookup) echo "bind-utils" ;;
                host) echo "bind-utils" ;;
                traceroute) echo "traceroute" ;;
                curl) echo "curl" ;;
                wget) echo "wget" ;;
                python3) echo "dev-lang/python" ;;
                pip3) echo "dev-python/pip" ;;
                go) echo "dev-lang/go" ;;
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
            echo -e "${CYAN}📦 Installation via pacman: $package${NC}"
            if sudo pacman -S --noconfirm "$package" 2>/dev/null; then
                return 0
            else
                echo -e "${YELLOW}⚠️  Paquet non trouvé dans les repos officiels${NC}"
                if command -v yay &>/dev/null; then
                    echo -e "${CYAN}📦 Tentative avec yay (AUR)...${NC}"
                    if yay -S --noconfirm "$package" 2>/dev/null; then
                        return 0
                    fi
                elif command -v pamac &>/dev/null; then
                    echo -e "${CYAN}📦 Tentative avec pamac (AUR)...${NC}"
                    if pamac build --no-confirm "$package" 2>/dev/null; then
                        return 0
                    fi
                fi
                echo -e "${RED}❌ Échec de l'installation de $package${NC}"
                return 1
            fi
            ;;
        debian)
            echo -e "${CYAN}📦 Installation via apt: $package${NC}"
            if sudo apt-get update -qq && sudo apt-get install -y "$package"; then
                return 0
            else
                echo -e "${RED}❌ Échec de l'installation de $package${NC}"
                return 1
            fi
            ;;
        fedora)
            echo -e "${CYAN}📦 Installation via dnf: $package${NC}"
            if sudo dnf install -y "$package"; then
                return 0
            else
                echo -e "${RED}❌ Échec de l'installation de $package${NC}"
                return 1
            fi
            ;;
        gentoo)
            echo -e "${CYAN}📦 Installation via emerge: $package${NC}"
            if sudo emerge -av "$package"; then
                return 0
            else
                echo -e "${RED}❌ Échec de l'installation de $package${NC}"
                return 1
            fi
            ;;
        *)
            echo -e "${RED}❌ Distribution non supportée pour l'installation automatique${NC}"
            echo -e "${YELLOW}💡 Installez $package manuellement pour votre distribution${NC}"
            return 1
            ;;
    esac
}

# Charger ensure_osint_tool si disponible
if [ -f "$HOME/dotfiles/zsh/functions/utils/ensure_osint_tool.sh" ]; then
    source "$HOME/dotfiles/zsh/functions/utils/ensure_osint_tool.sh" 2>/dev/null
fi

# Fonction principale: ensure_tool
# DESC: Vérifie si un outil est installé et propose de l'installer automatiquement si absent.
#       Détecte automatiquement les outils OSINT et les installe depuis GitHub.
# USAGE: ensure_tool <tool_name> [package_name]
# EXAMPLE: ensure_tool docker
# EXAMPLE: ensure_tool sherlock  # Installe depuis GitHub
ensure_tool() {
    local tool="$1"
    local package_name="$2"  # Nom de paquet optionnel (si différent du nom de l'outil)
    
    if [ -z "$tool" ]; then
        echo -e "${RED}❌ Usage: ensure_tool <tool_name> [package_name]${NC}"
        return 1
    fi
    
    # Liste des outils OSINT (installés depuis GitHub)
    local osint_tools=(
        "sherlock" "sherlock-project"
        "theharvester" "theHarvester"
        "recon-ng" "recon_ng"
        "spiderfoot" "spiderFoot"
        "taranis-ai" "taranis_ai" "taranis"
        "gosearch" "go-search"
        "darkgpt" "dark_gpt" "DarkGPT"
        "robin"
        "osint-llm" "osint_llm" "osintllm"
        "ollama"
    )
    
    # Vérifier si c'est un outil OSINT
    for osint_tool in "${osint_tools[@]}"; do
        if [ "$tool" = "$osint_tool" ]; then
            # Utiliser ensure_osint_tool pour les outils OSINT
            if type ensure_osint_tool >/dev/null 2>&1; then
                ensure_osint_tool "$tool"
                return $?
            else
                echo -e "${YELLOW}⚠️  ensure_osint_tool non disponible${NC}"
                echo -e "${CYAN}💡 Installez $tool manuellement depuis GitHub${NC}"
                return 1
            fi
        fi
    done
    
    # Vérifier si l'outil est déjà installé
    if command -v "$tool" &>/dev/null; then
        return 0
    fi
    
    # Détecter la distribution
    local distro=$(detect_distro)
    
    if [ "$distro" = "unknown" ]; then
        echo -e "${YELLOW}⚠️  Distribution non détectée. Impossible d'installer automatiquement $tool${NC}"
        echo -e "${CYAN}💡 Veuillez installer $tool manuellement${NC}"
        return 1
    fi
    
    # Obtenir le nom du paquet
    local package=$(get_package_name "$tool" "$distro" "$package_name")
    
    # Afficher une proposition d'installation
    echo ""
    echo -e "${YELLOW}⚠️  L'outil '${BOLD}$tool${NC}${YELLOW}' n'est pas installé${NC}"
    echo -e "${CYAN}📦 Paquet requis: ${BOLD}$package${NC} (distribution: $distro)"
    echo ""
    printf "${CYAN}💡 Voulez-vous installer $tool maintenant? (O/n) [défaut: O]: ${NC}"
    read -r install_choice
    install_choice=${install_choice:-O}
    
    if [[ ! "$install_choice" =~ ^[oO]$ ]]; then
        echo -e "${YELLOW}⚠️  Installation annulée. L'outil $tool est requis pour continuer.${NC}"
        echo -e "${CYAN}💡 Installez-le manuellement: ${NC}"
        case "$distro" in
            arch) echo -e "   ${GREEN}sudo pacman -S $package${NC}" ;;
            debian) echo -e "   ${GREEN}sudo apt install $package${NC}" ;;
            fedora) echo -e "   ${GREEN}sudo dnf install $package${NC}" ;;
            *) echo -e "   ${GREEN}Installez $package pour votre distribution${NC}" ;;
        esac
        return 1
    fi
    
    # Installer le paquet
    echo ""
    echo -e "${CYAN}📦 Installation de $package...${NC}"
    if install_package "$package" "$distro"; then
        echo -e "${GREEN}✅ $tool installé avec succès !${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}❌ Échec de l'installation de $tool${NC}"
        echo -e "${YELLOW}💡 Essayez d'installer manuellement: ${NC}"
        case "$distro" in
            arch) echo -e "   ${GREEN}sudo pacman -S $package${NC}" ;;
            debian) echo -e "   ${GREEN}sudo apt install $package${NC}" ;;
            fedora) echo -e "   ${GREEN}sudo dnf install $package${NC}" ;;
            *) echo -e "   ${GREEN}Installez $package pour votre distribution${NC}" ;;
        esac
        echo ""
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
# DESC: Alias pour ensure_tool. Vérifie et installe un outil si nécessaire.
# USAGE: check_and_install_tool <tool_name> [package_name]
# EXAMPLE: check_and_install_tool docker
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

