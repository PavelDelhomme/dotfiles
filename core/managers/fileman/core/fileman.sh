#!/bin/sh
# =============================================================================
# FILEMAN - File Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des opérations sur fichiers
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

# DESC: Gestionnaire interactif complet pour les opérations sur fichiers
# USAGE: fileman [category]
# NOTE: Pour l'instant, ce wrapper charge le fichier ZSH original
# TODO: Migrer complètement vers POSIX
fileman() {
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    FILEMAN_ORIGINAL="$DOTFILES_DIR/zsh/functions/fileman/core/fileman.zsh"
    
    if [ -f "$FILEMAN_ORIGINAL" ]; then
        # Charger le fichier ZSH original (temporaire)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Source le fichier (définit la fonction fileman)
            . "$FILEMAN_ORIGINAL"
            # La fonction est maintenant définie et sera appelée automatiquement
        else
            echo "⚠️  fileman nécessite ZSH pour l'instant"
            echo "💡 Migration complète vers POSIX en cours..."
            return 1
        fi
    else
        echo "❌ Erreur: fileman non trouvé: $FILEMAN_ORIGINAL"
        return 1
    fi
}

