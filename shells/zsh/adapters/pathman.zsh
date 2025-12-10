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
    
    # Exporter les fonctions pour utilisation globale (utilisées par env.sh)
    # Note: En ZSH, les fonctions sont automatiquement disponibles après source
    # Mais on s'assure que add_to_path et clean_path sont bien exportées
    typeset -f add_to_path >/dev/null || {
        add_to_path() {
            pathman_add_to_path "$@"
        }
    }
    typeset -f clean_path >/dev/null || {
        clean_path() {
            pathman_clean_path
        }
    }
    
    # Alias spécifiques ZSH
    alias pm='pathman'
    alias path-manager='pathman'
else
    echo "❌ Erreur: pathman core non trouvé: $CORE_MANAGER"
    return 1
fi

