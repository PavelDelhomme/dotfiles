#!/usr/bin/env bash
# Installe Terraria (installeur GOG .sh) → ~/GOG Games/Terraria
set -euo pipefail
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
# shellcheck source=/dev/null
. "$DOTFILES_DIR/scripts/lib/games_mirror.sh"

ARCHIVE_NAME="terraria_v1_4_5_6_89299.sh"
DEST="${TERRARIA_DEST:-$HOME/GOG Games/Terraria}"
log() { printf '[terraria] %s\n' "$*"; }
err() { printf '[terraria] ERREUR: %s\n' "$*" >&2; }

stage_sources() {
    local src
    for src in \
        "$HOME/Téléchargements/$ARCHIVE_NAME" \
        "$HOME/Downloads/$ARCHIVE_NAME" \
        "/data/jeux/$ARCHIVE_NAME"; do
        [ -f "$src" ] && games_stage_archive "$src" >/dev/null && return 0
    done
    return 1
}

install_terraria() {
    # Déjà installé ?
    if [ -x "$DEST/start.sh" ]; then
        log "déjà présent: $DEST"
        local icon="$DEST/support/icon.png"
        [ -f "$icon" ] || icon=applications-games
        games_write_desktop "Terraria" "\"$DEST/start.sh\"" "$icon" "$DEST" "Game;"
        mkdir -p "$HOME/.local/bin"
        cat >"$HOME/.local/bin/terraria" <<EOF
#!/usr/bin/env bash
exec "$DEST/start.sh" "\$@"
EOF
        chmod +x "$HOME/.local/bin/terraria"
        log "raccourcis OK — lance: terraria"
        return 0
    fi

    stage_sources || true
    local installer
    installer=$(games_find_archive "$ARCHIVE_NAME") || {
        err "Installeur absent ($ARCHIVE_NAME)."
        err "Place-le dans $(games_mirror_dir)/ ou ~/Téléchargements/"
        return 1
    }

    log "installeur: $installer"
    chmod +x "$installer"
    mkdir -p "$(dirname "$DEST")"

    # GOG mojosetup silencieux
    if ! "$installer" -- --i-agree-to-all-licenses --noreadme --nooverwrite \
        --destination "$DEST" 2>/tmp/terraria-install.log; then
        # fallback interactif-moins
        if ! "$installer" --destination "$DEST" </dev/null >>/tmp/terraria-install.log 2>&1; then
            err "échec install GOG — voir /tmp/terraria-install.log"
            return 1
        fi
    fi

    [ -x "$DEST/start.sh" ] || {
        err "start.sh manquant après install"
        return 1
    }

    local icon="$DEST/support/icon.png"
    [ -f "$icon" ] || icon=applications-games
    games_write_desktop "Terraria" "\"$DEST/start.sh\"" "$icon" "$DEST" "Game;"
    mkdir -p "$HOME/.local/bin"
    cat >"$HOME/.local/bin/terraria" <<EOF
#!/usr/bin/env bash
exec "$DEST/start.sh" "\$@"
EOF
    chmod +x "$HOME/.local/bin/terraria"
    log "OK — lance: terraria"
}

install_terraria "$@"
