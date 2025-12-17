#!/bin/bash

################################################################################
# Script pour résoudre les problèmes d'installation de proton-pass
# Nettoie le cache et réinstalle le paquet
# Usage: bash ~/dotfiles/scripts/config/fix_proton_pass_install.sh
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Résolution des problèmes d'installation de proton-pass"

# Nettoyer le cache yay pour proton-pass
log_info "Nettoyage du cache yay pour proton-pass..."
rm -rf ~/.cache/yay/proton-pass
log_info "✓ Cache nettoyé"

# Nettoyer les fichiers de compilation
log_info "Nettoyage des fichiers de compilation..."
rm -rf ~/.cache/yay/proton-pass/src
rm -rf ~/.cache/yay/proton-pass/pkg
log_info "✓ Fichiers de compilation nettoyés"

# Réessayer l'installation
log_info "Réinstallation de proton-pass..."
log_warn "Vous devrez peut-être répondre aux questions interactives de yay"
echo ""

if yay -S proton-pass --noconfirm; then
    log_info "✅ proton-pass installé avec succès"
else
    log_warn "⚠️  L'installation automatique a échoué"
    log_info "Essayez manuellement avec : yay -S proton-pass"
    log_info "Si le problème persiste, vérifiez le PKGBUILD sur l'AUR"
fi

