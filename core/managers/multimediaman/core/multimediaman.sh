#!/bin/sh
# =============================================================================
# MULTIMEDIAMAN - Multimedia Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire de multimédia
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

# DESC: Gestionnaire interactif complet pour gérer le multimédia
# USAGE: multimediaman [command]
# NOTE: Pour l'instant, ce wrapper charge le fichier ZSH original
# TODO: Migrer complètement vers POSIX
multimediaman() {
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    MULTIMEDIAMAN_ORIGINAL="$DOTFILES_DIR/zsh/functions/multimediaman.zsh"
    
    if [ -f "$MULTIMEDIAMAN_ORIGINAL" ]; then
        # Charger le fichier ZSH original (temporaire)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Source le fichier (définit la fonction multimediaman)
            . "$MULTIMEDIAMAN_ORIGINAL"
            # La fonction est maintenant définie et sera appelée automatiquement
        else
            echo "⚠️  multimediaman nécessite ZSH pour l'instant"
            echo "💡 Migration complète vers POSIX en cours..."
            return 1
        fi
    else
        echo "❌ Erreur: multimediaman non trouvé: $MULTIMEDIAMAN_ORIGINAL"
        return 1
    fi
}

