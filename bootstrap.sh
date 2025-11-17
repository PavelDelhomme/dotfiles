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
# 2. CONFIGURATION GIT GLOBALE
################################################################################
log_section "Configuration Git globale"

# Configuration par défaut (compte perso)
DEFAULT_GIT_NAME="Paul Delhomme"
DEFAULT_GIT_EMAIL="36136537+PavelDelhomme@users.noreply.github.com"

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
# 2.1. CONFIGURATION CREDENTIAL HELPER
################################################################################
log_section "Configuration credential helper"

if [ -z "$(git config --global credential.helper)" ]; then
    log_info "Configuration du credential helper (cache)..."
    git config --global credential.helper cache
    log_info "✓ Credentials stockés en cache (15min)"
else
    log_info "✓ Credential helper déjà configuré: $(git config --global credential.helper)"
fi

################################################################################
# 2.2. GÉNÉRATION CLÉ SSH (si absente)
################################################################################
log_section "Configuration SSH pour GitHub"

SSH_KEY="$HOME/.ssh/id_ed25519"
SSH_PUB_KEY="$SSH_KEY.pub"

if [ ! -f "$SSH_KEY" ]; then
    log_info "Génération de la clé SSH ED25519..."
    ssh-keygen -t ed25519 -C "$git_email" -f "$SSH_KEY" -N ""
    log_info "✓ Clé SSH générée: $SSH_KEY"
    
    # Démarrer ssh-agent
    log_info "Démarrage de ssh-agent..."
    eval "$(ssh-agent -s)" > /dev/null
    
    # Ajouter la clé
    ssh-add "$SSH_KEY" 2>/dev/null || log_warn "Impossible d'ajouter la clé au ssh-agent"
    log_info "✓ Clé ajoutée au ssh-agent"
    
    # Copier la clé publique dans le presse-papier
    if [ -f "$SSH_PUB_KEY" ]; then
        # Lire uniquement la première ligne (la clé SSH complète)
        SSH_KEY_CONTENT=$(head -n1 "$SSH_PUB_KEY" 2>/dev/null)
        
        if [ -n "$SSH_KEY_CONTENT" ]; then
            if command -v xclip &> /dev/null; then
                echo -n "$SSH_KEY_CONTENT" | xclip -selection clipboard 2>/dev/null
                log_info "✓ Clé publique copiée dans le presse-papier (xclip)"
            elif command -v wl-copy &> /dev/null; then
                echo -n "$SSH_KEY_CONTENT" | wl-copy 2>/dev/null
                log_info "✓ Clé publique copiée dans le presse-papier (wl-copy)"
            else
                log_warn "xclip/wl-copy non disponible, affichage de la clé:"
                echo "$SSH_KEY_CONTENT"
            fi
        else
            log_error "Impossible de lire la clé publique"
        fi
    else
        log_error "Fichier clé publique non trouvé: $SSH_PUB_KEY"
    fi
    
    log_warn "⚠️ Ajoutez cette clé SSH sur GitHub:"
    log_info "URL: https://github.com/settings/keys"
    
    # Ouvrir automatiquement GitHub
    if command -v xdg-open &> /dev/null; then
        xdg-open "https://github.com/settings/keys" 2>/dev/null || true
    fi
    
    read -p "Appuyez sur Entrée après avoir ajouté la clé sur GitHub..."
    
    # Tester la connexion
    log_info "Test de la connexion GitHub..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        log_info "✅ Connexion GitHub OK"
    else
        log_warn "⚠️ Connexion GitHub non vérifiée (peut être normal si clé non encore ajoutée)"
        log_info "Testez manuellement avec: ssh -T git@github.com"
    fi
else
    log_info "✓ Clé SSH déjà présente: $SSH_KEY"
    
    # Tester la connexion existante
    log_info "Test de la connexion GitHub..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        log_info "✅ Connexion GitHub OK"
    else
        log_warn "⚠️ Connexion GitHub échouée, vérifiez la clé SSH"
    fi
fi

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

printf "Lancer le menu d'installation modulaire? (o/n) [défaut: o]: "
read -r launch_menu
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
