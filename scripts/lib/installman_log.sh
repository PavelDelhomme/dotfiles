#!/usr/bin/env bash
# =============================================================================
# INSTALLMAN LOG - Journalisation de toutes les actions installman
# =============================================================================
# Chaque action (install, update, check-urls, etc.) est enregistrée avec
# timestamp, résultat et erreur éventuelle pour reprise / diagnostic.
# Utilisable par tout shell (sourcé depuis installman).
# =============================================================================

INSTALLMAN_LOG_DIR="${DOTFILES_DIR:-$HOME/dotfiles}/logs"
INSTALLMAN_LOG_FILE="${INSTALLMAN_LOG_FILE:-$INSTALLMAN_LOG_DIR/installman.log}"

# Crée le répertoire de logs si besoin
_installman_log_ensure_dir() {
    [ -n "$INSTALLMAN_LOG_DIR" ] && mkdir -p "$INSTALLMAN_LOG_DIR" 2>/dev/null
}

# Log une action installman
# Usage: log_installman_action "install" "cursor" "success" ""
#        log_installman_action "check-urls" "" "failed" "HTTP empty"
log_installman_action() {
    local action="$1"   # install | update | update-all | check-urls | package-search | ...
    local target="$2"   # nom outil ou ""
    local status="$3"   # success | failed | skipped | error
    local details="$4"  # message d'erreur ou détail
    _installman_log_ensure_dir
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    local line="[$ts] [installman] [$action] [$status] target=$target"
    [ -n "$details" ] && line="$line | $details"
    echo "$line" >> "$INSTALLMAN_LOG_FILE" 2>/dev/null
}

# Afficher les derniers logs installman (sans ouvrir less si appelé depuis script)
show_installman_logs() {
    local lines="${1:-50}"
    _installman_log_ensure_dir
    if [ ! -f "$INSTALLMAN_LOG_FILE" ]; then
        echo "Aucun log installman."
        return 1
    fi
    tail -n "$lines" "$INSTALLMAN_LOG_FILE"
}

# Résumé: succès / échecs
installman_log_summary() {
    _installman_log_ensure_dir
    if [ ! -f "$INSTALLMAN_LOG_FILE" ]; then
        echo "Aucun log installman."
        return 1
    fi
    echo "--- Résumé installman ---"
    grep -c "\[success\]" "$INSTALLMAN_LOG_FILE" 2>/dev/null && echo "  succès" || true
    grep -c "\[failed\]" "$INSTALLMAN_LOG_FILE" 2>/dev/null && echo "  échecs" || true
    echo "Fichier: $INSTALLMAN_LOG_FILE"
}
