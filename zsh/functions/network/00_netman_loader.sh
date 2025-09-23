#!/bin/zsh
# Chargeur automatique pour NETMAN
# Ce fichier charge NETMAN au démarrage de ZSH

# Charger NETMAN
if [ -f "$HOME/dotfiles/zsh/functions/network/netman.zsh" ]; then
    source "$HOME/dotfiles/zsh/functions/network/netman.zsh"
fi

# Exporter la fonction pour qu'elle soit disponible globalement
export -f netman 2>/dev/null || true
