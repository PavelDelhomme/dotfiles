#!/bin/bash

################################################################################
# Script de migration pour utilisateurs existants
# Migre la configuration existante vers la structure dotfiles centralisée
# Usage: bash ~/dotfiles/scripts/migrate_existing_user.sh
################################################################################

set +e  # Ne pas arrêter sur erreurs

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

log_section "Migration utilisateur existant vers structure dotfiles centralisée"

################################################################################
# VÉRIFICATIONS PRÉALABLES
################################################################################
if [ ! -d "$DOTFILES_DIR" ]; then
    log_error "Répertoire dotfiles non trouvé: $DOTFILES_DIR"
    log_info "Cloner d'abord le repo: git clone git@github.com:PavelDelhomme/dotfiles.git ~/dotfiles"
    exit 1
fi

################################################################################
# 1. MIGRATION .zshrc
################################################################################
log_section "1. Migration .zshrc"

if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    log_warn "Fichier .zshrc existant détecté"
    printf "Déplacer vers dotfiles et créer symlink? (o/n) [défaut: o]: "
    read -r migrate_zshrc
    migrate_zshrc=${migrate_zshrc:-o}
    
    if [[ "$migrate_zshrc" =~ ^[oO]$ ]]; then
        BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
        log_info "✓ Backup créé: $BACKUP_DIR/.zshrc"
        
        # Créer .zshrc dans dotfiles qui source zshrc_custom
        if [ ! -f "$DOTFILES_DIR/.zshrc" ]; then
            cat > "$DOTFILES_DIR/.zshrc" << 'EOF'
# Dotfiles - Configuration ZSH
# Source: zshrc_custom
if [ -f "$HOME/dotfiles/zsh/zshrc_custom" ]; then
    source "$HOME/dotfiles/zsh/zshrc_custom"
fi
EOF
            log_info "✓ Fichier .zshrc créé dans dotfiles"
        fi
        
        # Sauvegarder l'ancien .zshrc dans dotfiles pour référence
        cp "$HOME/.zshrc" "$DOTFILES_DIR/.zshrc.old"
        log_info "✓ Ancien .zshrc sauvegardé dans dotfiles/.zshrc.old"
        
        rm "$HOME/.zshrc"
        ln -s "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
        log_info "✓ Symlink .zshrc créé"
    fi
elif [ -L "$HOME/.zshrc" ]; then
    log_info "✓ .zshrc est déjà un symlink"
else
    log_info "Aucun .zshrc existant, création d'un nouveau"
    if [ ! -f "$DOTFILES_DIR/.zshrc" ]; then
        cat > "$DOTFILES_DIR/.zshrc" << 'EOF'
# Dotfiles - Configuration ZSH
# Source: zshrc_custom
if [ -f "$HOME/dotfiles/zsh/zshrc_custom" ]; then
    source "$HOME/dotfiles/zsh/zshrc_custom"
fi
EOF
    fi
    ln -s "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    log_info "✓ Symlink .zshrc créé"
fi

################################################################################
# 2. MIGRATION .gitconfig
################################################################################
log_section "2. Migration .gitconfig"

if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
    log_warn "Fichier .gitconfig existant détecté"
    printf "Déplacer vers dotfiles et créer symlink? (o/n) [défaut: o]: "
    read -r migrate_gitconfig
    migrate_gitconfig=${migrate_gitconfig:-o}
    
    if [[ "$migrate_gitconfig" =~ ^[oO]$ ]]; then
        BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        cp "$HOME/.gitconfig" "$BACKUP_DIR/.gitconfig"
        log_info "✓ Backup créé: $BACKUP_DIR/.gitconfig"
        
        cp "$HOME/.gitconfig" "$DOTFILES_DIR/.gitconfig"
        rm "$HOME/.gitconfig"
        ln -s "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
        log_info "✓ .gitconfig déplacé et symlink créé"
    fi
elif [ -L "$HOME/.gitconfig" ]; then
    log_info "✓ .gitconfig est déjà un symlink"
else
    log_info "Aucun .gitconfig existant"
    if [ ! -f "$DOTFILES_DIR/.gitconfig" ]; then
        touch "$DOTFILES_DIR/.gitconfig"
    fi
    ln -s "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
    log_info "✓ Symlink .gitconfig créé"
fi

################################################################################
# 3. MIGRATION .ssh/
################################################################################
log_section "3. Migration .ssh/"

mkdir -p "$DOTFILES_DIR/.ssh"
mkdir -p "$HOME/.ssh"

# Migration id_ed25519
if [ -f "$HOME/.ssh/id_ed25519" ] && [ ! -L "$HOME/.ssh/id_ed25519" ]; then
    log_warn "Clé SSH id_ed25519 existante détectée"
    printf "Déplacer vers dotfiles et créer symlink? (o/n) [défaut: o]: "
    read -r migrate_ssh_key
    migrate_ssh_key=${migrate_ssh_key:-o}
    
    if [[ "$migrate_ssh_key" =~ ^[oO]$ ]]; then
        BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR/.ssh"
        cp "$HOME/.ssh/id_ed25519" "$BACKUP_DIR/.ssh/id_ed25519" 2>/dev/null || true
        cp "$HOME/.ssh/id_ed25519.pub" "$BACKUP_DIR/.ssh/id_ed25519.pub" 2>/dev/null || true
        log_info "✓ Backup créé: $BACKUP_DIR/.ssh/"
        
        mv "$HOME/.ssh/id_ed25519" "$DOTFILES_DIR/.ssh/id_ed25519"
        [ -f "$HOME/.ssh/id_ed25519.pub" ] && mv "$HOME/.ssh/id_ed25519.pub" "$DOTFILES_DIR/.ssh/id_ed25519.pub"
        chmod 600 "$DOTFILES_DIR/.ssh/id_ed25519"
        chmod 644 "$DOTFILES_DIR/.ssh/id_ed25519.pub" 2>/dev/null || true
        ln -s "$DOTFILES_DIR/.ssh/id_ed25519" "$HOME/.ssh/id_ed25519"
        [ -f "$DOTFILES_DIR/.ssh/id_ed25519.pub" ] && ln -s "$DOTFILES_DIR/.ssh/id_ed25519.pub" "$HOME/.ssh/id_ed25519.pub"
        log_info "✓ Clé SSH déplacée et symlink créé"
    fi
elif [ -L "$HOME/.ssh/id_ed25519" ]; then
    log_info "✓ .ssh/id_ed25519 est déjà un symlink"
fi

# Migration config
if [ -f "$HOME/.ssh/config" ] && [ ! -L "$HOME/.ssh/config" ]; then
    log_warn "Fichier .ssh/config existant détecté"
    printf "Déplacer vers dotfiles et créer symlink? (o/n) [défaut: o]: "
    read -r migrate_ssh_config
    migrate_ssh_config=${migrate_ssh_config:-o}
    
    if [[ "$migrate_ssh_config" =~ ^[oO]$ ]]; then
        BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR/.ssh"
        cp "$HOME/.ssh/config" "$BACKUP_DIR/.ssh/config"
        log_info "✓ Backup créé: $BACKUP_DIR/.ssh/config"
        
        mv "$HOME/.ssh/config" "$DOTFILES_DIR/.ssh/config"
        chmod 600 "$DOTFILES_DIR/.ssh/config"
        ln -s "$DOTFILES_DIR/.ssh/config" "$HOME/.ssh/config"
        log_info "✓ Config SSH déplacée et symlink créé"
    fi
elif [ -L "$HOME/.ssh/config" ]; then
    log_info "✓ .ssh/config est déjà un symlink"
fi

################################################################################
# 4. VÉRIFICATION DOTFILES SOURCÉS
################################################################################
log_section "4. Vérification configuration ZSH"

if grep -q "dotfiles\|zshrc_custom" "$HOME/.zshrc" 2>/dev/null || [ -L "$HOME/.zshrc" ]; then
    log_info "✓ Configuration dotfiles détectée dans .zshrc"
else
    log_warn "Configuration dotfiles non détectée dans .zshrc"
    printf "Ajouter le sourcing de zshrc_custom? (o/n) [défaut: o]: "
    read -r add_source
    add_source=${add_source:-o}
    
    if [[ "$add_source" =~ ^[oO]$ ]]; then
        echo "" >> "$HOME/.zshrc"
        echo "# Dotfiles" >> "$HOME/.zshrc"
        echo "[ -f $DOTFILES_DIR/zsh/zshrc_custom ] && source $DOTFILES_DIR/zsh/zshrc_custom" >> "$HOME/.zshrc"
        log_info "✓ Sourcing ajouté dans .zshrc"
    fi
fi

################################################################################
# RÉSUMÉ
################################################################################
log_section "Migration terminée!"

echo ""
echo "Résumé des migrations:"
[ -L "$HOME/.zshrc" ] && echo "  ✅ $HOME/.zshrc -> $(readlink "$HOME/.zshrc")" || echo "  ⚠️  $HOME/.zshrc (non migré)"
[ -L "$HOME/.gitconfig" ] && echo "  ✅ $HOME/.gitconfig -> $(readlink "$HOME/.gitconfig")" || echo "  ⚠️  $HOME/.gitconfig (non migré)"
[ -L "$HOME/.ssh/id_ed25519" ] && echo "  ✅ $HOME/.ssh/id_ed25519 -> $(readlink "$HOME/.ssh/id_ed25519")" || echo "  ⚠️  $HOME/.ssh/id_ed25519 (non migré)"
[ -L "$HOME/.ssh/config" ] && echo "  ✅ $HOME/.ssh/config -> $(readlink "$HOME/.ssh/config")" || echo "  ⚠️  $HOME/.ssh/config (non migré)"
echo ""

log_info "✅ Migration terminée"
echo ""
log_warn "Prochaines étapes:"
echo "  1. Rechargez votre shell: exec zsh"
echo "  2. Vérifiez la configuration: bash $DOTFILES_DIR/scripts/test/validate_setup.sh"
echo "  3. Lancez setup.sh pour installer les composants manquants: bash $DOTFILES_DIR/setup.sh"
echo ""

