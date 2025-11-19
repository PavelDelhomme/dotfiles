#!/bin/bash

################################################################################
# Désinstallation Brave Browser
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Désinstallation Brave Browser"

log_warn "⚠️  Cette opération va supprimer Brave Browser"
echo ""
printf "Continuer? (tapez 'OUI' en majuscules): "
read -r confirm

if [ "$confirm" != "OUI" ]; then
    log_info "Désinstallation annulée"
    exit 0
fi

# Détecter la distribution
if [ -f /etc/arch-release ]; then
    DISTRO="arch"
elif [ -f /etc/debian_version ]; then
    DISTRO="debian"
elif [ -f /etc/fedora-release ]; then
    DISTRO="fedora"
else
    log_error "Distribution non supportée"
    exit 1
fi

case "$DISTRO" in
    arch)
        log_info "Suppression Brave (Arch)..."
        if command -v yay &> /dev/null; then
            yay -Rns --noconfirm brave-bin 2>/dev/null && log_info "✓ Brave supprimé" || log_warn "Impossible de supprimer Brave"
        else
            sudo pacman -Rns --noconfirm brave-bin 2>/dev/null && log_info "✓ Brave supprimé" || log_warn "Impossible de supprimer Brave"
        fi
        ;;
    debian)
        log_info "Suppression Brave (Debian/Ubuntu)..."
        sudo apt remove -y brave-browser 2>/dev/null && log_info "✓ Brave supprimé" || log_warn "Impossible de supprimer Brave"
        
        # Optionnel: supprimer le dépôt
        log_warn "⚠️  Supprimer aussi le dépôt Brave?"
        printf "Supprimer dépôt? (o/n): "
        read -r remove_repo
        if [[ "$remove_repo" =~ ^[oO]$ ]]; then
            sudo rm -f /etc/apt/sources.list.d/brave-browser-release.list 2>/dev/null
            sudo rm -f /usr/share/keyrings/brave-browser-archive-keyring.gpg 2>/dev/null
            log_info "✓ Dépôt Brave supprimé"
        fi
        ;;
    fedora)
        log_info "Suppression Brave (Fedora)..."
        sudo dnf remove -y brave-browser 2>/dev/null && log_info "✓ Brave supprimé" || log_warn "Impossible de supprimer Brave"
        
        # Optionnel: supprimer le dépôt
        log_warn "⚠️  Supprimer aussi le dépôt Brave?"
        printf "Supprimer dépôt? (o/n): "
        read -r remove_repo
        if [[ "$remove_repo" =~ ^[oO]$ ]]; then
            sudo rm -f /etc/yum.repos.d/brave-browser-release.repo 2>/dev/null
            log_info "✓ Dépôt Brave supprimé"
        fi
        ;;
esac

log_info "✅ Désinstallation Brave terminée"

