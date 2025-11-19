#!/bin/bash

################################################################################
# Installation du système de synchronisation automatique Git
# Configure un timer systemd pour synchroniser toutes les heures
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

DOTFILES_DIR="$HOME/dotfiles"
SYNC_SCRIPT="$DOTFILES_DIR/scripts/sync/git_auto_sync.sh"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

log_section "Installation synchronisation automatique Git"

# Vérifier que le script de sync existe
if [ ! -f "$SYNC_SCRIPT" ]; then
    log_error "Script de synchronisation non trouvé: $SYNC_SCRIPT"
    exit 1
fi

# Rendre le script exécutable
chmod +x "$SYNC_SCRIPT"
log_info "Script rendu exécutable"

# Créer le dossier systemd user si nécessaire
mkdir -p "$SYSTEMD_USER_DIR"
log_info "Dossier systemd user créé"

# Créer le service systemd
log_info "Création du service systemd..."
cat > "$SYSTEMD_USER_DIR/dotfiles-sync.service" <<EOF
[Unit]
Description=Synchronisation automatique dotfiles Git
After=network.target

[Service]
Type=oneshot
ExecStart=$SYNC_SCRIPT
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF

log_info "✓ Service créé: dotfiles-sync.service"

# Créer le timer systemd (toutes les heures)
log_info "Création du timer systemd (toutes les heures)..."
cat > "$SYSTEMD_USER_DIR/dotfiles-sync.timer" <<EOF
[Unit]
Description=Timer pour synchronisation automatique dotfiles
Requires=dotfiles-sync.service

[Timer]
OnBootSec=5min
OnUnitActiveSec=1h
AccuracySec=1min

[Install]
WantedBy=timers.target
EOF

log_info "✓ Timer créé: dotfiles-sync.timer"

# Recharger systemd
log_info "Rechargement de systemd..."
systemctl --user daemon-reload
log_info "✓ systemd rechargé"

# Activer et démarrer le timer
log_info "Activation du timer..."
systemctl --user enable dotfiles-sync.timer
systemctl --user start dotfiles-sync.timer
log_info "✓ Timer activé et démarré"

# Vérifier le statut
log_info "Vérification du statut..."
systemctl --user status dotfiles-sync.timer --no-pager -l || true

log_section "Installation terminée!"

echo ""
log_info "Le système de synchronisation est maintenant actif"
echo ""
log_warn "Commandes utiles:"
echo "  systemctl --user status dotfiles-sync.timer    # Vérifier le statut"
echo "  systemctl --user list-timers                    # Voir tous les timers"
echo "  systemctl --user stop dotfiles-sync.timer      # Arrêter le timer"
echo "  systemctl --user start dotfiles-sync.timer     # Démarrer le timer"
echo "  journalctl --user -u dotfiles-sync.service     # Voir les logs"
echo ""
log_info "La synchronisation se fera automatiquement toutes les heures"
log_info "Logs disponibles dans: $DOTFILES_DIR/auto_sync.log"
echo ""
