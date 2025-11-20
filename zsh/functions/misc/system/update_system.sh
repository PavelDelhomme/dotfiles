#!/bin/zsh
# =============================================================================
# UPDATE_SYSTEM - Mise à jour intelligente du système selon la distribution
# =============================================================================
# DESC: Détecte automatiquement la distribution Linux et utilise le bon
#       gestionnaire de paquets pour mettre à jour le système.
#       Supporte : Arch, Debian, Ubuntu, Fedora, Gentoo, NixOS, openSUSE, etc.
# USAGE: update
# EXAMPLES:
#   update          # Mise à jour des paquets (sans upgrade)
#   upgrade         # Mise à jour complète du système
# RETURNS: 0 si succès, 1 si erreur
# =============================================================================

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Source le logger d'actions si disponible
if [ -f "$HOME/dotfiles/scripts/lib/actions_logger.sh" ]; then
    source "$HOME/dotfiles/scripts/lib/actions_logger.sh"
else
    log_action() {
        local type="$1" action="$2" status="$3" component="$4" details="$5"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$type] [$action] [$status] $component | $details" >> "$HOME/dotfiles/logs/actions.log" 2>/dev/null || true
    }
fi

################################################################################
# DESC: Détecte la distribution Linux
# USAGE: detect_distro
# RETURNS: Nom de la distribution (arch, debian, ubuntu, fedora, gentoo, nixos, opensuse, etc.)
################################################################################
detect_distro() {
    # Arch Linux et dérivés
    if [ -f /etc/arch-release ]; then
        echo "arch"
        return 0
    fi
    
    # Debian et dérivés
    if [ -f /etc/debian_version ]; then
        if [ -f /etc/lsb-release ]; then
            source /etc/lsb-release
            if [ "$DISTRIB_ID" = "Ubuntu" ]; then
                echo "ubuntu"
                return 0
            elif [ "$DISTRIB_ID" = "LinuxMint" ]; then
                echo "mint"
                return 0
            fi
        fi
        echo "debian"
        return 0
    fi
    
    # Fedora et dérivés
    if [ -f /etc/fedora-release ]; then
        echo "fedora"
        return 0
    fi
    
    # Gentoo
    if [ -f /etc/gentoo-release ] || [ -f /etc/portage/make.conf ]; then
        echo "gentoo"
        return 0
    fi
    
    # NixOS
    if [ -f /etc/nixos/configuration.nix ] || [ -f /nix/var/nix/profiles/system ]; then
        echo "nixos"
        return 0
    fi
    
    # openSUSE
    if [ -f /etc/SUSE-brand ] || [ -f /etc/os-release ] && grep -q "openSUSE" /etc/os-release 2>/dev/null; then
        echo "opensuse"
        return 0
    fi
    
    # Alpine Linux
    if [ -f /etc/alpine-release ]; then
        echo "alpine"
        return 0
    fi
    
    # Red Hat Enterprise Linux
    if [ -f /etc/redhat-release ] && grep -q "Red Hat" /etc/redhat-release 2>/dev/null; then
        echo "rhel"
        return 0
    fi
    
    # CentOS
    if [ -f /etc/redhat-release ] && grep -q "CentOS" /etc/redhat-release 2>/dev/null; then
        echo "centos"
        return 0
    fi
    
    # Autres distributions via os-release
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        case "$ID" in
            arch*|manjaro*|endeavouros*) echo "arch" ;;
            debian*|ubuntu*|mint*|kali*|parrot*) echo "debian" ;;
            fedora*) echo "fedora" ;;
            gentoo*) echo "gentoo" ;;
            nixos*) echo "nixos" ;;
            opensuse*|suse*) echo "opensuse" ;;
            alpine*) echo "alpine" ;;
            rhel*) echo "rhel" ;;
            centos*) echo "centos" ;;
            *) echo "unknown" ;;
        esac
        return 0
    fi
    
    echo "unknown"
    return 1
}

################################################################################
# DESC: Met à jour les paquets (sans upgrade)
# USAGE: update
# RETURNS: 0 si succès, 1 si erreur
################################################################################
update() {
    local distro=$(detect_distro)
    local cmd=""
    
    echo -e "${BLUE}🔄 Mise à jour des paquets...${NC}"
    echo -e "${CYAN}Distribution détectée: ${YELLOW}$distro${NC}"
    echo ""
    
    case "$distro" in
        arch|manjaro|endeavouros)
            cmd="sudo pacman -Sy"
            echo -e "${GREEN}Utilisation de: ${CYAN}pacman${NC}"
            ;;
        debian|ubuntu|mint|kali|parrot)
            cmd="sudo apt update"
            echo -e "${GREEN}Utilisation de: ${CYAN}apt${NC}"
            ;;
        fedora)
            cmd="sudo dnf check-update || sudo dnf makecache"
            echo -e "${GREEN}Utilisation de: ${CYAN}dnf${NC}"
            ;;
        gentoo)
            cmd="sudo emerge --sync"
            echo -e "${GREEN}Utilisation de: ${CYAN}emerge${NC}"
            ;;
        nixos)
            cmd="sudo nix-channel --update"
            echo -e "${GREEN}Utilisation de: ${CYAN}nix-channel${NC}"
            ;;
        opensuse)
            cmd="sudo zypper refresh"
            echo -e "${GREEN}Utilisation de: ${CYAN}zypper${NC}"
            ;;
        alpine)
            cmd="sudo apk update"
            echo -e "${GREEN}Utilisation de: ${CYAN}apk${NC}"
            ;;
        rhel|centos)
            cmd="sudo yum check-update || sudo yum makecache"
            echo -e "${GREEN}Utilisation de: ${CYAN}yum${NC}"
            ;;
        *)
            echo -e "${RED}❌ Distribution non supportée: $distro${NC}"
            echo -e "${YELLOW}Veuillez mettre à jour manuellement votre système${NC}"
            log_action "update_system" "update" "failed" "$distro" "Distribution non supportée"
            return 1
            ;;
    esac
    
    echo -e "${BLUE}Commande: ${CYAN}$cmd${NC}"
    echo ""
    
    eval "$cmd"
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Mise à jour des paquets terminée${NC}"
        log_action "update_system" "update" "success" "$distro" "Mise à jour réussie"
        return 0
    else
        echo ""
        echo -e "${RED}❌ Erreur lors de la mise à jour${NC}"
        log_action "update_system" "update" "failed" "$distro" "Erreur lors de l'exécution"
        return 1
    fi
}

################################################################################
# DESC: Met à jour complètement le système (upgrade)
# USAGE: upgrade
# RETURNS: 0 si succès, 1 si erreur
################################################################################
upgrade() {
    local distro=$(detect_distro)
    local cmd=""
    
    echo -e "${BLUE}🚀 Mise à jour complète du système...${NC}"
    echo -e "${CYAN}Distribution détectée: ${YELLOW}$distro${NC}"
    echo ""
    
    case "$distro" in
        arch|manjaro|endeavouros)
            cmd="sudo pacman -Syu"
            echo -e "${GREEN}Utilisation de: ${CYAN}pacman${NC}"
            ;;
        debian|ubuntu|mint|kali|parrot)
            cmd="sudo apt update && sudo apt upgrade -y"
            echo -e "${GREEN}Utilisation de: ${CYAN}apt${NC}"
            ;;
        fedora)
            cmd="sudo dnf upgrade -y"
            echo -e "${GREEN}Utilisation de: ${CYAN}dnf${NC}"
            ;;
        gentoo)
            cmd="sudo emerge -auDN @world"
            echo -e "${GREEN}Utilisation de: ${CYAN}emerge${NC}"
            ;;
        nixos)
            cmd="sudo nixos-rebuild switch --upgrade"
            echo -e "${GREEN}Utilisation de: ${CYAN}nixos-rebuild${NC}"
            ;;
        opensuse)
            cmd="sudo zypper update -y"
            echo -e "${GREEN}Utilisation de: ${CYAN}zypper${NC}"
            ;;
        alpine)
            cmd="sudo apk update && sudo apk upgrade"
            echo -e "${GREEN}Utilisation de: ${CYAN}apk${NC}"
            ;;
        rhel|centos)
            cmd="sudo yum update -y"
            echo -e "${GREEN}Utilisation de: ${CYAN}yum${NC}"
            ;;
        *)
            echo -e "${RED}❌ Distribution non supportée: $distro${NC}"
            echo -e "${YELLOW}Veuillez mettre à jour manuellement votre système${NC}"
            log_action "update_system" "upgrade" "failed" "$distro" "Distribution non supportée"
            return 1
            ;;
    esac
    
    echo -e "${BLUE}Commande: ${CYAN}$cmd${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Cette opération peut prendre du temps...${NC}"
    echo ""
    
    eval "$cmd"
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Mise à jour complète terminée${NC}"
        log_action "update_system" "upgrade" "success" "$distro" "Upgrade réussi"
        return 0
    else
        echo ""
        echo -e "${RED}❌ Erreur lors de la mise à jour complète${NC}"
        log_action "update_system" "upgrade" "failed" "$distro" "Erreur lors de l'exécution"
        return 1
    fi
}

