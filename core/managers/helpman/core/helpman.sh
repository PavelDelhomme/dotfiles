#!/bin/sh
# =============================================================================
# HELPMAN - Help Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet du système d'aide et documentation
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

# DESC: Guide interactif pour comprendre le système d'aide
# USAGE: helpman
# NOTE: Pour l'instant, ce wrapper charge le fichier ZSH original
# TODO: Migrer complètement vers POSIX
helpman() {
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    HELPMAN_ORIGINAL="$DOTFILES_DIR/zsh/functions/helpman/core/helpman.zsh"
    
    if [ -f "$HELPMAN_ORIGINAL" ]; then
        # Charger le fichier ZSH original (temporaire)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Source le fichier (définit la fonction helpman)
            . "$HELPMAN_ORIGINAL"
            # La fonction est maintenant définie et sera appelée automatiquement
        else
            echo "⚠️  helpman nécessite ZSH pour l'instant"
            echo "💡 Migration complète vers POSIX en cours..."
            return 1
        fi
    else
        echo "❌ Erreur: helpman non trouvé: $HELPMAN_ORIGINAL"
        return 1
    fi
}

