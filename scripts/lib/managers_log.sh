#!/usr/bin/env bash
# =============================================================================
# MANAGERS LOG - Journal commun pour tous les *man (installman, configman, etc.)
# =============================================================================
# Chaque action est enregistrée avec manager, action, cible, statut, détail.
# Fichier: dotfiles/logs/managers.log
# =============================================================================

MANAGERS_LOG_DIR="${DOTFILES_DIR:-$HOME/dotfiles}/logs"
MANAGERS_LOG_FILE="${MANAGERS_LOG_FILE:-$MANAGERS_LOG_DIR/managers.log}"

_managers_log_ensure_dir() {
    [ -n "$MANAGERS_LOG_DIR" ] && mkdir -p "$MANAGERS_LOG_DIR" 2>/dev/null
}

# Log une action pour un manager quelconque
# Usage: log_manager_action "installman" "install" "cursor" "success" ""
#        log_manager_action "configman" "configure" "git" "failed" "permission denied"
# Note: on évite le nom "status" (variable en lecture seule en zsh)
log_manager_action() {
    local manager="$1"
    local action="$2"
    local target="$3"
    local outcome="$4"
    local details="$5"
    _managers_log_ensure_dir
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    local line="[$ts] [$manager] [$action] [$outcome] target=$target"
    [ -n "$details" ] && line="$line | $details"
    echo "$line" >> "$MANAGERS_LOG_FILE" 2>/dev/null
}

# Afficher les derniers logs (tous managers ou filtré)
show_managers_logs() {
    local lines="${1:-50}"
    local filter="$2"
    _managers_log_ensure_dir
    if [ ! -f "$MANAGERS_LOG_FILE" ]; then
        echo "Aucun log managers."
        return 1
    fi
    if [ -n "$filter" ]; then
        grep "$filter" "$MANAGERS_LOG_FILE" | tail -n "$lines"
    else
        tail -n "$lines" "$MANAGERS_LOG_FILE"
    fi
}
