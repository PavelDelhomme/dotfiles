#!/bin/zsh
# =============================================================================
# PATHMAN ADAPTER - Wrapper ZSH pour pathman
# =============================================================================
# Description: Adapter ZSH pour charger pathman depuis core/
# Author: Auto-generated
# Version: 1.0
# =============================================================================

# Charger le code commun depuis core/
CORE_MANAGER="$HOME/dotfiles/core/managers/pathman/core/pathman.sh"

if [ -f "$CORE_MANAGER" ]; then
    # Source le code commun
    source "$CORE_MANAGER"
    
    # Les fonctions add_to_path et clean_path sont définies dans le code commun
    # et sont automatiquement disponibles après le source
    
    # Alias spécifiques ZSH
    alias pm='pathman'
    alias path-manager='pathman'
else
    echo "❌ Erreur: pathman core non trouvé: $CORE_MANAGER"
    return 1
fi

