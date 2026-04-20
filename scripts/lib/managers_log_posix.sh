#!/bin/sh
# =============================================================================
# MANAGERS_LOG POSIX — une ligne dans managers.log sans bash
# =============================================================================
# Même format que log_manager_action() dans managers_log.sh (bash).
# USAGE (après . ce fichier) : managers_log_line manager action target outcome [details]
# =============================================================================

managers_log_line() {
    manager="$1"
    action="$2"
    target="$3"
    outcome="$4"
    details="${5:-}"
    df="${DOTFILES_DIR:-${HOME:-/}/dotfiles}"
    lf="${MANAGERS_LOG_FILE:-$df/logs/managers.log}"
    dird=$(dirname "$lf")
    mkdir -p "$dird" 2>/dev/null || return 0
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    if [ -n "$details" ]; then
        printf '[%s] [%s] [%s] [%s] target=%s | %s\n' "$ts" "$manager" "$action" "$outcome" "$target" "$details" >>"$lf" 2>/dev/null || true
    else
        printf '[%s] [%s] [%s] [%s] target=%s\n' "$ts" "$manager" "$action" "$outcome" "$target" >>"$lf" 2>/dev/null || true
    fi
}

# Log une invocation CLI : managers_cli_log <nom_manager> "$@"
# (sourcie managers_log_posix si besoin ; target = $1 ou "menu")
managers_cli_log() {
    mgr="$1"
    shift
    df="${DOTFILES_DIR:-${HOME:-/}/dotfiles}"
    lf="$df/scripts/lib/managers_log_posix.sh"
    [ -f "$lf" ] || return 0
    # shellcheck disable=SC1090
    . "$lf" 2>/dev/null || return 0
    tgt="${1:-menu}"
    managers_log_line "$mgr" "cli" "$tgt" "info" "$*"
}
