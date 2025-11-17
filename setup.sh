#!/bin/bash

################################################################################
# Dotfiles Setup Script
# Paul Delhomme - Initialisation automatique de l'environnement dotfiles
################################################################################

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

DOTFILES_DIR="$HOME/dotfiles"

################################################################################
# SECTION 1: VÉRIFICATIONS PRÉALABLES
################################################################################
log_section "Vérification de l'environnement"

# Vérifier qu'on est bien dans ~/dotfiles
if [ ! -d "$DOTFILES_DIR" ]; then
    log_error "Le dossier $DOTFILES_DIR n'existe pas!"
    log_warn "Clonez d'abord le repo: git clone git@github.com:PavelDelhomme/dotfiles.git ~/dotfiles"
    exit 1
fi

cd "$DOTFILES_DIR"
log_info "Dossier dotfiles trouvé: $DOTFILES_DIR"

################################################################################
# SECTION 2: CRÉATION DES SYMLINKS
################################################################################
log_section "Création des symlinks"

# Backup des fichiers existants
backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

backup_and_link() {
    local source="$1"
    local target="$2"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        log_warn "Sauvegarde de $target existant..."
        mkdir -p "$backup_dir"
        mv "$target" "$backup_dir/"
    fi

    if [ -L "$target" ]; then
        log_info "Symlink existant pour $target, suppression..."
        rm "$target"
    fi

    ln -sf "$source" "$target"
    log_info "Symlink créé: $target -> $source"
}

# Créer les symlinks pour les fichiers de config
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    backup_and_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
fi

if [ -f "$DOTFILES_DIR/.gitconfig" ]; then
    backup_and_link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
fi

if [ -f "$DOTFILES_DIR/.vimrc" ]; then
    backup_and_link "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
fi

if [ -f "$DOTFILES_DIR/.tmux.conf" ]; then
    backup_and_link "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
fi

################################################################################
# SECTION 3: SOURCING DANS .zshrc
################################################################################
log_section "Configuration du sourcing .zshrc"

ZSHRC="$HOME/.zshrc"

# Si .zshrc n'existe pas, en créer un minimal
if [ ! -f "$ZSHRC" ]; then
    log_warn ".zshrc n'existe pas, création d'un fichier minimal..."
    cat > "$ZSHRC" <<'EOF'
# ZSH Configuration
# Managed by dotfiles

EOF
    log_info ".zshrc créé"
fi

# Vérifier si le sourcing est déjà présent
if grep -q "source.*dotfiles" "$ZSHRC" 2>/dev/null; then
    log_info "Dotfiles déjà sourcé dans .zshrc"
else
    log_info "Ajout du sourcing dotfiles dans .zshrc..."
    cat >> "$ZSHRC" <<EOF

# ═══════════════════════════════════
# Dotfiles configuration
# ═══════════════════════════════════

# Source environment variables
[ -f ~/dotfiles/.env ] && source ~/dotfiles/.env

# Source aliases
[ -f ~/dotfiles/aliases.zsh ] && source ~/dotfiles/aliases.zsh

# Source functions
[ -f ~/dotfiles/functions.zsh ] && source ~/dotfiles/functions.zsh

# Source custom zsh config if separate
[ -f ~/dotfiles/zshrc.custom ] && source ~/dotfiles/zshrc.custom
EOF
    log_info "Sourcing ajouté à .zshrc"
fi

################################################################################
# SECTION 4: CRÉATION DES FICHIERS MANQUANTS
################################################################################
log_section "Création des fichiers de configuration manquants"

# Créer .env s'il n'existe pas
if [ ! -f "$DOTFILES_DIR/.env" ]; then
    log_info "Création de .env avec les variables d'environnement..."
    cat > "$DOTFILES_DIR/.env" <<'EOF'
# ═══════════════════════════════════
# Environment Variables
# ═══════════════════════════════════

# Java (for Flutter/Android)
export JAVA_HOME='/usr/lib/jvm/java-11-openjdk'
export PATH=$JAVA_HOME/bin:$PATH

# Android SDK
export ANDROID_SDK_ROOT='/opt/android-sdk'
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools/
export PATH=$PATH:$ANDROID_SDK_ROOT/tools/bin/
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/tools/

# Flutter
export PATH=$PATH:/opt/flutter/bin

# Local binaries
export PATH=$PATH:$HOME/.local/bin

# Node.js global packages
export PATH=$PATH:$HOME/.npm-global/bin

# Cargo (Rust)
export PATH=$PATH:$HOME/.cargo/bin
EOF
    log_info ".env créé avec variables Flutter/Android/Node"
else
    log_info ".env déjà présent"
fi

# Créer aliases.zsh s'il n'existe pas
if [ ! -f "$DOTFILES_DIR/aliases.zsh" ]; then
    log_info "Création de aliases.zsh..."
    cat > "$DOTFILES_DIR/aliases.zsh" <<'EOF'
# ═══════════════════════════════════
# Aliases
# ═══════════════════════════════════

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Listing
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'

# Docker
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'

# Système
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -R'

# Cursors update
alias update-cursor='~/.local/bin/update-cursor.sh'

# Flutter
alias fl='flutter'
alias fld='flutter doctor'
alias flr='flutter run'
alias flc='flutter clean'

# Manjaro specific
alias yayup='yay -Syu'
EOF
    log_info "aliases.zsh créé"
else
    log_info "aliases.zsh déjà présent"
fi

# Créer functions.zsh s'il n'existe pas
if [ ! -f "$DOTFILES_DIR/functions.zsh" ]; then
    log_info "Création de functions.zsh..."
    cat > "$DOTFILES_DIR/functions.zsh" <<'EOF'
# ═══════════════════════════════════
# Custom Functions
# ═══════════════════════════════════

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Git clone and cd
gclone() {
    git clone "$1" && cd "$(basename "$1" .git)"
}

# Docker cleanup
docker-cleanup() {
    docker system prune -af --volumes
}

# Flutter device info
fldevices() {
    flutter devices -v
}

# Quick backup
backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}
EOF
    log_info "functions.zsh créé"
else
    log_info "functions.zsh déjà présent"
fi

################################################################################
# SECTION 5: VÉRIFIER SI MANJARO_SETUP_FINAL.SH EST PRÉSENT
################################################################################
log_section "Vérification du script d'installation système"

if [ ! -f "$DOTFILES_DIR/manjaro_setup_final.sh" ]; then
    log_warn "manjaro_setup_final.sh n'est pas présent dans le repo dotfiles"
    log_warn "Vous devriez l'ajouter au repo pour une installation complète"

    read -p "Voulez-vous lancer l'installation complète du système maintenant? (o/n): " install_choice
    if [[ "$install_choice" =~ ^[oO]$ ]]; then
        log_error "manjaro_setup_final.sh manquant, impossible de continuer"
        log_info "Ajoutez le script au repo dotfiles ou lancez-le manuellement"
    fi
else
    log_info "Script d'installation système trouvé"

    read -p "Voulez-vous lancer l'installation complète du système? (o/n): " install_choice
    if [[ "$install_choice" =~ ^[oO]$ ]]; then
        log_info "Lancement de manjaro_setup_final.sh..."
        bash "$DOTFILES_DIR/manjaro_setup_final.sh"
    else
        log_info "Installation système ignorée"
        log_warn "Pour lancer plus tard: bash ~/dotfiles/manjaro_setup_final.sh"
    fi
fi

################################################################################
# SECTION 6: PERMISSIONS ET NETTOYAGE
################################################################################
log_section "Finalisation"

# Rendre les scripts exécutables
chmod +x "$DOTFILES_DIR/setup.sh" 2>/dev/null || true
chmod +x "$DOTFILES_DIR/manjaro_setup_final.sh" 2>/dev/null || true
chmod +x "$DOTFILES_DIR"/*.sh 2>/dev/null || true

log_info "Scripts rendus exécutables"

################################################################################
# RÉSUMÉ
################################################################################
log_section "Configuration terminée!"

echo ""
log_info "✓ Symlinks créés"
log_info "✓ Sourcing configuré dans .zshrc"
log_info "✓ Fichiers de configuration créés (.env, aliases.zsh, functions.zsh)"
log_info "✓ Scripts rendus exécutables"

if [ -d "$backup_dir" ]; then
    log_warn "Anciens fichiers sauvegardés dans: $backup_dir"
fi

echo ""
log_warn "PROCHAINES ÉTAPES:"
echo "  1. Rechargez votre shell: exec zsh"
echo "  2. Vérifiez les variables: echo \$JAVA_HOME"
echo "  3. Si pas encore fait: bash ~/dotfiles/manjaro_setup_final.sh"
echo ""

log_info "Pour recharger la config: source ~/.zshrc"
