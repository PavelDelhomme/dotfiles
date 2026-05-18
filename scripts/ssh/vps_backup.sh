#!/usr/bin/env bash
# Sauvegarde locale du home VPS (rsync via alias SSH pavel-server).
# Pour un snapshot complet disque : panneau Contabo + ce script pour les données utilisateur.
set -euo pipefail

HOST="${VPS_SSH_HOST:-pavel-server}"
REMOTE_USER_HOME="${VPS_REMOTE_HOME:-/home/pavel}"
STAMP=$(date +%Y%m%d_%H%M%S)
DEST="${VPS_BACKUP_DIR:-$HOME/Backups/vps-pavel}/backup_${STAMP}"

mkdir -p "$DEST"

if ! command -v rsync >/dev/null 2>&1; then
    echo "rsync requis : sudo pacman -S rsync  (ou apt install rsync)" >&2
    exit 1
fi

echo "→ Sauvegarde $HOST:$REMOTE_USER_HOME → $DEST"
rsync -avz --progress \
    --exclude '.cache' \
    --exclude 'node_modules' \
    --exclude '.local/share/Trash' \
    "$HOST:$REMOTE_USER_HOME/" "$DEST/"

# Liste des paquets installés (utile avant upgrade)
ssh "$HOST" "dpkg -l" >"$DEST/dpkg-list.txt" 2>/dev/null || true
ssh "$HOST" "uname -a; cat /etc/os-release 2>/dev/null" >"$DEST/system-info.txt" 2>/dev/null || true

echo "✓ Sauvegarde terminée : $DEST"
echo "  Conseil : gardez aussi un snapshot Contabo (niveau hyperviseur)."
