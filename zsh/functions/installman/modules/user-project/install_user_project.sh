#!/bin/zsh
# =============================================================================
# Projet Git personnel — module installman
# =============================================================================
# Variables :
#   DOTFILES_USER_PROJECT_GIT_URL  URL du dépôt (obligatoire pour clone)
#   DOTFILES_USER_PROJECT_DIR      Répertoire cible (défaut : ~/src/<nom-du-repo>)
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
[[ -f "$INSTALLMAN_DIR/utils/logger.sh" ]] && source "$INSTALLMAN_DIR/utils/logger.sh"
[[ -f "$INSTALLMAN_DIR/utils/installman_confirm.sh" ]] && source "$INSTALLMAN_DIR/utils/installman_confirm.sh"

install_user_project() {
    log_step "Projet Git personnel…"

    local url="${DOTFILES_USER_PROJECT_GIT_URL:-}"
    if [[ -z "$url" ]]; then
        log_error "Définissez DOTFILES_USER_PROJECT_GIT_URL (ex: export DOTFILES_USER_PROJECT_GIT_URL='https://github.com/moi/mon-projet.git')"
        log_info "Optionnel : DOTFILES_USER_PROJECT_DIR=/chemin/clone"
        return 1
    fi

    local dir="${DOTFILES_USER_PROJECT_DIR:-}"
    if [[ -z "$dir" ]]; then
        local base
        base=$(basename "$url" .git)
        dir="$HOME/src/$base"
    fi

    if [[ -d "$dir/.git" ]]; then
        log_info "Dépôt déjà présent : $dir"
        if installman_confirm "Exécuter git pull dans $dir ?"; then
            (cd "$dir" && git pull --ff-only) || return 1
        fi
        return 0
    fi

    installman_confirm "Cloner $url vers $dir ?" || return 1
    mkdir -p "$(dirname "$dir")"
    git clone "$url" "$dir" || return 1
    log_info "✓ Clone terminé : $dir"
    return 0
}
