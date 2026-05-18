#!/bin/bash
# Module installman — sshpass + client OpenSSH
INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
PACKAGES_SSH="$DOTFILES_DIR/scripts/install/system/packages_ssh.sh"

install_sshpass() {
    log_step "Installation sshpass + client OpenSSH…"
    if command -v sshpass >/dev/null 2>&1 && command -v ssh >/dev/null 2>&1; then
        log_success "sshpass et ssh déjà installés"
        return 0
    fi
    if [ -f "$PACKAGES_SSH" ]; then
        bash "$PACKAGES_SSH" || return 1
        log_success "✓ sshpass / openssh installés"
        return 0
    fi
    log_error "Script introuvable : $PACKAGES_SSH"
    return 1
}
