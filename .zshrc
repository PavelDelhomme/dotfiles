#!/bin/zsh
################################################################################
# Configuration Zsh - Wrapper unifié
# Source la configuration partagée compatible avec tous les shells
################################################################################

# Charger la configuration unifiée
if [ -f "$HOME/dotfiles/shared/config.sh" ]; then
    . "$HOME/dotfiles/shared/config.sh"
fi

# Configuration spécifique Zsh (si nécessaire)
if [ -f "$HOME/dotfiles/zsh/zshrc_custom" ]; then
    . "$HOME/dotfiles/zsh/zshrc_custom"
fi

