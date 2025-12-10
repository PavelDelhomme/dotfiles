#!/bin/bash
# =============================================================================
# PATHMAN ADAPTER - Wrapper Bash pour pathman
# =============================================================================
# Description: Adapter Bash pour charger pathman depuis core/
# Author: Auto-generated
# Version: 1.0
# =============================================================================

# Charger le code commun depuis core/
CORE_MANAGER="$HOME/dotfiles/core/managers/pathman/core/pathman.sh"

if [ -f "$CORE_MANAGER" ]; then
    # Source le code commun
    source "$CORE_MANAGER"
    
    # Exporter les fonctions pour utilisation globale (utilisées par env.sh)
    export -f add_to_path clean_path 2>/dev/null || {
        # Si export -f ne fonctionne pas, créer des wrappers
        add_to_path() {
            pathman_add_to_path "$@"
        }
        clean_path() {
            pathman_clean_path
        }
    }
    
    # Alias spécifiques Bash
    alias pm='pathman'
    alias path-manager='pathman'
else
    echo "❌ Erreur: pathman core non trouvé: $CORE_MANAGER"
    return 1
fi

