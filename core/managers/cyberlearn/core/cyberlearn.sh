#!/bin/sh
# =============================================================================
# CYBERLEARN - Cyber Learning Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire d'apprentissage cybersécurité
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

# DESC: Gestionnaire interactif complet pour l'apprentissage cybersécurité
# USAGE: cyberlearn [command]
# NOTE: Pour l'instant, ce wrapper charge le fichier ZSH original
# TODO: Migrer complètement vers POSIX
cyberlearn() {
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    CYBERLEARN_ORIGINAL="$DOTFILES_DIR/zsh/functions/cyberlearn.zsh"
    
    if [ -f "$CYBERLEARN_ORIGINAL" ]; then
        # Charger le fichier ZSH original (temporaire)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Source le fichier (définit la fonction cyberlearn)
            . "$CYBERLEARN_ORIGINAL"
            # La fonction est maintenant définie et sera appelée automatiquement
        else
            echo "⚠️  cyberlearn nécessite ZSH pour l'instant"
            echo "💡 Migration complète vers POSIX en cours..."
            return 1
        fi
    else
        echo "❌ Erreur: cyberlearn non trouvé: $CYBERLEARN_ORIGINAL"
        return 1
    fi
}

