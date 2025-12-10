#!/bin/sh
# =============================================================================
# ALIAMAN - Alias Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet et interactif des alias
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

# DESC: Gestionnaire interactif complet pour gérer les alias
# USAGE: aliaman [command]
# EXAMPLE: aliaman
# NOTE: Pour l'instant, ce wrapper charge le fichier ZSH original
# TODO: Migrer complètement vers POSIX
aliaman() {
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    ALIAMAN_ORIGINAL="$DOTFILES_DIR/zsh/functions/aliaman.zsh"
    
    if [ -f "$ALIAMAN_ORIGINAL" ]; then
        # Charger le fichier ZSH original (temporaire)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Source le fichier (définit la fonction aliaman)
            . "$ALIAMAN_ORIGINAL"
            # La fonction est maintenant définie et sera appelée automatiquement
        else
            echo "⚠️  aliaman nécessite ZSH pour l'instant"
            echo "💡 Migration complète vers POSIX en cours..."
            return 1
        fi
    else
        echo "❌ Erreur: aliaman non trouvé: $ALIAMAN_ORIGINAL"
        return 1
    fi
}

