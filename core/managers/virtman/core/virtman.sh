#!/bin/sh
# =============================================================================
# VIRTMAN - Virtualization Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des outils de virtualisation
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

# DESC: Gestionnaire interactif complet pour les outils de virtualisation
# USAGE: virtman [module]
# NOTE: Pour l'instant, ce wrapper charge le fichier ZSH original
# TODO: Migrer complètement vers POSIX
virtman() {
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    VIRTMAN_ORIGINAL="$DOTFILES_DIR/zsh/functions/virtman/core/virtman.zsh"
    
    if [ -f "$VIRTMAN_ORIGINAL" ]; then
        # Charger le fichier ZSH original (temporaire)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Source le fichier (définit la fonction virtman)
            . "$VIRTMAN_ORIGINAL"
            # La fonction est maintenant définie et sera appelée automatiquement
        else
            echo "⚠️  virtman nécessite ZSH pour l'instant"
            echo "💡 Migration complète vers POSIX en cours..."
            return 1
        fi
    else
        echo "❌ Erreur: virtman non trouvé: $VIRTMAN_ORIGINAL"
        return 1
    fi
}

