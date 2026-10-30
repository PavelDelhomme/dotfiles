#!/usr/bin/env bash
# Installe Noita (archive Linux Wine portable) → /opt/Noita
set -euo pipefail
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
# shellcheck source=/dev/null
. "$DOTFILES_DIR/scripts/lib/games_mirror.sh"

ARCHIVE_NAME="Noita_v08.04.24_Linux.tar.xz"
DEST="${NOITA_DEST:-/opt/Noita}"
log() { printf '[noita] %s\n' "$*"; }
err() { printf '[noita] ERREUR: %s\n' "$*" >&2; }

stage_sources() {
    local src
    for src in \
        "$HOME/Téléchargements/$ARCHIVE_NAME" \
        "$HOME/Downloads/$ARCHIVE_NAME" \
        "/data/jeux/$ARCHIVE_NAME" \
        "$HOME/Jeux/$ARCHIVE_NAME"; do
        if [ -f "$src" ]; then
            games_stage_archive "$src" >/dev/null
            log "miroir: $(games_mirror_dir)/$ARCHIVE_NAME"
            return 0
        fi
    done
    # Dossier déjà extrait
    if [ -d "$HOME/Téléchargements/Noita_v08.04.24_Linux/Noita" ]; then
        log "source: dossier extrait Téléchargements"
        return 0
    fi
    return 1
}

install_noita() {
    stage_sources || log "pas de source locale à stager (on cherche quand même)"

    local archive extracted_src tmp
    if archive=$(games_find_archive "$ARCHIVE_NAME"); then
        log "archive: $archive"
        tmp=$(mktemp -d)
        log "extraction…"
        tar -xJf "$archive" -C "$tmp"
        if [ -d "$tmp/Noita" ]; then
            extracted_src="$tmp/Noita"
        elif [ -d "$tmp/Noita_v08.04.24_Linux/Noita" ]; then
            extracted_src="$tmp/Noita_v08.04.24_Linux/Noita"
        else
            extracted_src=$(find "$tmp" -maxdepth 3 -type f -name start.sh -printf '%h\n' | head -1)
        fi
        [ -n "$extracted_src" ] && [ -f "$extracted_src/start.sh" ] || {
            err "start.sh introuvable dans l’archive"
            rm -rf "$tmp"
            return 1
        }
    elif [ -d "$HOME/Téléchargements/Noita_v08.04.24_Linux/Noita" ]; then
        extracted_src="$HOME/Téléchargements/Noita_v08.04.24_Linux/Noita"
        tmp=""
    else
        err "Archive absente. Place $ARCHIVE_NAME dans:"
        err "  $(games_mirror_dir)/"
        err "  ou /data/jeux/  ou  ~/Téléchargements/"
        err "Puis: installman noita"
        err "Miroir HTTP privé optionnel: export DOTFILES_GAMES_MIRROR_URL=https://ton-nas/games"
        return 1
    fi

    log "installation → $DEST"
    if [ "$(id -u)" -eq 0 ]; then
        rm -rf "$DEST"
        mkdir -p "$(dirname "$DEST")"
        cp -a "$extracted_src" "$DEST"
        chown -R "${SUDO_USER:-root}:${SUDO_USER:-root}" "$DEST" 2>/dev/null || true
    else
        sudo rm -rf "$DEST"
        sudo mkdir -p "$(dirname "$DEST")"
        sudo cp -a "$extracted_src" "$DEST"
        sudo chown -R "$USER:$USER" "$DEST"
    fi
    chmod +x "$DEST/start.sh"
    [ -n "$tmp" ] && rm -rf "$tmp"

    # Icone si présente
    local icon=applications-games
    [ -f "$DEST/game_info/icon.png" ] && icon="$DEST/game_info/icon.png"

    games_write_desktop "Noita" "$DEST/start.sh" "$icon" "$DEST" "Game;"
    mkdir -p "$HOME/.local/bin"
    cat >"$HOME/.local/bin/noita" <<EOF
#!/usr/bin/env bash
cd "$DEST" && exec ./start.sh "\$@"
EOF
    chmod +x "$HOME/.local/bin/noita"
    log "OK — lance: noita   ou raccourci bureau"
}

install_noita "$@"
