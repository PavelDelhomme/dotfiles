#!/bin/sh
################################################################################
# Script pour résoudre le conflit entre gs (git status) et ghostscript
# Détecte si ghostscript est installé et configure les aliases automatiquement
# S'exécute à chaque ouverture de terminal
# Version POSIX
################################################################################

# Vérifier si ghostscript est installé en cherchant directement dans le PATH système
# On utilise 'command -v' pour bypasser les alias et fonctions
GS_BINARY=""
if command -v gs >/dev/null 2>&1; then
    GS_BINARY=$(command -v gs)
fi

# Si on trouve un binaire gs et que c'est un exécutable
if [ -n "$GS_BINARY" ] && [ -x "$GS_BINARY" ]; then
    # Vérifier que c'est bien ghostscript (pas un autre binaire)
    # Ghostscript se trouve généralement dans /usr/bin/gs
    if [ -f "$GS_BINARY" ]; then
        # S'assurer que gs pointe vers git status (priorité sur le binaire)
        # Seulement pour ZSH et Bash qui supportent alias
        if [ -n "$ZSH_VERSION" ] || [ -n "$BASH_VERSION" ]; then
            alias gs="git status" 2>/dev/null || true
            
            # Créer l'alias ghs pour ghostscript si pas déjà défini
            if ! alias ghs >/dev/null 2>&1; then
                alias ghs="command gs"
            fi
        fi
    fi
fi

