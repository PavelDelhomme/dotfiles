#!/bin/bash

################################################################################
# Installation Powerlevel10k - Thème Zsh avec support Git
# Installe: zsh-theme-powerlevel10k (Arch/Manjaro)
################################################################################

set +e  # Ne pas arrêter sur erreurs pour mieux gérer les problèmes

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_skip()  { echo -e "${BLUE}[→]${NC} $1"; }

is_installed() {
    command -v "$1" >/dev/null 2>&1
}

is_package_installed() {
    pacman -Q "$1" >/dev/null 2>&1
}

log_section "Installation Powerlevel10k"

################################################################################
# VÉRIFICATION SYSTÈME ARCH
################################################################################
if [ ! -f /etc/arch-release ]; then
    log_warn "Ce script est conçu pour Arch Linux / Manjaro"
    log_info "Système détecté: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || echo 'Inconnu')"
    read -p "Continuer quand même? (o/n): " continue_choice
    if [[ ! "$continue_choice" =~ ^[oO]$ ]]; then
        log_info "Installation annulée"
        exit 0
    fi
fi

################################################################################
# INSTALLATION POWERLEVEL10K
################################################################################
if is_package_installed "zsh-theme-powerlevel10k"; then
    log_skip "Powerlevel10k déjà installé"
else
    log_info "Installation de zsh-theme-powerlevel10k..."
    if sudo pacman -S --needed --noconfirm zsh-theme-powerlevel10k 2>&1; then
        log_info "✓ Powerlevel10k installé"
    else
        log_error "Erreur lors de l'installation de Powerlevel10k"
        log_info "Essayez manuellement: sudo pacman -S zsh-theme-powerlevel10k"
        return 1 2>/dev/null || exit 1
    fi
fi

################################################################################
# VÉRIFICATION GITSTATUSD
################################################################################
log_section "Vérification gitstatusd"

if [ -d /usr/share/zsh-theme-powerlevel10k/gitstatus ]; then
    log_info "✓ Répertoire gitstatus trouvé"
    
    if [ -f /usr/share/zsh-theme-powerlevel10k/gitstatus/usrbin/gitstatusd ]; then
        log_info "✓ gitstatusd trouvé"
        
        # Tester gitstatusd
        if /usr/share/zsh-theme-powerlevel10k/gitstatus/usrbin/gitstatusd --version >/dev/null 2>&1; then
            log_info "✓ gitstatusd fonctionne"
        else
            log_warn "⚠ gitstatusd présent mais ne répond pas"
        fi
    else
        log_warn "⚠ gitstatusd non trouvé dans le package"
    fi
else
    log_warn "⚠ Répertoire gitstatus non trouvé"
fi

################################################################################
# CONFIGURATION
################################################################################
log_section "Configuration"

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
P10K_DOTFILES="$DOTFILES_DIR/.p10k.zsh"
P10K_HOME="$HOME/.p10k.zsh"

# Vérifier si .p10k.zsh existe dans dotfiles
if [ -f "$P10K_DOTFILES" ]; then
    log_info "✓ Configuration .p10k.zsh trouvée dans dotfiles"
    
    # Créer un symlink si nécessaire
    if [ ! -L "$P10K_HOME" ] || [ "$(readlink "$P10K_HOME")" != "$P10K_DOTFILES" ]; then
        if [ -f "$P10K_HOME" ] && [ ! -L "$P10K_HOME" ]; then
            log_info "Création d'un backup de la configuration existante..."
            mv "$P10K_HOME" "$P10K_HOME.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
        fi
        
        log_info "Création du symlink vers la configuration dotfiles..."
        ln -sf "$P10K_DOTFILES" "$P10K_HOME"
        log_info "✓ Symlink créé: $P10K_HOME -> $P10K_DOTFILES"
    else
        log_skip "Symlink déjà configuré"
    fi
else
    log_warn "⚠ Configuration .p10k.zsh non trouvée dans dotfiles"
    log_info "Vous pouvez configurer Powerlevel10k avec: p10k configure"
fi

################################################################################
# VÉRIFICATION FINALE
################################################################################
log_section "Vérification finale"

# Vérifier que P10k peut être chargé
if [ -f /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]; then
    log_info "✓ Thème Powerlevel10k trouvé"
else
    log_warn "⚠ Thème Powerlevel10k non trouvé"
fi

# Vérifier la commande p10k
if command -v p10k >/dev/null 2>&1; then
    log_info "✓ Commande 'p10k' disponible"
else
    log_warn "⚠ Commande 'p10k' non disponible (normal si pas encore chargé dans zsh)"
fi

echo ""
log_info "✅ Installation Powerlevel10k terminée!"
echo ""
log_info "Pour utiliser Powerlevel10k:"
echo "  1. Rechargez votre shell: exec zsh"
echo "  2. Configurez si nécessaire: p10k configure"
echo "  3. Vérifiez que GITSTATUS_DIR est configuré dans ~/.zshrc ou ~/.p10k.zsh"
echo ""
log_info "Pour diagnostiquer les problèmes:"
echo "  - Vérifiez que gitstatusd est accessible"
echo "  - Vérifiez que GITSTATUS_DIR est défini"
echo "  - Vérifiez que vcs est dans LEFT_PROMPT_ELEMENTS dans .p10k.zsh"

