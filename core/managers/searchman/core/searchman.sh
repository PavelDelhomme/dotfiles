#!/bin/sh
# =============================================================================
# SEARCHMAN - Search Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet de recherche et exploration
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

# DESC: Gestionnaire interactif complet pour la recherche et l'exploration
# USAGE: searchman [command]
# EXAMPLE: searchman
# NOTE: Pour l'instant, ce wrapper charge le fichier ZSH original
# TODO: Migrer complètement vers POSIX
searchman() {
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    SEARCHMAN_ORIGINAL="$DOTFILES_DIR/zsh/functions/searchman.zsh"
    
    if [ -f "$SEARCHMAN_ORIGINAL" ]; then
        # Charger le fichier ZSH original (temporaire)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Source le fichier (définit la fonction searchman)
            . "$SEARCHMAN_ORIGINAL"
            # La fonction est maintenant définie et sera appelée automatiquement
        else
            echo "⚠️  searchman nécessite ZSH pour l'instant"
            echo "💡 Migration complète vers POSIX en cours..."
            return 1
        fi
    else
        echo "❌ Erreur: searchman non trouvé: $SEARCHMAN_ORIGINAL"
        return 1
    fi
}

