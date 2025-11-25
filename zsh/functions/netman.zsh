#!/bin/zsh
# =============================================================================
# NETMAN WRAPPER - Wrapper de compatibilité pour netman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

# Charger le script principal depuis la nouvelle structure
NETMAN_CORE="$HOME/dotfiles/zsh/functions/netman/core/netman.zsh"

if [ -f "$NETMAN_CORE" ]; then
    source "$NETMAN_CORE"
else
    echo "❌ Erreur: netman core non trouvé: $NETMAN_CORE"
    return 1
fi
