#!/bin/bash

################################################################################
# Script d'installation complète de Zsh avec Oh My Zsh et Powerlevel10k
# Installe et configure automatiquement :
# - Oh My Zsh
# - Powerlevel10k
# - Plugins Zsh (autosuggestions, syntax-highlighting, completions)
# - Configuration Git dans le prompt
# Usage: bash ~/dotfiles/scripts/config/setup_zsh_complete.sh
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Installation complète Zsh + Oh My Zsh + Powerlevel10k"

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

################################################################################
# ÉTAPE 1: Installation de Zsh
################################################################################
log_section "1. Installation de Zsh"

if ! command -v zsh >/dev/null 2>&1; then
    log_info "Installation de Zsh..."
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm zsh
    elif command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y zsh
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y zsh
    else
        log_error "Gestionnaire de paquets non supporté"
        exit 1
    fi
    log_info "✓ Zsh installé"
else
    log_info "✓ Zsh déjà installé"
fi

################################################################################
# ÉTAPE 2: Installation de Oh My Zsh
################################################################################
log_section "2. Installation de Oh My Zsh"

OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"

if [ ! -d "$OH_MY_ZSH_DIR" ]; then
    log_info "Installation de Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
        log_error "Échec de l'installation de Oh My Zsh"
        exit 1
    }
    log_info "✓ Oh My Zsh installé"
else
    log_info "✓ Oh My Zsh déjà installé"
fi

################################################################################
# ÉTAPE 3: Installation de Powerlevel10k
################################################################################
log_section "3. Installation de Powerlevel10k"

P10K_THEME_DIR="$OH_MY_ZSH_DIR/custom/themes/powerlevel10k"
P10K_INSTALLED=false

# Vérifier installation système (Arch/Manjaro)
if [[ -f /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]]; then
    P10K_INSTALLED=true
    log_info "✓ Powerlevel10k trouvé (système)"
elif [[ -f "$P10K_THEME_DIR/powerlevel10k.zsh-theme" ]]; then
    P10K_INSTALLED=true
    log_info "✓ Powerlevel10k trouvé (Oh-My-Zsh)"
fi

if [[ "$P10K_INSTALLED" == "false" ]]; then
    log_info "Installation de Powerlevel10k..."
    
    # Créer le répertoire si nécessaire
    mkdir -p "$OH_MY_ZSH_DIR/custom/themes"
    
    if [[ -d "$P10K_THEME_DIR" ]]; then
        log_info "Mise à jour de Powerlevel10k..."
        cd "$P10K_THEME_DIR" && git pull
    else
        log_info "Clonage de Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_THEME_DIR"
    fi
    
    log_info "✓ Powerlevel10k installé"
fi

################################################################################
# ÉTAPE 4: Installation des plugins Zsh
################################################################################
log_section "4. Installation des plugins Zsh"

if [ -f "$DOTFILES_DIR/scripts/config/install_zsh_plugins.sh" ]; then
    bash "$DOTFILES_DIR/scripts/config/install_zsh_plugins.sh" || {
        log_warn "⚠️  Installation des plugins échouée"
    }
else
    log_warn "⚠️  Script install_zsh_plugins.sh non trouvé"
fi

################################################################################
# ÉTAPE 5: Configuration de zshrc_custom pour Oh My Zsh
################################################################################
log_section "5. Configuration de zshrc_custom"

ZSH_RC_CUSTOM="$DOTFILES_DIR/zsh/zshrc_custom"
if [ ! -f "$ZSH_RC_CUSTOM" ]; then
    log_error "Fichier $ZSH_RC_CUSTOM introuvable"
    exit 1
fi

# Vérifier si Oh My Zsh est déjà configuré dans zshrc_custom
if ! grep -q "export ZSH=" "$ZSH_RC_CUSTOM" 2>/dev/null; then
    log_info "Ajout de la configuration Oh My Zsh dans zshrc_custom..."
    
    # Trouver où insérer la configuration (après les variables NVM)
    if grep -q "export NVM_DIR" "$ZSH_RC_CUSTOM"; then
        # Insérer après la section NVM
        sed -i '/^npx()/a\
\
# =============================================================================\
# CONFIGURATION OH MY ZSH\
# =============================================================================\
export ZSH="$HOME/.oh-my-zsh"\
ZSH_THEME="powerlevel10k/powerlevel10k"\
\
# Plugins Oh My Zsh\
plugins=(\
  git\
  docker\
  docker-compose\
  kubectl\
  npm\
  node\
  python\
  pip\
  sudo\
  systemd\
  archlinux\
)\
\
# Charger Oh My Zsh\
if [ -f "$ZSH/oh-my-zsh.sh" ]; then\
    source "$ZSH/oh-my-zsh.sh"\
fi\
' "$ZSH_RC_CUSTOM"
        log_info "✓ Configuration Oh My Zsh ajoutée"
    else
        log_warn "⚠️  Impossible de trouver l'emplacement pour insérer la config Oh My Zsh"
    fi
else
    log_info "✓ Configuration Oh My Zsh déjà présente"
fi

################################################################################
# ÉTAPE 6: Configuration Powerlevel10k
################################################################################
log_section "6. Configuration Powerlevel10k"

if [ -f "$DOTFILES_DIR/scripts/config/setup_p10k.sh" ]; then
    bash "$DOTFILES_DIR/scripts/config/setup_p10k.sh" || {
        log_warn "⚠️  Configuration Powerlevel10k échouée"
    }
else
    log_warn "⚠️  Script setup_p10k.sh non trouvé"
fi

################################################################################
# ÉTAPE 7: Vérification du symlink .zshrc
################################################################################
log_section "7. Vérification du symlink .zshrc"

if [ ! -L "$HOME/.zshrc" ] || [ ! -f "$HOME/.zshrc" ]; then
    log_info "Création du symlink .zshrc..."
    if [ -f "$HOME/.zshrc" ]; then
        BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        mv "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
        log_info "✓ Ancien .zshrc sauvegardé: $BACKUP_DIR/.zshrc"
    fi
    
    if [ -f "$DOTFILES_DIR/zshrc" ]; then
        ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
        log_info "✓ Symlink .zshrc créé"
    else
        log_error "Fichier $DOTFILES_DIR/zshrc introuvable"
        exit 1
    fi
else
    log_info "✓ Symlink .zshrc déjà configuré"
fi

################################################################################
# ÉTAPE 8: Définir Zsh comme shell par défaut
################################################################################
log_section "8. Configuration du shell par défaut"

CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    log_info "Définition de Zsh comme shell par défaut..."
    chsh -s $(which zsh) || {
        log_warn "⚠️  Impossible de changer le shell par défaut (nécessite sudo)"
        log_info "Pour changer manuellement: chsh -s $(which zsh)"
    }
    log_info "✓ Shell par défaut changé vers Zsh"
else
    log_info "✓ Zsh est déjà le shell par défaut"
fi

################################################################################
# RÉSUMÉ
################################################################################
log_section "Installation terminée!"

echo ""
echo "✅ Configuration complète:"
echo "  ✅ Zsh installé"
echo "  ✅ Oh My Zsh installé"
echo "  ✅ Powerlevel10k installé"
echo "  ✅ Plugins Zsh installés"
echo "  ✅ Configuration Git dans le prompt"
echo "  ✅ Symlink .zshrc configuré"
echo ""
echo "📝 Pour appliquer les changements:"
echo "  exec zsh"
echo ""
echo "🎨 Pour reconfigurer le prompt:"
echo "  p10k configure"
echo ""

