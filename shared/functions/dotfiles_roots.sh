#!/bin/sh
# =============================================================================
# dotfiles_roots — chemins stables (POSIX : sh / bash / zsh)
# =============================================================================
# Sourcer depuis un script ou un adapter après avoir fixé DOTFILES_DIR si besoin.
# Fish : ne pas sourcer ce fichier ; utiliser shells/fish/adapters/*.fish qui
# posent DOTFILES_DIR puis lancent bash/sh si nécessaire.
# =============================================================================

if [ -z "${DOTFILES_DIR:-}" ]; then
    if [ -n "${HOME:-}" ] && [ -d "${HOME}/dotfiles" ]; then
        DOTFILES_DIR="${HOME}/dotfiles"
    elif [ -n "${HOME:-}" ] && [ -d "${HOME}/.dotfiles" ]; then
        DOTFILES_DIR="${HOME}/.dotfiles"
    else
        DOTFILES_DIR="${HOME:-/tmp}/dotfiles"
    fi
fi
export DOTFILES_DIR

# Chemins dérivés (réutilisables dans les cores POSIX et les tests)
export DOTFILES_CORE_MANAGERS="${DOTFILES_DIR}/core/managers"
export DOTFILES_SHELLS_DIR="${DOTFILES_DIR}/shells"
export DOTFILES_SHARED_DIR="${DOTFILES_DIR}/shared"
export DOTFILES_SCRIPTS_DIR="${DOTFILES_DIR}/scripts"
export DOTFILES_SHARE_DIR="${DOTFILES_DIR}/share"

# Nom du shell courant (informationnel ; pas fish ici)
if [ -n "${ZSH_VERSION:-}" ]; then
    DOTFILES_SHELL=zsh
elif [ -n "${BASH_VERSION:-}" ]; then
    DOTFILES_SHELL=bash
else
    DOTFILES_SHELL=sh
fi
export DOTFILES_SHELL
