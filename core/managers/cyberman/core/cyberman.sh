#!/bin/sh
# =============================================================================
# CYBERMAN - Cybersecurity Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des outils de cybersécurité
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

# DESC: Gestionnaire interactif complet pour les outils de cybersécurité
# USAGE: cyberman [module]
# NOTE: Pour l'instant, ce wrapper charge le fichier ZSH original
# TODO: Migrer complètement vers POSIX
cyberman() {
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    CYBERMAN_ORIGINAL="$DOTFILES_DIR/zsh/functions/cyberman/core/cyberman.zsh"
    
    if [ -f "$CYBERMAN_ORIGINAL" ]; then
        # Charger le fichier ZSH original (temporaire)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Source le fichier (définit la fonction cyberman)
            . "$CYBERMAN_ORIGINAL"
            # La fonction est maintenant définie et sera appelée automatiquement
        else
            echo "⚠️  cyberman nécessite ZSH pour l'instant"
            echo "💡 Migration complète vers POSIX en cours..."
            return 1
        fi
    else
        echo "❌ Erreur: cyberman non trouvé: $CYBERMAN_ORIGINAL"
        return 1
    fi
}

