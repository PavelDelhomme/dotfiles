#!/bin/bash

################################################################################
# Désinstallation configuration remote Git
# Supprime ou réinitialise le remote origin
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

log_section "Désinstallation configuration remote Git"

cd "$DOTFILES_DIR" 2>/dev/null || {
    log_error "Répertoire dotfiles non trouvé: $DOTFILES_DIR"
    exit 1
}

if [ ! -d ".git" ]; then
    log_error "Ce n'est pas un dépôt Git"
    exit 1
fi

log_info "Remote actuel:"
git remote -v

echo ""
log_warn "⚠️  Options :"
echo "1. Supprimer le remote origin"
echo "2. Réinitialiser vers HTTPS"
echo "3. Réinitialiser vers SSH"
echo "0. Annuler"
echo ""
printf "Choix: "
read -r choice

case "$choice" in
    1)
        log_info "Suppression du remote origin..."
        git remote remove origin 2>/dev/null && log_info "✅ Remote origin supprimé" || log_warn "Remote origin déjà absent"
        ;;
    2)
        log_info "Réinitialisation vers HTTPS..."
        git remote set-url origin https://github.com/PavelDelhomme/dotfiles.git
        log_info "✅ Remote réinitialisé vers HTTPS"
        ;;
    3)
        log_info "Réinitialisation vers SSH..."
        git remote set-url origin git@github.com:PavelDelhomme/dotfiles.git
        log_info "✅ Remote réinitialisé vers SSH"
        ;;
    0)
        log_info "Opération annulée"
        exit 0
        ;;
    *)
        log_error "Choix invalide"
        exit 1
        ;;
esac

log_info "Remote actuel après modification:"
git remote -v

