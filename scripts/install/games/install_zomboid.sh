#!/usr/bin/env bash
# Configure Project Zomboid (PortProton + exe Windows) + raccourcis
set -euo pipefail
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
# shellcheck source=/dev/null
. "$DOTFILES_DIR/scripts/lib/games_mirror.sh"

DEST="${ZOMBOID_DEST:-$HOME/Jeux/ProjectZomboid}"
PP_START="${PORTPROTON_START:-$HOME/PortProton/data/scripts/start.sh}"
[ -f "$PP_START" ] || PP_START="$HOME/.local/share/PortProton/data_from_portwine/scripts/start.sh"
log() { printf '[zomboid] %s\n' "$*"; }
err() { printf '[zomboid] ERREUR: %s\n' "$*" >&2; }

find_exe() {
    local f
    for f in \
        "$DEST/ProjectZomboid64.exe" \
        "$HOME/Jeux/ProjectZomboid/ProjectZomboid64.exe" \
        "$HOME/ProjectZomboid/ProjectZomboid64.exe" \
        "/data/jeux/ProjectZomboid/ProjectZomboid64.exe"; do
        [ -f "$f" ] && { printf '%s\n' "$f"; return 0; }
    done
    # recherche limitée
    f=$(find "$HOME/Jeux" /data/jeux "$HOME/PortProton" -maxdepth 5 \
        -iname 'ProjectZomboid64.exe' 2>/dev/null | head -1 || true)
    [ -n "$f" ] && { printf '%s\n' "$f"; return 0; }
    return 1
}

install_zomboid() {
    local exe icon
    if exe=$(find_exe); then
        log "exe trouvé: $exe"
        DEST=$(dirname "$exe")
    else
        err "ProjectZomboid64.exe introuvable."
        err "Place le jeu dans: $HOME/Jeux/ProjectZomboid/"
        err "  (ou archive/dossier dans $(games_mirror_dir)/ puis relance)"
        err "Le .desktop actuel pointait vers un chemin absent — on prépare quand même le lanceur."
        mkdir -p "$DEST"
        # Si miroir contient une archive .7z/.zip/.rar nommée *Zomboid*
        local arc
        arc=$(find "$(games_mirror_dir)" /data/jeux "$HOME/Téléchargements" -maxdepth 1 \
            \( -iname '*zomboid*.7z' -o -iname '*zomboid*.zip' -o -iname '*zomboid*.rar' -o -iname '*zomboid*.tar*' \) \
            2>/dev/null | head -1 || true)
        if [ -n "$arc" ]; then
            log "archive miroir: $arc — extraction manuelle recommandée vers $DEST"
            err "Extrais puis relance installman zomboid"
            return 1
        fi
        return 1
    fi

    if [ ! -f "$PP_START" ]; then
        err "PortProton start.sh introuvable ($PP_START)"
        err "installe PortProton: installman portproton"
        return 1
    fi

    icon="$HOME/PortProton/data/img/ProjectZomboid64.png"
    [ -f "$icon" ] || icon=/data/PortProton/data/img/ProjectZomboid64.png
    [ -f "$icon" ] || icon=applications-games

    local exec_cmd
    exec_cmd="env \"$PP_START\" \"$exe\""
    games_write_desktop "Project Zomboid 64" "$exec_cmd" "$icon" "$(dirname "$PP_START")" "Game;"

    mkdir -p "$HOME/.local/bin"
    cat >"$HOME/.local/bin/zomboid" <<EOF
#!/usr/bin/env bash
exec env "$PP_START" "$exe" "\$@"
EOF
    chmod +x "$HOME/.local/bin/zomboid"
    ln -sfn "$HOME/.local/bin/zomboid" "$HOME/.local/bin/projectzomboid"
    log "OK — lance: zomboid"
}

install_zomboid "$@"
