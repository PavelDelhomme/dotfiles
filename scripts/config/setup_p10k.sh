#!/bin/bash

################################################################################
# Script d'installation et configuration de Powerlevel10k
# Installe p10k, configure gitstatus et crée les symlinks nécessaires
# Usage: bash ~/dotfiles/scripts/config/setup_p10k.sh
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Installation et configuration de Powerlevel10k"

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
# Chercher .p10k.zsh à la racine de dotfiles
P10K_DOTFILES="$DOTFILES_DIR/.p10k.zsh"
if [ ! -f "$P10K_DOTFILES" ]; then
    # Essayer aussi dans le répertoire courant si on est dans dotfiles
    if [ -f "$HOME/dotfiles/.p10k.zsh" ]; then
        P10K_DOTFILES="$HOME/dotfiles/.p10k.zsh"
    fi
fi
P10K_HOME="$HOME/.p10k.zsh"

# Vérifier si Powerlevel10k est déjà installé
P10K_INSTALLED=false

# Vérifier installation système (Arch/Manjaro)
if [[ -f /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]]; then
    P10K_INSTALLED=true
    log_info "✓ Powerlevel10k trouvé (système)"
elif [[ -f "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
    P10K_INSTALLED=true
    log_info "✓ Powerlevel10k trouvé (Oh-My-Zsh)"
fi

# Installer si nécessaire
if [[ "$P10K_INSTALLED" == "false" ]]; then
    log_info "Powerlevel10k non trouvé, installation..."
    
    if command -v pacman >/dev/null 2>&1; then
        # Essayer d'installer via AUR avec yay
        if command -v yay >/dev/null 2>&1; then
            log_info "Installation via AUR (yay)..."
            yay -S --noconfirm zsh-theme-powerlevel10k 2>/dev/null || {
                log_warn "⚠️  Installation via AUR échouée, installation manuelle via git..."
                install_p10k_manual
            }
        else
            log_warn "⚠️  yay non trouvé, installation manuelle via git..."
            install_p10k_manual
        fi
    else
        install_p10k_manual
    fi
fi

# Fonction pour installer p10k manuellement via git
install_p10k_manual() {
    log_info "Installation de Powerlevel10k via git..."
    OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
    P10K_THEME_DIR="$OH_MY_ZSH_DIR/custom/themes/powerlevel10k"
    
    # Créer le répertoire si nécessaire
    mkdir -p "$OH_MY_ZSH_DIR/custom/themes"
    
    if [[ -d "$P10K_THEME_DIR" ]]; then
        log_info "Mise à jour de Powerlevel10k..."
        cd "$P10K_THEME_DIR" && git pull
    else
        log_info "Clonage de Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_THEME_DIR"
    fi
    
    log_info "✓ Powerlevel10k installé dans $P10K_THEME_DIR"
}

# Vérifier que gitstatus est disponible
if [[ -d /usr/share/zsh-theme-powerlevel10k/gitstatus ]]; then
    log_info "✓ gitstatus trouvé (système)"
elif [[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/gitstatus" ]]; then
    log_info "✓ gitstatus trouvé (Oh-My-Zsh)"
else
    log_warn "⚠️  gitstatus non trouvé (sera téléchargé automatiquement par p10k)"
fi

# Créer le symlink .p10k.zsh
log_info "Configuration du symlink .p10k.zsh..."

if [[ -f "$P10K_DOTFILES" ]]; then
    # Supprimer l'ancien fichier/symlink s'il existe
    if [[ -L "$P10K_HOME" ]]; then
        rm "$P10K_HOME"
        log_info "✓ Ancien symlink supprimé"
    elif [[ -f "$P10K_HOME" ]]; then
        BACKUP_FILE="$P10K_HOME.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$P10K_HOME" "$BACKUP_FILE"
        log_info "✓ Ancien fichier sauvegardé: $BACKUP_FILE"
    fi
    
    # Créer le symlink
    ln -sf "$P10K_DOTFILES" "$P10K_HOME"
    log_info "✓ Symlink créé: $P10K_HOME -> $P10K_DOTFILES"
else
    log_warn "⚠️  Fichier $P10K_DOTFILES non trouvé"
    log_info "Création d'une configuration par défaut..."
    
    # Si p10k est installé, lancer la configuration
    if command -v p10k >/dev/null 2>&1 || [[ -f /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]]; then
        log_info "Lancement de p10k configure pour créer une configuration..."
        log_warn "⚠️  Vous devrez répondre aux questions interactives"
        echo ""
        if command -v p10k >/dev/null 2>&1; then
            p10k configure
        else
            log_info "Pour configurer p10k, lancez: p10k configure"
        fi
        
        # Après configuration, copier vers dotfiles
        if [[ -f "$P10K_HOME" ]]; then
            cp "$P10K_HOME" "$P10K_DOTFILES"
            log_info "✓ Configuration copiée vers $P10K_DOTFILES"
        fi
    fi
fi

log_section "Résumé de la configuration"

echo ""
echo "État de Powerlevel10k:"
if [[ -f /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]]; then
    echo "  ✅ Powerlevel10k installé (système)"
elif [[ -f "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
    echo "  ✅ Powerlevel10k installé (Oh-My-Zsh)"
else
    echo "  ❌ Powerlevel10k non installé"
fi

if [[ -d /usr/share/zsh-theme-powerlevel10k/gitstatus ]]; then
    echo "  ✅ gitstatus disponible"
else
    echo "  ⚠️  gitstatus non trouvé"
fi

if [[ -L "$P10K_HOME" ]]; then
    echo "  ✅ Symlink .p10k.zsh: $(readlink "$P10K_HOME")"
elif [[ -f "$P10K_HOME" ]]; then
    echo "  ⚠️  Fichier .p10k.zsh existe (pas un symlink)"
else
    echo "  ❌ .p10k.zsh n'existe pas"
fi

echo ""

log_info "✅ Configuration terminée"
echo ""
log_info "Pour appliquer les changements, rechargez votre shell :"
echo "  exec zsh"
echo ""
log_info "Pour reconfigurer le prompt, utilisez :"
echo "  p10k configure"
echo ""
log_info "Ou via configman :"
echo "  configman p10k"

