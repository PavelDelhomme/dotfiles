#!/bin/sh
# Git refuse les dépôts dont le propriétaire ≠ l’utilisateur courant (ex. volume hôte → root dans Docker).
# N’activer qu’avec DOTFILES_DOCKER_TEST=1 pour ne pas toucher au gitconfig de la machine hôte.

dotfiles_docker_git_trust_repo() {
    [ "${DOTFILES_DOCKER_TEST:-0}" = "1" ] || return 0
    command -v git >/dev/null 2>&1 || return 0
    df="${DOTFILES_DIR:-/root/dotfiles}"
    [ -e "$df/.git" ] || return 0
    _gh="${HOME:-/root}"
    export HOME="$_gh"
    mkdir -p "$HOME/.config/git" 2>/dev/null || true
    git config --global --add safe.directory "$df" 2>/dev/null || true
}
