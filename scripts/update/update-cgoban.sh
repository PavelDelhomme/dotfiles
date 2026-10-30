#!/usr/bin/env bash
################################################################################
# Installe / met à jour CGoban (client KGS) dans /opt/cgoban.jar
# Source officielle: https://files.gokgs.com/javaBin/cgoban.jar
# Version annoncée: https://www.gokgs.com/download.jsp
################################################################################
set -euo pipefail

JAR_URL="${CGOBAN_JAR_URL:-https://files.gokgs.com/javaBin/cgoban.jar}"
PAGE_URL="${CGOBAN_VERSION_URL:-https://www.gokgs.com/download.jsp}"
OPT_JAR="${CGOBAN_OPT_JAR:-/opt/cgoban.jar}"
VERSION_FILE="${CGOBAN_VERSION_FILE:-/opt/cgoban.version}"
ICON_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/icons/cgoban.png"
DESKTOP_APP="${XDG_DATA_HOME:-$HOME/.local/share}/applications/cgoban.desktop"
DESKTOP_BUREAU="${XDG_DESKTOP_DIR:-$HOME/Bureau}/CGoban.desktop"
# Fallback English Desktop
[ -d "$HOME/Bureau" ] || DESKTOP_BUREAU="${XDG_DESKTOP_DIR:-$HOME/Desktop}/CGoban.desktop"

log() { printf '[cgoban] %s\n' "$*"; }
err() { printf '[cgoban] ERREUR: %s\n' "$*" >&2; }

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || { err "commande requise: $1"; return 1; }
}

fetch_remote_version() {
    local html ver
    html=$(curl -fsSL --connect-timeout 15 --max-time 30 "$PAGE_URL" 2>/dev/null || true)
    ver=$(printf '%s' "$html" | grep -oE 'CGoban v?[0-9]+\.[0-9]+\.[0-9]+' | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)
    if [ -z "$ver" ]; then
        ver=$(printf '%s' "$html" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
    fi
    printf '%s' "${ver:-unknown}"
}

local_version() {
    if [ -f "$VERSION_FILE" ]; then
        tr -d ' \n\r' <"$VERSION_FILE"
        return 0
    fi
    if [ -f "$OPT_JAR" ]; then
        printf 'installed'
        return 0
    fi
    printf 'not_installed'
}

install_java_hint() {
    if command -v java >/dev/null 2>&1; then
        return 0
    fi
    err "Java absent — installe un JRE (ex: sudo pacman -S jre-openjdk)"
    return 1
}

write_desktop() {
    local icon="$ICON_PATH"
    [ -f "$icon" ] || icon=applications-games
    mkdir -p "$(dirname "$DESKTOP_APP")" "$(dirname "$ICON_PATH")" 2>/dev/null || true
    cat >"$DESKTOP_APP" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=CGoban
GenericName=Go Client
Comment=Client Go / KGS (CGoban)
Exec=java -jar $OPT_JAR
TryExec=/usr/bin/java
Path=/opt
Icon=$icon
Terminal=false
Categories=Game;BoardGame;
Keywords=go;baduk;weiqi;kgs;cgoban;
StartupNotify=true
StartupWMClass=com-gokgs-igoweb-cgoban-CGoban
EOF
    chmod +x "$DESKTOP_APP"
    if [ -d "$(dirname "$DESKTOP_BUREAU")" ]; then
        cp "$DESKTOP_APP" "$DESKTOP_BUREAU"
        chmod +x "$DESKTOP_BUREAU"
        gio set "$DESKTOP_BUREAU" metadata::trusted true 2>/dev/null || true
    fi
    update-desktop-database "$(dirname "$DESKTOP_APP")" 2>/dev/null || true
}

extract_icon() {
    local tmp
    tmp=$(mktemp -d)
    if command -v jar >/dev/null 2>&1; then
        (cd "$tmp" && jar xf "$OPT_JAR" com/gokgs/igoweb/igoweb/client/images/icon.png 2>/dev/null) || true
    fi
    if [ ! -f "$tmp/com/gokgs/igoweb/igoweb/client/images/icon.png" ] && command -v unzip >/dev/null 2>&1; then
        unzip -q -j "$OPT_JAR" 'com/gokgs/igoweb/igoweb/client/images/icon.png' -d "$tmp" 2>/dev/null || true
    fi
    mkdir -p "$(dirname "$ICON_PATH")"
    if [ -f "$tmp/com/gokgs/igoweb/igoweb/client/images/icon.png" ]; then
        cp "$tmp/com/gokgs/igoweb/igoweb/client/images/icon.png" "$ICON_PATH"
    elif [ -f "$tmp/icon.png" ]; then
        cp "$tmp/icon.png" "$ICON_PATH"
    fi
    rm -rf "$tmp"
}

cleanup_downloads() {
    local f
    for f in \
        "$HOME/Téléchargements/cgoban.jar" \
        "$HOME/Downloads/cgoban.jar" \
        "$HOME/Bureau/cgoban.jar" \
        "$HOME/Desktop/cgoban.jar"; do
        if [ -f "$f" ]; then
            rm -f "$f" && log "supprimé: $f"
        fi
    done
}

install_or_update() {
    need_cmd curl
    install_java_hint || true

    local remote local etag_hdr etag_file force
    force="${1:-}"
    remote=$(fetch_remote_version)
    local=$(local_version)
    etag_file="${CGOBAN_ETAG_FILE:-/opt/cgoban.etag}"

    log "version locale=$local  distante=$remote"

    if [ "$force" != "--force" ] && [ -f "$OPT_JAR" ] && [ "$local" = "$remote" ] && [ "$remote" != "unknown" ]; then
        log "déjà à jour ($local)"
        write_desktop
        cleanup_downloads
        return 0
    fi

    local tmp
    tmp=$(mktemp)
    log "téléchargement $JAR_URL …"
    if ! curl -fsSL --connect-timeout 20 --max-time 180 -o "$tmp" "$JAR_URL"; then
        rm -f "$tmp"
        err "téléchargement échoué"
        return 1
    fi
    # sanity: jar zip magic PK
    if ! head -c 2 "$tmp" | grep -q 'PK'; then
        rm -f "$tmp"
        err "fichier téléchargé invalide (pas un JAR)"
        return 1
    fi

    if [ "$(id -u)" -eq 0 ]; then
        install -m 0644 "$tmp" "$OPT_JAR"
        printf '%s\n' "$remote" >"$VERSION_FILE"
        chmod 0644 "$VERSION_FILE"
    else
        sudo install -m 0644 "$tmp" "$OPT_JAR"
        printf '%s\n' "$remote" | sudo tee "$VERSION_FILE" >/dev/null
        sudo chmod 0644 "$VERSION_FILE"
    fi
    rm -f "$tmp"

    # ETag optionnel pour check rapide
    etag_hdr=$(curl -fsSI --connect-timeout 10 --max-time 20 "$JAR_URL" 2>/dev/null | awk -F': ' 'tolower($1)=="etag"{print $2}' | tr -d '\r' || true)
    if [ -n "$etag_hdr" ]; then
        if [ "$(id -u)" -eq 0 ]; then
            printf '%s\n' "$etag_hdr" >"$etag_file"
        else
            printf '%s\n' "$etag_hdr" | sudo tee "$etag_file" >/dev/null
        fi
    fi

    extract_icon
    write_desktop
    cleanup_downloads
    log "OK → $OPT_JAR (v$remote)"
    log "lance: cgoban   ou   java -jar $OPT_JAR"
}

case "${1:-update}" in
    help|-h|--help)
        cat <<EOF
update-cgoban.sh — install / maj CGoban dans /opt

  update-cgoban.sh [update]   télécharge la dernière version officielle
  update-cgoban.sh --force    force le re-téléchargement
  update-cgoban.sh check      affiche locale vs distante
  update-cgoban.sh version    version locale
  update-cgoban.sh remote     version distante (download.jsp)
EOF
        ;;
    check|status)
        printf 'local=%s\nremote=%s\njar=%s\n' "$(local_version)" "$(fetch_remote_version)" \
            "$([ -f "$OPT_JAR" ] && echo present || echo absent)"
        ;;
    version|local)
        local_version; echo
        ;;
    remote|latest)
        fetch_remote_version; echo
        ;;
    update|install|run|--force)
        if [ "${1:-}" = "--force" ]; then install_or_update --force
        else install_or_update
        fi
        ;;
    *)
        err "commande inconnue: $1 (help)"
        exit 1
        ;;
esac
