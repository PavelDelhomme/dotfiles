#!/bin/bash

################################################################################
# Script de création de symlinks pour centraliser la configuration
# Crée des symlinks vers ~/dotfiles pour .zshrc, .gitconfig, .ssh/id_ed25519, .ssh/config
# Usage: bash ~/dotfiles/scripts/config/create_symlinks.sh
################################################################################

set +e  # Ne pas arrêter sur erreurs pour continuer le traitement

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Création des symlinks pour centraliser la configuration"

################################################################################
# VÉRIFICATIONS PRÉALABLES
################################################################################
if [ ! -d "$DOTFILES_DIR" ]; then
    log_error "Répertoire dotfiles non trouvé: $DOTFILES_DIR"
    exit 1
fi

################################################################################
# 1. SYMLINK .zshrc
################################################################################
echo ""
log_info "Vérification symlink .zshrc..."

if [ -L "$HOME/.zshrc" ]; then
    CURRENT_LINK=$(readlink "$HOME/.zshrc")
    # Accepter les deux chemins : .zshrc (wrapper) ou zsh/zshrc_custom (direct)
    if [ "$CURRENT_LINK" = "$DOTFILES_DIR/zshrc" ] || \
       [ "$CURRENT_LINK" = "$DOTFILES_DIR/.zshrc" ] || \
       [ "$CURRENT_LINK" = "$DOTFILES_DIR/zsh/zshrc_custom" ]; then
        log_info "Symlink .zshrc déjà configuré: $CURRENT_LINK"
    else
        log_warn "Symlink .zshrc existe mais pointe vers: $CURRENT_LINK"
        printf "Remplacer? (o/n) [défaut: n]: "
        read -r replace_zshrc
        if [[ "$replace_zshrc" =~ ^[oO]$ ]]; then
            rm "$HOME/.zshrc"
            # Préférer le wrapper zshrc qui détecte le shell
            if [ -f "$DOTFILES_DIR/zshrc" ]; then
                ln -s "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
            else
                ln -s "$DOTFILES_DIR/zsh/zshrc_custom" "$HOME/.zshrc"
            fi
            log_info "✓ Symlink .zshrc créé"
        fi
    fi
elif [ -f "$HOME/.zshrc" ]; then
    log_warn "Fichier .zshrc existe déjà (pas un symlink)"
    printf "Créer un backup et remplacer par un symlink? (o/n) [défaut: n]: "
    read -r backup_zshrc
    if [[ "$backup_zshrc" =~ ^[oO]$ ]]; then
        BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
        log_info "✓ Backup créé: $BACKUP_DIR/.zshrc"
        rm "$HOME/.zshrc"
        # Préférer le wrapper zshrc qui détecte le shell
        if [ -f "$DOTFILES_DIR/zshrc" ]; then
            ln -s "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
        else
            ln -s "$DOTFILES_DIR/zsh/zshrc_custom" "$HOME/.zshrc"
        fi
        log_info "✓ Symlink .zshrc créé"
    fi
else
    # Créer le symlink directement vers zshrc (wrapper avec détection shell)
    if [ -f "$DOTFILES_DIR/zshrc" ]; then
        ln -s "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
    else
        # Fallback vers zshrc_custom si zshrc n'existe pas
        ln -s "$DOTFILES_DIR/zsh/zshrc_custom" "$HOME/.zshrc"
    fi
    log_info "✓ Symlink .zshrc créé"
fi

################################################################################
# 2. SYMLINK .gitconfig
################################################################################
echo ""
log_info "Vérification symlink .gitconfig..."

if [ -L "$HOME/.gitconfig" ]; then
    CURRENT_LINK=$(readlink "$HOME/.gitconfig")
    if [ "$CURRENT_LINK" = "$DOTFILES_DIR/.gitconfig" ]; then
        log_info "Symlink .gitconfig déjà configuré: $CURRENT_LINK"
    else
        log_warn "Symlink .gitconfig existe mais pointe vers: $CURRENT_LINK"
        printf "Remplacer? (o/n) [défaut: n]: "
        read -r replace_gitconfig
        if [[ "$replace_gitconfig" =~ ^[oO]$ ]]; then
            rm "$HOME/.gitconfig"
            ln -s "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
            log_info "✓ Symlink .gitconfig créé"
        fi
    fi
elif [ -f "$HOME/.gitconfig" ]; then
    log_warn "Fichier .gitconfig existe déjà (pas un symlink)"
    printf "Créer un backup et remplacer par un symlink? (o/n) [défaut: n]: "
    read -r backup_gitconfig
    if [[ "$backup_gitconfig" =~ ^[oO]$ ]]; then
        BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        cp "$HOME/.gitconfig" "$BACKUP_DIR/.gitconfig"
        log_info "✓ Backup créé: $BACKUP_DIR/.gitconfig"
        rm "$HOME/.gitconfig"
        # Créer .gitconfig dans dotfiles si nécessaire
        if [ ! -f "$DOTFILES_DIR/.gitconfig" ]; then
            cp "$BACKUP_DIR/.gitconfig" "$DOTFILES_DIR/.gitconfig"
            log_info "✓ .gitconfig copié dans dotfiles"
        fi
        ln -s "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
        log_info "✓ Symlink .gitconfig créé"
    fi
else
    # Créer .gitconfig dans dotfiles s'il n'existe pas
    if [ ! -f "$DOTFILES_DIR/.gitconfig" ]; then
        touch "$DOTFILES_DIR/.gitconfig"
        log_info "✓ Fichier .gitconfig créé dans dotfiles"
    fi
    ln -s "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
    log_info "✓ Symlink .gitconfig créé"
fi

################################################################################
# 3. SYMLINKS .ssh/id_ed25519 et .ssh/config
################################################################################
echo ""
log_info "Vérification symlinks .ssh/..."

# Créer le répertoire .ssh dans dotfiles si nécessaire
mkdir -p "$DOTFILES_DIR/.ssh"
mkdir -p "$HOME/.ssh"

# Symlink id_ed25519
if [ -L "$HOME/.ssh/id_ed25519" ]; then
    CURRENT_LINK=$(readlink "$HOME/.ssh/id_ed25519")
    if [ "$CURRENT_LINK" = "$DOTFILES_DIR/.ssh/id_ed25519" ]; then
        log_info "Symlink .ssh/id_ed25519 déjà configuré"
    else
        log_warn "Symlink .ssh/id_ed25519 existe mais pointe vers: $CURRENT_LINK"
        printf "Remplacer? (o/n) [défaut: n]: "
        read -r replace_ssh_key
        if [[ "$replace_ssh_key" =~ ^[oO]$ ]]; then
            rm "$HOME/.ssh/id_ed25519"
            if [ -f "$DOTFILES_DIR/.ssh/id_ed25519" ]; then
                ln -s "$DOTFILES_DIR/.ssh/id_ed25519" "$HOME/.ssh/id_ed25519"
                log_info "✓ Symlink .ssh/id_ed25519 créé"
            fi
        fi
    fi
elif [ -f "$HOME/.ssh/id_ed25519" ]; then
    log_warn "Fichier .ssh/id_ed25519 existe déjà (pas un symlink)"
    printf "Déplacer vers dotfiles et créer symlink? (o/n) [défaut: n]: "
    read -r move_ssh_key
    if [[ "$move_ssh_key" =~ ^[oO]$ ]]; then
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
elif [ -f "$DOTFILES_DIR/.ssh/id_ed25519" ]; then
    ln -s "$DOTFILES_DIR/.ssh/id_ed25519" "$HOME/.ssh/id_ed25519"
    [ -f "$DOTFILES_DIR/.ssh/id_ed25519.pub" ] && ln -s "$DOTFILES_DIR/.ssh/id_ed25519.pub" "$HOME/.ssh/id_ed25519.pub"
    log_info "✓ Symlink .ssh/id_ed25519 créé"
fi

# Symlink config
if [ -L "$HOME/.ssh/config" ]; then
    CURRENT_LINK=$(readlink "$HOME/.ssh/config")
    if [ "$CURRENT_LINK" = "$DOTFILES_DIR/.ssh/config" ]; then
        log_info "Symlink .ssh/config déjà configuré"
    else
        log_warn "Symlink .ssh/config existe mais pointe vers: $CURRENT_LINK"
        printf "Remplacer? (o/n) [défaut: n]: "
        read -r replace_ssh_config
        if [[ "$replace_ssh_config" =~ ^[oO]$ ]]; then
            rm "$HOME/.ssh/config"
            if [ -f "$DOTFILES_DIR/.ssh/config" ]; then
                ln -s "$DOTFILES_DIR/.ssh/config" "$HOME/.ssh/config"
                log_info "✓ Symlink .ssh/config créé"
            fi
        fi
    fi
elif [ -f "$HOME/.ssh/config" ]; then
    log_warn "Fichier .ssh/config existe déjà (pas un symlink)"
    printf "Déplacer vers dotfiles et créer symlink? (o/n) [défaut: n]: "
    read -r move_ssh_config
    if [[ "$move_ssh_config" =~ ^[oO]$ ]]; then
        BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR/.ssh"
        cp "$HOME/.ssh/config" "$BACKUP_DIR/.ssh/config"
        log_info "✓ Backup créé: $BACKUP_DIR/.ssh/config"
        mv "$HOME/.ssh/config" "$DOTFILES_DIR/.ssh/config"
        chmod 600 "$DOTFILES_DIR/.ssh/config"
        ln -s "$DOTFILES_DIR/.ssh/config" "$HOME/.ssh/config"
        log_info "✓ Config SSH déplacée et symlink créé"
    fi
elif [ -f "$DOTFILES_DIR/.ssh/config" ]; then
    ln -s "$DOTFILES_DIR/.ssh/config" "$HOME/.ssh/config"
    log_info "✓ Symlink .ssh/config créé"
fi

################################################################################
# RÉSUMÉ
################################################################################
log_section "Résumé des symlinks"

echo ""
echo "Symlinks créés/configurés :"
[ -L "$HOME/.zshrc" ] && echo "  ✅ $HOME/.zshrc -> $(readlink "$HOME/.zshrc")" || echo "  ❌ $HOME/.zshrc (non configuré)"
[ -L "$HOME/.gitconfig" ] && echo "  ✅ $HOME/.gitconfig -> $(readlink "$HOME/.gitconfig")" || echo "  ❌ $HOME/.gitconfig (non configuré)"
[ -L "$HOME/.ssh/id_ed25519" ] && echo "  ✅ $HOME/.ssh/id_ed25519 -> $(readlink "$HOME/.ssh/id_ed25519")" || echo "  ⚠️  $HOME/.ssh/id_ed25519 (optionnel)"
[ -L "$HOME/.ssh/config" ] && echo "  ✅ $HOME/.ssh/config -> $(readlink "$HOME/.ssh/config")" || echo "  ⚠️  $HOME/.ssh/config (optionnel)"
echo ""

log_info "✅ Configuration des symlinks terminée"
echo ""
log_info "Pour appliquer les changements, rechargez votre shell :"
echo "  exec zsh"

