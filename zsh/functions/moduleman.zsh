#!/bin/zsh
# =============================================================================
# MODULEMAN WRAPPER - Wrapper de compatibilité pour moduleman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger le script principal depuis la nouvelle structure
MODULEMAN_CORE="$HOME/dotfiles/zsh/functions/moduleman/core/moduleman.zsh"

if [ -f "$MODULEMAN_CORE" ]; then
    source "$MODULEMAN_CORE"
else
    echo "❌ Erreur: moduleman core non trouvé: $MODULEMAN_CORE"
    return 1
fi

