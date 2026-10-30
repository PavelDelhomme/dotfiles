#!/usr/bin/env bash
# Miroir local des gros jeux (hors git). Sourcé par installers.
# shellcheck disable=SC2034

games_mirror_dir() {
    if [ -n "${DOTFILES_GAMES_MIRROR_DIR:-}" ]; then
        printf '%s\n' "$DOTFILES_GAMES_MIRROR_DIR"
        return 0
    fi
    if [ -d /data/jeux ]; then
        printf '%s\n' /data/jeux/dotfiles-mirror
        return 0
    fi
    printf '%s\n' "${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles-games-mirror"
}

games_expand() {
    # Remplace $HOME
    printf '%s' "$1" | sed "s|^\$HOME|$HOME|; s|^~|$HOME|"
}

games_find_archive() {
    # $1 = filename
    local name="$1" d f
    local -a dirs=()
    dirs+=("$(games_mirror_dir)")
    dirs+=("/data/jeux" "$HOME/Téléchargements" "$HOME/Downloads" "$HOME/Jeux")
    for d in "${dirs[@]}"; do
        [ -d "$d" ] || continue
        f="$d/$name"
        if [ -f "$f" ]; then
            printf '%s\n' "$f"
            return 0
        fi
    done
    # HTTP miroir privé optionnel
    if [ -n "${DOTFILES_GAMES_MIRROR_URL:-}" ]; then
        local dest
        dest="$(games_mirror_dir)/$name"
        mkdir -p "$(games_mirror_dir)"
        echo "[games] téléchargement $DOTFILES_GAMES_MIRROR_URL/$name …" >&2
        if curl -fL --connect-timeout 30 --max-time 0 \
            -o "$dest.partial" "${DOTFILES_GAMES_MIRROR_URL%/}/$name"; then
            mv -f "$dest.partial" "$dest"
            printf '%s\n' "$dest"
            return 0
        fi
        rm -f "$dest.partial"
    fi
    return 1
}

games_stage_archive() {
    # Copie une archive vers le miroir local
    local src="$1"
    [ -f "$src" ] || return 1
    local dest
    dest="$(games_mirror_dir)/$(basename "$src")"
    mkdir -p "$(games_mirror_dir)"
    if [ "$(readlink -f "$src")" = "$(readlink -f "$dest" 2>/dev/null || true)" ]; then
        printf '%s\n' "$dest"
        return 0
    fi
    # hardlink si même FS, sinon cp
    if ln -f "$src" "$dest" 2>/dev/null; then
        printf '%s\n' "$dest"
        return 0
    fi
    cp -a "$src" "$dest"
    printf '%s\n' "$dest"
}

games_write_desktop() {
    # args: name exec icon path categories
    local name="$1" exec_cmd="$2" icon="$3" path="$4" cats="${5:-Game;}"
    local desktop_app desktop_bureau
    desktop_app="${XDG_DATA_HOME:-$HOME/.local/share}/applications/${name// /_}.desktop"
    desktop_bureau="${XDG_DESKTOP_DIR:-$HOME/Bureau}/${name}.desktop"
    [ -d "$HOME/Bureau" ] || desktop_bureau="${XDG_DESKTOP_DIR:-$HOME/Desktop}/${name}.desktop"
    mkdir -p "$(dirname "$desktop_app")"
    cat >"$desktop_app" <<EOF
[Desktop Entry]
Type=Application
Name=$name
Comment=$name
Exec=$exec_cmd
Path=$path
Icon=${icon:-applications-games}
Terminal=false
Categories=$cats
StartupNotify=true
EOF
    chmod +x "$desktop_app"
    if [ -d "$(dirname "$desktop_bureau")" ]; then
        cp "$desktop_app" "$desktop_bureau"
        chmod +x "$desktop_bureau"
        gio set "$desktop_bureau" metadata::trusted true 2>/dev/null || true
    fi
    update-desktop-database "$(dirname "$desktop_app")" 2>/dev/null || true
    printf '%s\n' "$desktop_app"
}
