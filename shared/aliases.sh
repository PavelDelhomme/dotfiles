#!/bin/sh
################################################################################
# Alias communs pour tous les shells (sh/bash/zsh compatible)
# Compatible avec sh, bash, zsh, fish (via wrapper)
################################################################################

# Alias Git (compatibles tous shells)
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gcl='git clone'
alias gst='git stash'
alias gpo='git push origin'
alias gca='git commit -a -m'

# Alias système (compatibles)
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Alias Docker (si disponible)
if command -v docker >/dev/null 2>&1; then
    alias d='docker'
    alias dc='docker-compose'
    alias dps='docker ps'
    alias dimg='docker images'
fi

# Alias Make (si disponible)
if command -v make >/dev/null 2>&1; then
    alias m='make'
    alias mi='make install'
    alias mv='make validate'
    alias ms='make setup'
fi

