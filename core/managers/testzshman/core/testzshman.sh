#!/bin/sh
# =============================================================================
# TESTZSHMAN - Test ZSH Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire de tests ZSH
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

# DESC: Gestionnaire interactif complet pour gérer les tests ZSH
# USAGE: testzshman [command]
# NOTE: Pour l'instant, ce wrapper charge le fichier ZSH original
# TODO: Migrer complètement vers POSIX
testzshman() {
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    TESTZSHMAN_ORIGINAL="$DOTFILES_DIR/zsh/functions/testzshman.zsh"
    
    if [ -f "$TESTZSHMAN_ORIGINAL" ]; then
        # Charger le fichier ZSH original (temporaire)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Source le fichier (définit la fonction testzshman)
            . "$TESTZSHMAN_ORIGINAL"
            # La fonction est maintenant définie et sera appelée automatiquement
        else
            echo "⚠️  testzshman nécessite ZSH pour l'instant"
            echo "💡 Migration complète vers POSIX en cours..."
            return 1
        fi
    else
        echo "❌ Erreur: testzshman non trouvé: $TESTZSHMAN_ORIGINAL"
        return 1
    fi
}

