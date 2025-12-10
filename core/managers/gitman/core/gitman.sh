#!/bin/sh
# =============================================================================
# GITMAN - Git Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des opérations Git
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

# DESC: Gestionnaire interactif complet pour les opérations Git
# USAGE: gitman [command] [args]
# NOTE: Pour l'instant, ce wrapper charge le fichier ZSH original
# TODO: Migrer complètement vers POSIX
gitman() {
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    GITMAN_ORIGINAL="$DOTFILES_DIR/zsh/functions/gitman/core/gitman.zsh"
    
    if [ -f "$GITMAN_ORIGINAL" ]; then
        # Charger le fichier ZSH original (temporaire)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Source le fichier (définit la fonction gitman)
            . "$GITMAN_ORIGINAL"
            # La fonction est maintenant définie et sera appelée automatiquement
        else
            echo "⚠️  gitman nécessite ZSH pour l'instant"
            echo "💡 Migration complète vers POSIX en cours..."
            return 1
        fi
    else
        echo "❌ Erreur: gitman non trouvé: $GITMAN_ORIGINAL"
        return 1
    fi
}

