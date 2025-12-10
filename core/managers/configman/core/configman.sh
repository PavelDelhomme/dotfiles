#!/bin/sh
# =============================================================================
# CONFIGMAN - Configuration Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des configurations système
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

# DESC: Gestionnaire interactif complet pour les configurations système
# USAGE: configman [category]
# NOTE: Pour l'instant, ce wrapper charge le fichier ZSH original
# TODO: Migrer complètement vers POSIX
configman() {
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    CONFIGMAN_ORIGINAL="$DOTFILES_DIR/zsh/functions/configman/core/configman.zsh"
    
    if [ -f "$CONFIGMAN_ORIGINAL" ]; then
        # Charger le fichier ZSH original (temporaire)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Source le fichier (définit la fonction configman)
            . "$CONFIGMAN_ORIGINAL"
            # La fonction est maintenant définie et sera appelée automatiquement
        else
            echo "⚠️  configman nécessite ZSH pour l'instant"
            echo "💡 Migration complète vers POSIX en cours..."
            return 1
        fi
    else
        echo "❌ Erreur: configman non trouvé: $CONFIGMAN_ORIGINAL"
        return 1
    fi
}

