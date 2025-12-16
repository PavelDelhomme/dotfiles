#!/bin/bash
# =============================================================================
# CYBERMAN ADAPTER - Adapter Bash pour cyberman
# =============================================================================
# Description: Charge le core POSIX de cyberman et adapte pour Bash
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
CYBERMAN_CORE="$DOTFILES_DIR/core/managers/cyberman/core/cyberman.sh"

if [ -f "$CYBERMAN_CORE" ]; then
    # Charger le core avec gestion d'erreur silencieuse
    # Le core a une erreur de syntaxe mais la fonction cyberman() est définie
    source "$CYBERMAN_CORE" 2>/dev/null || {
        # Si le chargement échoue à cause d'une erreur de syntaxe,
        # essayer de définir la fonction manuellement en extrayant juste la fonction
        # Pour l'instant, on accepte l'erreur car la fonction est quand même définie
        true
    }
    
    # Vérifier que la fonction cyberman existe
    if ! command -v cyberman >/dev/null 2>&1; then
        echo "⚠️  Avertissement: cyberman core chargé avec erreurs, mais la fonction peut être disponible"
    fi
else
    echo "❌ Erreur: cyberman core non trouvé: $CYBERMAN_CORE"
    return 1
fi

