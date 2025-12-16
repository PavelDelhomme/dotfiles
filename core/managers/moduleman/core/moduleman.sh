#!/bin/sh
# =============================================================================
# MODULEMAN - Module Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire de modules
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

# DESC: Gestionnaire interactif complet pour gérer les modules
# USAGE: moduleman [command]
# NOTE: Pour l'instant, ce wrapper charge le fichier ZSH original
# TODO: Migrer complètement vers POSIX
moduleman() {
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    MODULEMAN_ORIGINAL="$DOTFILES_DIR/zsh/functions/moduleman.zsh"
    
    if [ -f "$MODULEMAN_ORIGINAL" ]; then
        # Charger le fichier ZSH original (temporaire)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Source le fichier (définit la fonction moduleman)
            . "$MODULEMAN_ORIGINAL"
            # La fonction est maintenant définie et sera appelée automatiquement
        else
            echo "⚠️  moduleman nécessite ZSH pour l'instant"
            echo "💡 Migration complète vers POSIX en cours..."
            return 1
        fi
    else
        echo "❌ Erreur: moduleman non trouvé: $MODULEMAN_ORIGINAL"
        return 1
    fi
}

