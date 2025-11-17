#!/bin/bash

################################################################################
# Installation yay (AUR Helper pour Arch Linux)
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

log_section "Installation yay (AUR Helper)"

################################################################################
# VÉRIFICATION SYSTÈME ARCH
################################################################################
if [ ! -f /etc/arch-release ]; then
    log_warn "Non applicable, système non-Arch"
    log_info "Système détecté: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "inconnu")"
    exit 0
fi

################################################################################
# VÉRIFICATION INSTALLATION EXISTANTE
################################################################################
if command -v yay &> /dev/null; then
    CURRENT_VERSION=$(yay --version | head -n1)
    log_info "✅ yay déjà présent: $CURRENT_VERSION"
    exit 0
fi

################################################################################
# INSTALLATION DES DÉPENDANCES
################################################################################
log_section "Installation des dépendances"

log_info "Installation de git et base-devel..."
sudo pacman -S --noconfirm git base-devel
log_info "✓ Dépendances installées"

################################################################################
# CLONAGE ET INSTALLATION
################################################################################
log_section "Installation depuis source"

YAY_TMP_DIR="/tmp/yay"

# Nettoyer si existe déjà
if [ -d "$YAY_TMP_DIR" ]; then
    log_info "Nettoyage du dossier temporaire..."
    rm -rf "$YAY_TMP_DIR"
fi

log_info "Clonage du repo yay..."
git clone https://aur.archlinux.org/yay.git "$YAY_TMP_DIR"

log_info "Compilation et installation..."
cd "$YAY_TMP_DIR"
makepkg -si --noconfirm

log_info "✓ yay compilé et installé"

################################################################################
# NETTOYAGE
################################################################################
log_info "Nettoyage..."
rm -rf "$YAY_TMP_DIR"
log_info "✓ Nettoyage terminé"

################################################################################
# VÉRIFICATION
################################################################################
log_section "Vérification"

if command -v yay &> /dev/null; then
    YAY_VERSION=$(yay --version | head -n1)
    log_info "✅ yay installé: $YAY_VERSION"
else
    log_error "✗ yay non trouvé après installation"
    exit 1
fi

################################################################################
# MISE À JOUR AUR
################################################################################
log_section "Mise à jour AUR"

log_info "Mise à jour de la base de données AUR..."
yay -Syu --noconfirm
log_info "✓ Base de données AUR mise à jour"

################################################################################
# CONFIGURATION YAY
################################################################################
log_section "Configuration yay"

log_info "Configuration pour ne pas demander confirmation..."
yay --save --answerclean None --answerdiff None
log_info "✓ yay configuré"

log_section "Installation terminée!"

echo ""
log_info "✅ yay installé et configuré"
echo ""
log_info "Commandes utiles:"
echo "  yay -S <package>        # Installer un paquet AUR"
echo "  yay -Syu                # Mettre à jour système + AUR"
echo "  yay -Ss <search>        # Rechercher un paquet"
echo "  yay -Rns <package>       # Supprimer un paquet"
echo ""

