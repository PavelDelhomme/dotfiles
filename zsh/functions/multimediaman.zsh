#!/bin/zsh
# =============================================================================
# MULTIMEDIAMAN WRAPPER - Wrapper de compatibilité pour multimediaman
# =============================================================================
# Description: Wrapper pour maintenir la compatibilité avec l'ancien chemin
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger le script principal depuis la nouvelle structure
MULTIMEDIAMAN_CORE="$HOME/dotfiles/zsh/functions/multimediaman/core/multimediaman.zsh"

if [ -f "$MULTIMEDIAMAN_CORE" ]; then
    source "$MULTIMEDIAMAN_CORE"
else
    echo "❌ Erreur: multimediaman core non trouvé: $MULTIMEDIAMAN_CORE"
    return 1
fi

