#!/usr/bin/env bash
################################################################################
# Mise à jour du dépôt dotfiles (multi-machine / multi-shell)
#
# Modes (DOTFILES_SYNC_MODE) :
#   pull  — fetch + fast-forward / rebase (défaut, sûr) — pour recevoir Arch→Gentoo…
#   full  — pull puis auto-commit + push des changements locaux
#
# Usage:
#   bash scripts/sync/dotfiles_update.sh [pull|full|status]
#   DOTFILES_SYNC_MODE=full bash scripts/sync/dotfiles_update.sh
#   DOTFILES_UPDATE_QUIET=1 …   # peu de sortie (hook login)
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/common.sh" 2>/dev/null || {
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
    log_info() { echo -e "${GREEN}[✓]${NC} $*"; }
    log_warn() { echo -e "${YELLOW}[!]${NC} $*"; }
    log_error() { echo -e "${RED}[✗]${NC} $*" >&2; }
}

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
case "$DOTFILES_DIR" in
    */scripts) DOTFILES_DIR="${DOTFILES_DIR%/scripts}" ;;
esac

MODE="${1:-${DOTFILES_SYNC_MODE:-pull}}"
case "$MODE" in
    pull|full|status|help|-h|--help) ;;
    *) MODE="${DOTFILES_SYNC_MODE:-pull}" ;;
esac

QUIET="${DOTFILES_UPDATE_QUIET:-0}"
LOG_DIR="$DOTFILES_DIR/logs"
LOG_FILE="$LOG_DIR/auto_sync.log"
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/dotfiles_update.lock"
STAMP_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
STAMP_FILE="$STAMP_DIR/last_update"
REMOTE="${DOTFILES_SYNC_REMOTE:-origin}"

_q() {
    if [ "$QUIET" = "1" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >>"$LOG_FILE" 2>/dev/null
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE" 2>/dev/null
    fi
}

_info() { [ "$QUIET" = "1" ] && _q "$*" || log_info "$*"; }
_warn() { [ "$QUIET" = "1" ] && _q "WARN $*" || log_warn "$*"; }
_err()  { [ "$QUIET" = "1" ] && _q "ERR $*" || log_error "$*"; }

mkdir -p "$LOG_DIR" "$STAMP_DIR" 2>/dev/null || true

if [ "$MODE" = "help" ] || [ "$MODE" = "-h" ] || [ "$MODE" = "--help" ]; then
    cat <<'EOF'
dotfiles_update.sh — sync du dépôt

  pull     fetch + mise à jour locale depuis origin (défaut)
  full     pull + commit auto des changements locaux + push
  status   branche, ahead/behind, dirty, timer

Variables:
  DOTFILES_DIR  DOTFILES_SYNC_MODE=pull|full  DOTFILES_UPDATE_QUIET=1
  DOTFILES_SYNC_REMOTE=origin
EOF
    exit 0
fi

if [ ! -d "$DOTFILES_DIR/.git" ]; then
    _err "Pas un dépôt git: $DOTFILES_DIR"
    exit 1
fi

cd "$DOTFILES_DIR" || exit 1

BRANCH=$(git branch --show-current 2>/dev/null || echo main)

_status() {
    echo "DOTFILES_DIR=$DOTFILES_DIR"
    echo "branch=$BRANCH  remote=$REMOTE  mode=${DOTFILES_SYNC_MODE:-pull}"
    git status -sb 2>/dev/null | head -8
    if git rev-parse "$REMOTE/$BRANCH" >/dev/null 2>&1; then
        ahead=$(git rev-list --count "$REMOTE/$BRANCH"..HEAD 2>/dev/null || echo 0)
        behind=$(git rev-list --count HEAD.."$REMOTE/$BRANCH" 2>/dev/null || echo 0)
        echo "ahead=$ahead  behind=$behind"
    fi
    if systemctl --user is-enabled dotfiles-sync.timer >/dev/null 2>&1; then
        echo "timer=enabled  $(systemctl --user is-active dotfiles-sync.timer 2>/dev/null)"
        systemctl --user list-timers dotfiles-sync.timer --no-pager 2>/dev/null | head -3
    else
        echo "timer=disabled (dotfiles update enable)"
    fi
    [ -f "$STAMP_FILE" ] && echo "last_update=$(cat "$STAMP_FILE")"
}

if [ "$MODE" = "status" ]; then
    _status
    exit 0
fi

if ! git remote get-url "$REMOTE" >/dev/null 2>&1; then
    _warn "Remote $REMOTE absent — sync annulée"
    exit 0
fi

if [ -f "$LOCK_FILE" ]; then
    old=$(cat "$LOCK_FILE" 2>/dev/null || true)
    if [ -n "$old" ] && kill -0 "$old" 2>/dev/null; then
        _warn "Update déjà en cours (PID $old)"
        exit 0
    fi
    rm -f "$LOCK_FILE"
fi
echo $$ >"$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

_q "═══ update mode=$MODE branch=$BRANCH ═══"

# --- PULL ---
if ! git fetch "$REMOTE" "$BRANCH" >/dev/null 2>&1; then
    _warn "fetch impossible (réseau?)"
else
    LOCAL=$(git rev-parse HEAD)
    REMOTE_REF=$(git rev-parse "$REMOTE/$BRANCH" 2>/dev/null || echo "")
    if [ -n "$REMOTE_REF" ] && [ "$LOCAL" != "$REMOTE_REF" ]; then
        dirty=$(git status --porcelain 2>/dev/null)
        if [ -n "$dirty" ]; then
            # stash local changes to allow pull, then pop
            _warn "Modifs locales présentes — stash avant pull"
            git stash push -u -m "dotfiles-update-autostash $(date +%s)" >/dev/null 2>&1 || true
            STASHED=1
        else
            STASHED=0
        fi
        if git pull --ff-only "$REMOTE" "$BRANCH" >>"$LOG_FILE" 2>&1 \
            || git pull --rebase "$REMOTE" "$BRANCH" >>"$LOG_FILE" 2>&1; then
            _info "✓ à jour depuis $REMOTE/$BRANCH"
        else
            _warn "pull en conflit — abandon rebase, priorité remote"
            git rebase --abort >/dev/null 2>&1 || true
            if [ "${DOTFILES_SYNC_FORCE_REMOTE:-0}" = "1" ]; then
                git reset --hard "$REMOTE/$BRANCH" >>"$LOG_FILE" 2>&1 && _warn "reset --hard remote (FORCE)"
            else
                _err "Échec pull. Relance avec DOTFILES_SYNC_FORCE_REMOTE=1 pour écraser le local."
            fi
        fi
        if [ "${STASHED:-0}" = "1" ]; then
            git stash pop >/dev/null 2>&1 || _warn "stash pop partiel — voir git stash list"
        fi
    else
        _info "✓ déjà synchronisé avec $REMOTE/$BRANCH"
    fi
fi

# --- FULL : commit + push ---
if [ "$MODE" = "full" ]; then
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        # Ne jamais committer .env / secrets
        git add -A
        git reset HEAD -- .env .env.local '*.pem' '*.key' 2>/dev/null || true
        if [ -n "$(git diff --cached --name-only 2>/dev/null)" ]; then
            msg="Auto-sync: $(date '+%Y-%m-%d %H:%M:%S') ($(hostname -s 2>/dev/null || echo host))"
            if git commit -m "$msg" >>"$LOG_FILE" 2>&1; then
                _info "✓ commit: $msg"
            fi
        fi
    fi
    LOCAL=$(git rev-parse HEAD)
    REMOTE_REF=$(git rev-parse "$REMOTE/$BRANCH" 2>/dev/null || echo "")
    if [ -n "$REMOTE_REF" ] && [ "$LOCAL" != "$REMOTE_REF" ]; then
        ahead=$(git rev-list --count "$REMOTE/$BRANCH"..HEAD 2>/dev/null || echo 0)
        if [ "$ahead" -gt 0 ]; then
            if git push "$REMOTE" "$BRANCH" >>"$LOG_FILE" 2>&1; then
                _info "✓ push $REMOTE/$BRANCH"
            else
                _warn "push échoué — pull --rebase puis retry"
                git pull --rebase "$REMOTE" "$BRANCH" >>"$LOG_FILE" 2>&1
                git push "$REMOTE" "$BRANCH" >>"$LOG_FILE" 2>&1 && _info "✓ push après rebase" || _err "push toujours KO"
            fi
        fi
    fi
fi

date -Iseconds >"$STAMP_FILE" 2>/dev/null || date >"$STAMP_FILE"
_q "═══ fin update ═══"
exit 0
