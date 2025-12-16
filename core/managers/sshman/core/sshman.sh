#!/bin/sh
# =============================================================================
# SSMAN - SSH Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet de SSH
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

# DESC: Gestionnaire interactif complet pour gérer SSH
# USAGE: sshman [command]
# NOTE: Pour l'instant, ce wrapper charge le fichier ZSH original
# TODO: Migrer complètement vers POSIX
sshman() {
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    SSMAN_ORIGINAL="$DOTFILES_DIR/zsh/functions/sshman.zsh"
    
    if [ -f "$SSMAN_ORIGINAL" ]; then
        # Charger le fichier ZSH original (temporaire)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Source le fichier (définit la fonction sshman)
            . "$SSMAN_ORIGINAL"
            # La fonction est maintenant définie et sera appelée automatiquement
        else
            echo "⚠️  sshman nécessite ZSH pour l'instant"
            echo "💡 Migration complète vers POSIX en cours..."
            return 1
        fi
    else
        echo "❌ Erreur: sshman non trouvé: $SSMAN_ORIGINAL"
        return 1
    fi
}

