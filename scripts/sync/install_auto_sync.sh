#!/bin/bash
################################################################################
# Active la sync auto du dépôt : timer systemd user + hook login
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/common.sh" || exit 1

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
case "$DOTFILES_DIR" in
    */scripts) DOTFILES_DIR="${DOTFILES_DIR%/scripts}" ;;
esac

SYSTEMD_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
SRC_SERVICE="$DOTFILES_DIR/systemd/user/dotfiles-sync.service"
SRC_TIMER="$DOTFILES_DIR/systemd/user/dotfiles-sync.timer"
SYNC_SCRIPT="$DOTFILES_DIR/scripts/sync/dotfiles_update.sh"
MODE="${DOTFILES_SYNC_MODE:-pull}"

log_section "Activation sync auto dotfiles (mode=$MODE)"

chmod +x "$SYNC_SCRIPT" "$DOTFILES_DIR/scripts/sync/git_auto_sync.sh" 2>/dev/null || true

mkdir -p "$SYSTEMD_USER_DIR"

if [ -f "$SRC_SERVICE" ] && [ -f "$SRC_TIMER" ]; then
    # Adapter %h si DOTFILES_DIR ≠ ~/dotfiles
    if [ "$DOTFILES_DIR" = "$HOME/dotfiles" ]; then
        install -m 0644 "$SRC_SERVICE" "$SYSTEMD_USER_DIR/dotfiles-sync.service"
        install -m 0644 "$SRC_TIMER" "$SYSTEMD_USER_DIR/dotfiles-sync.timer"
    else
        sed "s|%h/dotfiles|$DOTFILES_DIR|g" "$SRC_SERVICE" >"$SYSTEMD_USER_DIR/dotfiles-sync.service"
        cp "$SRC_TIMER" "$SYSTEMD_USER_DIR/dotfiles-sync.timer"
    fi
    # Injecter le mode souhaité
    if grep -q 'DOTFILES_SYNC_MODE=' "$SYSTEMD_USER_DIR/dotfiles-sync.service"; then
        sed -i "s|Environment=DOTFILES_SYNC_MODE=.*|Environment=DOTFILES_SYNC_MODE=$MODE|" \
            "$SYSTEMD_USER_DIR/dotfiles-sync.service" 2>/dev/null \
            || sed -i '' "s|Environment=DOTFILES_SYNC_MODE=.*|Environment=DOTFILES_SYNC_MODE=$MODE|" \
            "$SYSTEMD_USER_DIR/dotfiles-sync.service" 2>/dev/null || true
    fi
else
    log_warn "Unités repo absentes — génération minimale"
    cat >"$SYSTEMD_USER_DIR/dotfiles-sync.service" <<EOF
[Unit]
Description=Sync dotfiles
After=network-online.target
[Service]
Type=oneshot
Environment=DOTFILES_DIR=$DOTFILES_DIR
Environment=DOTFILES_SYNC_MODE=$MODE
Environment=DOTFILES_UPDATE_QUIET=1
ExecStart=$SYNC_SCRIPT
[Install]
WantedBy=default.target
EOF
    cat >"$SYSTEMD_USER_DIR/dotfiles-sync.timer" <<EOF
[Unit]
Description=Timer sync dotfiles
[Timer]
OnBootSec=2min
OnUnitActiveSec=1h
Persistent=true
[Install]
WantedBy=timers.target
EOF
fi

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user daemon-reload
    systemctl --user enable --now dotfiles-sync.timer
    log_info "✓ timer dotfiles-sync activé"
    systemctl --user status dotfiles-sync.timer --no-pager -l 2>/dev/null | head -12 || true
else
    log_warn "systemctl absent — seul le hook login (shared/dotfiles_autoupdate.sh) s'appliquera"
fi

# Premier pull immédiat
bash "$SYNC_SCRIPT" pull || true

echo ""
log_info "Hook login : sourcé via zsh/fish/bash (shared/dotfiles_autoupdate.sh)"
log_info "Commandes :"
echo "  dotfiles update          # pull maintenant"
echo "  dotfiles update full     # pull + commit/push locaux"
echo "  dotfiles update status"
echo "  dotfiles update enable|disable"
echo "  DOTFILES_SYNC_MODE=full make auto-sync   # push auto aussi"
echo ""
log_info "Logs: $DOTFILES_DIR/logs/auto_sync.log"
