#!/bin/sh
# =============================================================================
# INSTALLMAN - Installation Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des installations d'outils
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

# DESC: Gestionnaire interactif complet pour installer des outils de développement
# USAGE: installman [tool-name]
# NOTE: Pour l'instant, ce wrapper charge le fichier ZSH original
# TODO: Migrer complètement vers POSIX
installman() {
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    INSTALLMAN_ORIGINAL="$DOTFILES_DIR/zsh/functions/installman/core/installman.zsh"
    
    if [ -f "$INSTALLMAN_ORIGINAL" ]; then
        # Charger le fichier ZSH original (temporaire)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Source le fichier (définit la fonction installman)
            . "$INSTALLMAN_ORIGINAL"
            # La fonction est maintenant définie et sera appelée automatiquement
        else
            echo "⚠️  installman nécessite ZSH pour l'instant"
            echo "💡 Migration complète vers POSIX en cours..."
            return 1
        fi
    else
        echo "❌ Erreur: installman non trouvé: $INSTALLMAN_ORIGINAL"
        return 1
    fi
}

