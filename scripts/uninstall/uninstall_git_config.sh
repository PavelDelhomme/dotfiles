#!/bin/bash

################################################################################
# Désinstallation configuration Git
# Supprime user.name, user.email, credential.helper, etc.
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Désinstallation configuration Git"

log_warn "⚠️  Cette opération va supprimer la configuration Git globale"
log_warn "⚠️  Cela inclut :"
echo "  - user.name"
echo "  - user.email"
echo "  - credential.helper"
echo "  - core.editor"
echo "  - color.ui"
echo "  - init.defaultBranch"
echo ""
printf "Continuer? (tapez 'OUI' en majuscules): "
read -r confirm

if [ "$confirm" != "OUI" ]; then
    log_info "Désinstallation annulée"
    exit 0
fi

log_info "Suppression configuration Git..."

# Afficher la configuration actuelle
log_info "Configuration actuelle:"
git config --global --list 2>/dev/null | grep -E "user\.|credential\.|core\.|color\." || log_warn "Aucune configuration trouvée"

# Supprimer les configurations
git config --global --unset user.name 2>/dev/null && log_info "✓ user.name supprimé" || log_warn "user.name non configuré"
git config --global --unset user.email 2>/dev/null && log_info "✓ user.email supprimé" || log_warn "user.email non configuré"
git config --global --unset credential.helper 2>/dev/null && log_info "✓ credential.helper supprimé" || log_warn "credential.helper non configuré"
git config --global --unset core.editor 2>/dev/null && log_info "✓ core.editor supprimé" || log_warn "core.editor non configuré"
git config --global --unset color.ui 2>/dev/null && log_info "✓ color.ui supprimé" || log_warn "color.ui non configuré"
git config --global --unset init.defaultBranch 2>/dev/null && log_info "✓ init.defaultBranch supprimé" || log_warn "init.defaultBranch non configuré"

log_info "✅ Configuration Git supprimée"

