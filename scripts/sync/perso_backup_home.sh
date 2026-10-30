#!/usr/bin/env bash
################################################################################
# Snapshot local des données critiques de /home/pactivisme (hors secrets bruts)
# N'uploade RIEN automatiquement. Pour GitHub: utiliser les dépôts Git du projet.
################################################################################
set -euo pipefail

HOME_USER="${PERSO_HOME:-$HOME}"
STAMP=$(date +%Y%m%d-%H%M%S)
DEST_ROOT="${PERSO_BACKUP_DIR:-$HOME_USER/Backups/home-snapshots}"
DEST="$DEST_ROOT/$STAMP"
mkdir -p "$DEST"

echo "Backup → $DEST"
echo "(exclure: .ssh keys privées brutes, .gnupg, Bitwarden data, .env, HuberaRecovery/secrets)"

RSYNC=(rsync -a --info=stats2 --delete --delete-excluded)
EXCLUDE=(
    --exclude '.cache/'
    --exclude '.local/share/Trash/'
    --exclude '.npm/'
    --exclude '.gradle/caches/'
    --exclude '.cargo/registry/'
    --exclude '.android/avd/'
    --exclude '**/node_modules/'
    --exclude '**/.git/objects/'
    --exclude '.config/Bitwarden/'
    --exclude '.config/Bitwarden CLI/'
    --exclude '.ssh/id_*'
    --exclude '.gnupg/'
    --exclude 'HuberaRecovery/secrets/'
    --exclude '**/.env'
    --exclude '**/.env.*'
    --exclude '**/*.pem'
    --exclude '**/*.key'
)

# Projets + configs utiles
SOURCES=(
    "$HOME_USER/Documents/Dev/Perso"
    "$HOME_USER/dotfiles"
    "$HOME_USER/.config/dotfiles"
    "$HOME_USER/.zshrc"
    "$HOME_USER/.gitconfig"
)

mkdir -p "$DEST/Documents" "$DEST/dotfiles-meta" "$DEST/home-dot"
for src in "${SOURCES[@]}"; do
    [ -e "$src" ] || continue
    base=$(basename "$src")
    if [ -d "$src" ]; then
        mkdir -p "$DEST/tree/$base"
        "${RSYNC[@]}" "${EXCLUDE[@]}" "$src/" "$DEST/tree/$base/" || true
    else
        cp -a "$src" "$DEST/home-dot/" 2>/dev/null || true
    fi
done

# Manifeste Git (état, pas les objets lourds)
MANIFEST="$DEST/perso-git-status.txt"
if [ -x "${DOTFILES_DIR:-$HOME_USER/dotfiles}/scripts/sync/perso_git_status.sh" ]; then
    bash "${DOTFILES_DIR:-$HOME_USER/dotfiles}/scripts/sync/perso_git_status.sh" >"$MANIFEST" 2>&1 || true
fi

ln -sfn "$STAMP" "$DEST_ROOT/latest"
du -sh "$DEST" 2>/dev/null || true
echo "OK. latest → $DEST_ROOT/latest"
echo "Rappel: les repos Git restent la source de vérité sur GitHub (git push par projet)."
