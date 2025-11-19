#!/bin/bash

################################################################################
# Désinstallation auto-sync Git (systemd timer)
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Désinstallation auto-sync Git"

log_warn "⚠️  Cette opération va supprimer le système d'auto-sync Git"
log_warn "⚠️  Cela inclut :"
echo "  - Timer systemd dotfiles-sync.timer"
echo "  - Service systemd dotfiles-sync.service"
echo "  - Fichiers systemd (~/.config/systemd/user/)"
echo ""
printf "Continuer? (tapez 'OUI' en majuscules): "
read -r confirm

if [ "$confirm" != "OUI" ]; then
    log_info "Désinstallation annulée"
    exit 0
fi

SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
TIMER_FILE="$SYSTEMD_USER_DIR/dotfiles-sync.timer"
SERVICE_FILE="$SYSTEMD_USER_DIR/dotfiles-sync.service"

# Arrêter et désactiver le timer
if systemctl --user is-active --quiet dotfiles-sync.timer 2>/dev/null || \
   systemctl --user is-enabled --quiet dotfiles-sync.timer 2>/dev/null; then
    log_info "Arrêt du timer auto-sync..."
    systemctl --user stop dotfiles-sync.timer 2>/dev/null
    systemctl --user disable dotfiles-sync.timer 2>/dev/null
    log_info "✓ Timer arrêté"
fi

# Arrêter et désactiver le service
if systemctl --user is-active --quiet dotfiles-sync.service 2>/dev/null || \
   systemctl --user is-enabled --quiet dotfiles-sync.service 2>/dev/null; then
    log_info "Arrêt du service auto-sync..."
    systemctl --user stop dotfiles-sync.service 2>/dev/null
    systemctl --user disable dotfiles-sync.service 2>/dev/null
    log_info "✓ Service arrêté"
fi

# Supprimer les fichiers systemd
if [ -f "$TIMER_FILE" ]; then
    rm -f "$TIMER_FILE" && log_info "✓ Fichier timer supprimé" || log_warn "Impossible de supprimer timer"
fi

if [ -f "$SERVICE_FILE" ]; then
    rm -f "$SERVICE_FILE" && log_info "✓ Fichier service supprimé" || log_warn "Impossible de supprimer service"
fi

# Recharger systemd
systemctl --user daemon-reload 2>/dev/null || true

log_info "✅ Désinstallation auto-sync terminée"

