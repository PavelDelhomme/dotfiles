#!/bin/bash
################################################################################
# Configuration Bash - Wrapper unifié
# Source la configuration partagée compatible avec tous les shells
################################################################################

# Charger la configuration unifiée
if [ -f "$HOME/dotfiles/shared/config.sh" ]; then
    . "$HOME/dotfiles/shared/config.sh"
fi

# Configuration spécifique Bash (si nécessaire)
if [ -f "$HOME/dotfiles/bash/bashrc_custom" ]; then
    . "$HOME/dotfiles/bash/bashrc_custom"
fi

