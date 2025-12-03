#!/bin/zsh
# =============================================================================
# SSMAN WRAPPER - Wrapper de compatibilité pour sshman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger le script principal depuis la nouvelle structure
SSHMAN_CORE="$HOME/dotfiles/zsh/functions/sshman/core/sshman.zsh"

if [ -f "$SSHMAN_CORE" ]; then
    source "$SSHMAN_CORE" 2>/dev/null || {
        echo "❌ Erreur: Impossible de charger sshman core"
        return 1
    }
    # Ne pas afficher le message ici, il sera affiché par load_manager dans zshrc_custom
else
    echo "❌ Erreur: sshman core non trouvé: $SSHMAN_CORE"
    return 1
fi

