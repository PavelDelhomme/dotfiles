#!/bin/bash

################################################################################
# Installation Brave Browser (optionnel)
# Support: Arch Linux, Debian/Ubuntu, Fedora
################################################################################

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

log_section "Installation Brave Browser"

################################################################################
# DEMANDE À L'UTILISATEUR
################################################################################
read -p "Installer Brave Browser? (o/n): " install_choice
if [[ ! "$install_choice" =~ ^[oO]$ ]]; then
    log_info "Installation ignorée"
    exit 0
fi

################################################################################
# DÉTECTION DE LA DISTRIBUTION
################################################################################
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

################################################################################
# INSTALLATION SELON LA DISTRO
################################################################################
case "$DISTRO" in
    arch)
        log_section "Installation Brave (Arch Linux)"
        
        # Vérifier si yay est installé
        if ! command -v yay &> /dev/null; then
            log_warn "yay non trouvé"
            read -p "Installer yay d'abord? (o/n): " install_yay
            if [[ "$install_yay" =~ ^[oO]$ ]]; then
                log_info "Installation de yay..."
                bash "$HOME/dotfiles/scripts/install/tools/install_yay.sh" || {
                    log_error "Échec installation yay"
                    exit 1
                }
            else
                log_error "yay requis pour installer Brave sur Arch Linux"
                log_info "Installez yay ou installez Brave manuellement"
                exit 1
            fi
        fi
        
        log_info "Installation via yay..."
        yay -S brave-bin --noconfirm
        log_info "✓ Brave installé via yay"
        ;;
    
    debian)
        log_section "Installation Brave (Debian/Ubuntu)"
        
        log_info "Ajout du dépôt officiel Brave..."
        
        # Installer les dépendances
        sudo apt-get install -y apt-transport-https curl gnupg
        
        # Ajouter la clé GPG
        curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg
        
        # Ajouter le dépôt
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        
        # Mettre à jour et installer
        sudo apt-get update
        sudo apt-get install -y brave-browser
        
        log_info "✓ Brave installé"
        ;;
    
    fedora)
        log_section "Installation Brave (Fedora)"
        
        log_info "Ajout du dépôt Brave..."
        
        # Installer dnf-plugins-core si nécessaire
        sudo dnf install -y dnf-plugins-core
        
        # Ajouter le dépôt
        sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
        
        # Importer la clé
        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
        
        # Installer
        sudo dnf install -y brave-browser
        
        log_info "✓ Brave installé"
        ;;
    
    *)
        log_error "Distribution non supportée"
        log_warn "Installation manuelle requise"
        log_info "Visitez: https://brave.com/linux/"
        log_info "Ou installez via Flatpak: flatpak install flathub com.brave.Browser"
        exit 1
        ;;
esac

################################################################################
# VÉRIFICATION
################################################################################
log_section "Vérification de l'installation"

if command -v brave &> /dev/null || command -v brave-browser &> /dev/null; then
    BRAVE_CMD=$(command -v brave 2>/dev/null || command -v brave-browser 2>/dev/null)
    if $BRAVE_CMD --version &> /dev/null; then
        VERSION=$($BRAVE_CMD --version 2>/dev/null | head -n1 || echo "Version inconnue")
        log_info "✅ Brave Browser installé: $VERSION"
    else
        log_info "✅ Brave Browser installé"
    fi
else
    log_warn "⚠️ Brave installé mais commande non trouvée"
    log_info "Essayez de le lancer depuis le menu applications"
fi

log_section "Installation terminée!"

echo ""
log_info "Brave Browser est maintenant installé"
echo ""
log_info "Pour lancer Brave:"
echo "  brave              # Depuis le terminal"
echo "  brave-browser      # Alternative"
echo "  # Ou depuis le menu applications"
echo ""

