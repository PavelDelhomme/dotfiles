#!/bin/zsh
# =============================================================================
# INSTALLATION / SYNC DOTFILES — clone ou mise à jour sur n'importe quelle machine
# =============================================================================
# Variables :
#   DOTFILES_DIR              cible (défaut: ~/dotfiles)
#   DOTFILES_GIT_URL          URL clone (défaut: https://github.com/PavelDelhomme/dotfiles.git)
#   DOTFILES_SYNC_TRACK       canal (défaut: main = dernière version « prod »)
#   DOTFILES_SYNC_MODE        pull|full (défaut: pull)
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DOTFILES_GIT_URL="${DOTFILES_GIT_URL:-https://github.com/PavelDelhomme/dotfiles.git}"
TRACK="${DOTFILES_SYNC_TRACK:-main}"
SYNC_SCRIPT="${DOTFILES_DIR}/scripts/sync/dotfiles_update.sh"
INSTALL_SYNC="${DOTFILES_DIR}/scripts/sync/install_auto_sync.sh"

# DESC: Clone si besoin, puis sync le canal (main) + active le timer
# USAGE: install_dotfiles
install_dotfiles() {
    log_step "Dotfiles — installation / sync (canal=$TRACK)…"

    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        if [ -e "$DOTFILES_DIR" ] && [ ! -d "$DOTFILES_DIR" ]; then
            log_error "Chemin existant non-répertoire: $DOTFILES_DIR"
            return 1
        fi
        if [ -d "$DOTFILES_DIR" ] && [ "$(ls -A "$DOTFILES_DIR" 2>/dev/null)" ]; then
            log_error "Répertoire non vide sans .git: $DOTFILES_DIR"
            log_info "Vide-le, ou définis DOTFILES_DIR ailleurs, puis relance."
            return 1
        fi
        log_info "Clone $DOTFILES_GIT_URL → $DOTFILES_DIR (branche $TRACK)…"
        mkdir -p "$(dirname "$DOTFILES_DIR")"
        if ! git clone --branch "$TRACK" --single-branch "$DOTFILES_GIT_URL" "$DOTFILES_DIR" 2>/dev/null; then
            # Fallback SSH si HTTPS échoue (ou branche manquante)
            local ssh_url="git@github.com:PavelDelhomme/dotfiles.git"
            case "$DOTFILES_GIT_URL" in
                git@*|ssh://*) ssh_url="$DOTFILES_GIT_URL" ;;
                https://github.com/*)
                    ssh_url="git@github.com:${DOTFILES_GIT_URL#https://github.com/}"
                    ssh_url="${ssh_url%.git}.git"
                    ;;
            esac
            log_warn "Clone HTTPS échoué — essai SSH ($ssh_url)…"
            git clone --branch "$TRACK" --single-branch "$ssh_url" "$DOTFILES_DIR" \
                || git clone "$DOTFILES_GIT_URL" "$DOTFILES_DIR" \
                || {
                    log_error "Clone impossible"
                    return 1
                }
        fi
        # Rebind paths after clone
        SYNC_SCRIPT="${DOTFILES_DIR}/scripts/sync/dotfiles_update.sh"
        INSTALL_SYNC="${DOTFILES_DIR}/scripts/sync/install_auto_sync.sh"
    fi

    # Persister le canal (main = dernière version sur toutes les machines)
    if [ -x "$SYNC_SCRIPT" ] || [ -f "$SYNC_SCRIPT" ]; then
        chmod +x "$SYNC_SCRIPT" 2>/dev/null || true
        bash "$SYNC_SCRIPT" track "$TRACK" || true
        bash "$SYNC_SCRIPT" pull || {
            log_error "Sync pull échoué"
            return 1
        }
    else
        log_warn "Script sync absent — git pull manuel"
        (cd "$DOTFILES_DIR" && git fetch origin && git checkout "$TRACK" && git pull --ff-only origin "$TRACK") || return 1
    fi

    # Timer systemd + hook login
    if [ -f "$INSTALL_SYNC" ]; then
        DOTFILES_DIR="$DOTFILES_DIR" DOTFILES_SYNC_MODE="${DOTFILES_SYNC_MODE:-pull}" \
            bash "$INSTALL_SYNC" || true
    elif command -v updateman &>/dev/null; then
        updateman dotfiles enable 2>/dev/null || true
    fi

    log_info "✓ Dotfiles à jour ($TRACK) dans $DOTFILES_DIR"
    log_info "  màj: updateman dotfiles  |  installman dotfiles  |  dotfiles update"
    return 0
}
