#!/bin/sh
# =============================================================================
# NETMAN - Network Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet de réseau
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

# DESC: Gestionnaire interactif complet pour gérer le réseau
# USAGE: netman [command]
# NOTE: Pour l'instant, ce wrapper charge le fichier ZSH original
# TODO: Migrer complètement vers POSIX
netman() {
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    NETMAN_ORIGINAL="$DOTFILES_DIR/zsh/functions/netman.zsh"
    
    if [ -f "$NETMAN_ORIGINAL" ]; then
        # Charger le fichier ZSH original (temporaire)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Source le fichier (définit la fonction netman)
            . "$NETMAN_ORIGINAL"
            # La fonction est maintenant définie et sera appelée automatiquement
        else
            echo "⚠️  netman nécessite ZSH pour l'instant"
            echo "💡 Migration complète vers POSIX en cours..."
            return 1
        fi
    else
        echo "❌ Erreur: netman non trouvé: $NETMAN_ORIGINAL"
        return 1
    fi
}

