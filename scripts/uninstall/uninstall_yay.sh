#!/bin/bash

################################################################################
# Désinstallation yay (AUR helper)
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Désinstallation yay (AUR helper)"

# Vérifier Arch Linux
if [ ! -f /etc/arch-release ]; then
    log_error "yay n'est disponible que sur Arch Linux"
    exit 1
fi

log_warn "⚠️  Cette opération va supprimer yay (AUR helper)"
echo ""
printf "Continuer? (tapez 'OUI' en majuscules): "
read -r confirm

if [ "$confirm" != "OUI" ]; then
    log_info "Désinstallation annulée"
    exit 0
fi

if ! command -v yay &> /dev/null; then
    log_warn "yay non installé"
    exit 0
fi

log_info "Suppression yay..."
sudo pacman -Rns --noconfirm yay 2>/dev/null && log_info "✓ yay supprimé" || log_warn "Impossible de supprimer yay"

# Supprimer le cache yay (optionnel)
if [ -d "$HOME/.cache/yay" ]; then
    log_warn "⚠️  Supprimer aussi le cache yay?"
    printf "Supprimer cache? (o/n): "
    read -r remove_cache
    if [[ "$remove_cache" =~ ^[oO]$ ]]; then
        rm -rf "$HOME/.cache/yay" && log_info "✓ Cache yay supprimé" || true
    fi
fi

log_info "✅ Désinstallation yay terminée"

