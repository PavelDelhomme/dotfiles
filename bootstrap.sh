#!/bin/bash

################################################################################
# Bootstrap Script - Installation dotfiles sans configuration Git préalable
# Usage: curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

################################################################################
# CONFIGURATION PAR DÉFAUT (Pactivisme)
################################################################################
DEFAULT_GIT_NAME="Pactivisme"
DEFAULT_GIT_EMAIL="dev@delhomme.ovh"
DOTFILES_REPO="https://github.com/PavelDelhomme/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

log_section "Bootstrap Installation - Dotfiles Pactivisme"

################################################################################
# 1. VÉRIFIER ET INSTALLER GIT
################################################################################
if ! command -v git >/dev/null 2>&1; then
    log_info "Git non trouvé, installation..."
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm git
    elif command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y git
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y git
    else
        log_error "Gestionnaire de paquets non supporté"
        exit 1
    fi
    log_info "✓ Git installé"
else
    log_info "✓ Git déjà présent"
fi

################################################################################
# 2. CONFIGURATION GIT GLOBALE (Pactivisme)
################################################################################
log_section "Configuration Git globale"

# Demander confirmation ou utiliser les valeurs par défaut
read -p "Nom Git (défaut: $DEFAULT_GIT_NAME): " git_name
git_name=${git_name:-"$DEFAULT_GIT_NAME"}

read -p "Email Git (défaut: $DEFAULT_GIT_EMAIL): " git_email
git_email=${git_email:-"$DEFAULT_GIT_EMAIL"}

git config --global user.name "$git_name"
git config --global user.email "$git_email"
git config --global init.defaultBranch main
git config --global core.editor vim
git config --global color.ui auto

log_info "✓ Git configuré: $git_name <$git_email>"

################################################################################
# 3. CLONER LE REPO DOTFILES
################################################################################
log_section "Clonage du repo dotfiles"

if [ -d "$DOTFILES_DIR" ]; then
    log_warn "Dossier $DOTFILES_DIR existe déjà"
    read -p "Supprimer et re-cloner? (o/n): " delete_choice
    if [[ "$delete_choice" =~ ^[oO]$ ]]; then
        rm -rf "$DOTFILES_DIR"
        log_info "Dossier supprimé"
    else
        log_info "Utilisation du dossier existant"
        cd "$DOTFILES_DIR"
        git pull origin main || git pull origin master || true
        cd ~
    fi
fi

if [ ! -d "$DOTFILES_DIR" ]; then
    log_info "Clonage de $DOTFILES_REPO..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    log_info "✓ Dotfiles clonés"
fi

################################################################################
# 4. LANCER LE SETUP DOTFILES
################################################################################
log_section "Lancement du setup dotfiles"

if [ -f "$DOTFILES_DIR/setup.sh" ]; then
    log_info "Exécution de setup.sh..."
    bash "$DOTFILES_DIR/setup.sh"
else
    log_warn "setup.sh non trouvé, création des symlinks de base..."
    # Créer les symlinks de base si setup.sh n'existe pas
    if [ -f "$DOTFILES_DIR/zsh/zshrc_custom" ]; then
        if ! grep -q "dotfiles" "$HOME/.zshrc" 2>/dev/null; then
            echo "" >> "$HOME/.zshrc"
            echo "# Dotfiles" >> "$HOME/.zshrc"
            echo "[ -f $DOTFILES_DIR/zsh/zshrc_custom ] && source $DOTFILES_DIR/zsh/zshrc_custom" >> "$HOME/.zshrc"
        fi
    fi
fi

################################################################################
# 5. MENU D'INSTALLATION MODULAIRE
################################################################################
log_section "Menu d'installation modulaire"

read -p "Lancer le menu d'installation modulaire? (o/n) [défaut: o]: " launch_menu
launch_menu=${launch_menu:-o}

if [[ "$launch_menu" =~ ^[oO]$ ]]; then
    log_info "Lancement du menu interactif..."
    bash "$DOTFILES_DIR/setup.sh"
else
    log_warn "Menu ignoré"
    log_info "Pour lancer plus tard: bash $DOTFILES_DIR/setup.sh"
fi

################################################################################
# TERMINÉ
################################################################################
log_section "Bootstrap terminé!"
log_info "Dotfiles installés et configurés"
echo ""
log_warn "Prochaines étapes:"
echo "  1. Rechargez votre shell: exec zsh"
echo "  2. Si QEMU installé: déconnectez-vous et reconnectez-vous"
echo "  3. Vérifiez les installations avec les commandes appropriées"
echo ""
