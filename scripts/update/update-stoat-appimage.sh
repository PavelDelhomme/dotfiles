#!/usr/bin/env bash
################################################################################
# Installe / met à jour Stoat (ex-Revolt) AppImage depuis GitHub Releases
# Repo: https://github.com/stoatchat/for-desktop
# Cible: ~/Applications/Stoat.AppImage + shim + .desktop
################################################################################
set -euo pipefail

REPO="${STOAT_GITHUB_REPO:-stoatchat/for-desktop}"
API_URL="https://api.github.com/repos/${REPO}/releases/latest"
APP_DIR="${STOAT_APP_DIR:-${APP_DIR:-$HOME/Applications}}"
APP_PATH="${STOAT_APP_PATH:-$APP_DIR/Stoat.AppImage}"
VERSION_FILE="${STOAT_VERSION_FILE:-$APP_DIR/.stoat-version}"
SHIM="${XDG_BIN_HOME:-$HOME/.local/bin}/stoat"
DESKTOP="${XDG_DATA_HOME:-$HOME/.local/share}/applications/stoat.desktop"
DESKTOP_BUREAU="${XDG_DESKTOP_DIR:-$HOME/Bureau}/Stoat.desktop"
[ -d "$HOME/Bureau" ] || DESKTOP_BUREAU="${XDG_DESKTOP_DIR:-$HOME/Desktop}/Stoat.desktop"
ICON_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/icons/stoat.png"
BACKUP_KEEP="${BACKUP_KEEP:-3}"

log() { printf '[stoat-update] %s\n' "$*"; }
err() { printf '[stoat-update] ERREUR: %s\n' "$*" >&2; }

arch_suffix() {
    case "$(uname -m)" in
        aarch64|arm64) printf 'aarch64' ;;
        x86_64|amd64)  printf 'x86_64' ;;
        *)             printf 'x86_64' ;;
    esac
}

fetch_release() {
    local json
    json=$(curl -fsSL --connect-timeout 20 --max-time 60 \
        -H 'Accept: application/vnd.github+json' \
        -H 'User-Agent: dotfiles-stoat-updater' \
        "$API_URL") || return 1
    STOAT_REMOTE_VERSION=$(printf '%s' "$json" | python3 -c "
import sys,json,re
d=json.load(sys.stdin)
tag=d.get('tag_name') or ''
print(re.sub(r'^v','',tag))
" 2>/dev/null) || return 1
    local arch want
    arch=$(arch_suffix)
    want="anylinux-${arch}.AppImage"
    STOAT_REMOTE_URL=$(printf '%s' "$json" | python3 -c "
import sys,json
d=json.load(sys.stdin)
arch='''$arch'''
want=f'anylinux-{arch}.AppImage'
for a in d.get('assets') or []:
    n=a.get('name') or ''
    if n.endswith('.AppImage') and 'zsync' not in n.lower() and want in n:
        print(a.get('browser_download_url') or '')
        break
" 2>/dev/null) || return 1
    [ -n "$STOAT_REMOTE_VERSION" ] && [ -n "$STOAT_REMOTE_URL" ]
}

local_version() {
    if [ -f "$VERSION_FILE" ]; then
        tr -d ' \n\r' <"$VERSION_FILE"
        return 0
    fi
    if [ -f "$APP_PATH" ]; then
        # Essayer depuis le nom de backup / symlink
        local base
        base=$(basename "$(readlink -f "$APP_PATH" 2>/dev/null || echo "$APP_PATH")")
        case "$base" in
            Stoat-*-anylinux-*.AppImage)
                printf '%s' "$base" | sed -n 's/Stoat-\([0-9][0-9.]*\)-.*/\1/p'
                return 0
                ;;
        esac
        printf 'installed'
        return 0
    fi
    printf 'not_installed'
}

write_shim() {
    mkdir -p "$(dirname "$SHIM")"
    cat >"$SHIM" <<EOF
#!/usr/bin/env bash
exec "$APP_PATH" "\$@"
EOF
    chmod +x "$SHIM"
    # alias-friendly
    ln -sfn "$SHIM" "$(dirname "$SHIM")/stoatchat" 2>/dev/null || true
}

extract_icon() {
    # Optionnel: icône officielle (peut échouer hors réseau)
    mkdir -p "$(dirname "$ICON_PATH")"
    if [ ! -f "$ICON_PATH" ]; then
        curl -fsSL --connect-timeout 10 --max-time 20 \
            -o "$ICON_PATH" \
            'https://raw.githubusercontent.com/stoatchat/for-desktop/main/packages/client/assets/icon.png' \
            2>/dev/null || true
    fi
}

write_desktop() {
    local icon=applications-internet
    [ -f "$ICON_PATH" ] && icon="$ICON_PATH"
    mkdir -p "$(dirname "$DESKTOP")"
    cat >"$DESKTOP" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Stoat
GenericName=Stoat Chat
Comment=Client Stoat (ex-Revolt) — AppImage
Exec=$APP_PATH %U
TryExec=$APP_PATH
Icon=$icon
Terminal=false
Categories=Network;InstantMessaging;Chat;
Keywords=stoat;revolt;chat;discord;
StartupNotify=true
StartupWMClass=Stoat
MimeType=x-scheme-handler/stoat;
EOF
    chmod +x "$DESKTOP"
    if [ -d "$(dirname "$DESKTOP_BUREAU")" ]; then
        cp "$DESKTOP" "$DESKTOP_BUREAU"
        chmod +x "$DESKTOP_BUREAU"
        gio set "$DESKTOP_BUREAU" metadata::trusted true 2>/dev/null || true
    fi
    update-desktop-database "$(dirname "$DESKTOP")" 2>/dev/null || true
    # Handler URL stoat://
    if command -v xdg-mime >/dev/null 2>&1; then
        xdg-mime default stoat.desktop x-scheme-handler/stoat 2>/dev/null || true
    fi
}

backup_old() {
    [ -f "$APP_PATH" ] || return 0
    mkdir -p "$APP_DIR/.stoat-backups"
    local stamp dest
    stamp=$(date +%Y%m%d-%H%M%S)
    dest="$APP_DIR/.stoat-backups/Stoat-${stamp}.AppImage"
    cp -a "$APP_PATH" "$dest"
    log "backup → $dest"
    # garder les N plus récents
    ls -1t "$APP_DIR/.stoat-backups"/Stoat-*.AppImage 2>/dev/null \
        | tail -n +"$((BACKUP_KEEP + 1))" \
        | while read -r old; do rm -f "$old"; done
}

install_or_update() {
    local force="${1:-}"
    need_cmd() { command -v "$1" >/dev/null 2>&1 || { err "requis: $1"; return 1; }; }
    need_cmd curl
    need_cmd python3

    mkdir -p "$APP_DIR"

    if ! fetch_release; then
        err "impossible de lire $API_URL"
        return 1
    fi

    local local_v
    local_v=$(local_version)
    log "locale=$local_v  distante=$STOAT_REMOTE_VERSION"
    log "url=$STOAT_REMOTE_URL"

    if [ "$force" != "--force" ] && [ -f "$APP_PATH" ] \
        && [ "$local_v" = "$STOAT_REMOTE_VERSION" ]; then
        log "déjà à jour ($local_v)"
        write_shim
        write_desktop
        return 0
    fi

    local tmp named
    tmp=$(mktemp --tmpdir stoat-appimage.XXXXXX)
    named="$APP_DIR/Stoat-${STOAT_REMOTE_VERSION}-anylinux-$(arch_suffix).AppImage"

    log "téléchargement Stoat ${STOAT_REMOTE_VERSION}…"
    if ! curl -fL --connect-timeout 30 --max-time 600 \
        -H 'User-Agent: dotfiles-stoat-updater' \
        -o "$tmp" "$STOAT_REMOTE_URL"; then
        rm -f "$tmp"
        err "téléchargement échoué"
        return 1
    fi

    # ELF / AppImage magic
    if ! file "$tmp" 2>/dev/null | grep -Eqi 'elf|executable'; then
        # AppImage is ELF; still accept if size > 10M
        local sz
        sz=$(wc -c <"$tmp")
        if [ "$sz" -lt 10000000 ]; then
            rm -f "$tmp"
            err "fichier trop petit / invalide"
            return 1
        fi
    fi

    chmod +x "$tmp"
    backup_old
    mv -f "$tmp" "$named"
    ln -sfn "$(basename "$named")" "$APP_PATH"
    # Aussi lien stable sans version dans le nom pour TryExec
    printf '%s\n' "$STOAT_REMOTE_VERSION" >"$VERSION_FILE"

    extract_icon
    write_shim
    write_desktop
    log "OK → $APP_PATH (v$STOAT_REMOTE_VERSION)"
    log "lance: stoat   ou   stoatchat"
}

case "${1:-update}" in
    help|-h|--help)
        cat <<EOF
update-stoat-appimage.sh — Stoat Desktop (AppImage GitHub)

  update | install     télécharge la dernière release
  --force              force le re-téléchargement
  check | status       locale vs GitHub
  version | local      version installée
  remote | latest      version GitHub
  run                  lance l’AppImage

Variables: STOAT_APP_DIR STOAT_APP_PATH STOAT_GITHUB_REPO BACKUP_KEEP
EOF
        ;;
    check|status)
        fetch_release || { err "API GitHub KO"; exit 1; }
        printf 'local=%s\nremote=%s\npath=%s\nurl=%s\n' \
            "$(local_version)" "$STOAT_REMOTE_VERSION" \
            "$([ -f "$APP_PATH" ] && echo "$APP_PATH" || echo absent)" \
            "$STOAT_REMOTE_URL"
        ;;
    version|local) local_version; echo ;;
    remote|latest)
        fetch_release && printf '%s\n' "$STOAT_REMOTE_VERSION"
        ;;
    run|launch)
        [ -x "$APP_PATH" ] || [ -f "$APP_PATH" ] || { err "non installé — update d’abord"; exit 1; }
        exec "$APP_PATH" "$@"
        ;;
    update|install|run-update|--force)
        if [ "${1:-}" = "--force" ]; then install_or_update --force
        else install_or_update
        fi
        ;;
    *)
        err "commande inconnue: $1 (help)"
        exit 1
        ;;
esac
