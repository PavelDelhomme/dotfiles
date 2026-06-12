#!/bin/bash
# =============================================================================
# PATHMAN ADAPTER - Wrapper Bash pour pathman
# =============================================================================
# Description: Adapter Bash pour charger pathman depuis core/
# Author: Auto-generated
# Version: 1.0
# =============================================================================

# Charger le code commun depuis core/
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
_pathman_core="$DOTFILES_DIR/core/managers/pathman/core/pathman.sh"

if [ -f "$_pathman_core" ]; then
    # Source le code commun
    source "$_pathman_core"
    
    # Les fonctions add_to_path et clean_path sont définies dans le code commun
    # et sont automatiquement disponibles après le source
    # Note: export -f ne fonctionne qu'en Bash, mais les fonctions sont déjà globales
    
    # Alias spécifiques Bash
    alias pm='pathman'
    alias path-manager='pathman'
else
    echo "❌ Erreur: pathman core non trouvé: $_pathman_core"
    unset _pathman_core
    return 1
fi

unset _pathman_core
