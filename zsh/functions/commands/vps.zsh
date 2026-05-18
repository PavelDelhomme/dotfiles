#!/bin/zsh
# Connexion rapide au VPS (Host pavel-server dans ~/.ssh/config)
# Chargé via load_commands.sh — indépendant de aliases.zsh

vps() {
    ssh pavel-server "$@"
}

cnx_srv() {
    vps "$@"
}

alias vpsssh='vps'
