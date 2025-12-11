#!/bin/sh
# =============================================================================
# MISCMAN - Miscellaneous Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des outils divers
# Author: Paul Delhomme
# Version: 2.0 - Structure Hybride (Wrapper temporaire)
# =============================================================================

# Détecter le shell pour adapter certaines syntaxes
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_TYPE="fish"
else
    SHELL_TYPE="sh"
fi

# DESC: Gestionnaire interactif complet pour les outils divers
# USAGE: miscman [module]
# NOTE: Pour l'instant, ce wrapper charge le fichier ZSH original
# TODO: Migrer complètement vers POSIX
miscman() {
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    MISCMAN_ORIGINAL="$DOTFILES_DIR/zsh/functions/miscman/core/miscman.zsh"
    
    if [ -f "$MISCMAN_ORIGINAL" ]; then
        # Charger le fichier ZSH original (temporaire)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Source le fichier (définit la fonction miscman)
            . "$MISCMAN_ORIGINAL"
            # La fonction est maintenant définie et sera appelée automatiquement
        else
            echo "⚠️  miscman nécessite ZSH pour l'instant"
            echo "💡 Migration complète vers POSIX en cours..."
            return 1
        fi
    else
        echo "❌ Erreur: miscman non trouvé: $MISCMAN_ORIGINAL"
        return 1
    fi
}

