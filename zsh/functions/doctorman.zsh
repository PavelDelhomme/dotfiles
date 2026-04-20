#!/usr/bin/env zsh
# =============================================================================
# DOCTORMAN — wrapper (manman / compat)
# =============================================================================
# ${HOME:-/} : OK avec setopt nounset même si HOME est absent (ex. zsh -n).
: "${DOTFILES_DIR:=${HOME:-/}/dotfiles}"
export DOTFILES_DIR
source "$DOTFILES_DIR/shells/zsh/adapters/doctorman.zsh"
