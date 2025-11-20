#!/bin/zsh

################################################################################
# Script pour résoudre le conflit entre gs (git status) et ghostscript
# Détecte si ghostscript est installé et configure les aliases automatiquement
################################################################################

# Vérifier si ghostscript est installé
if command -v gs >/dev/null 2>&1 && [ -x "$(command -v gs)" ]; then
    # Vérifier que c'est bien ghostscript (pas un alias)
    GS_PATH=$(command -v gs)
    GS_TYPE=$(file "$GS_PATH" 2>/dev/null | grep -i "executable" || echo "")
    
    # Si c'est un exécutable (ghostscript) et pas déjà un alias
    if [ -n "$GS_TYPE" ] && [ "$(alias gs 2>/dev/null | grep -c 'git status')" -eq 0 ]; then
        # Créer l'alias ghs pour ghostscript si pas déjà défini
        if ! alias ghs >/dev/null 2>&1; then
            alias ghs="command gs"
            echo "  ℹ️  Ghostscript détecté : alias 'ghs' créé pour accéder à ghostscript"
            echo "     (l'alias 'gs' reste pour 'git status')"
        fi
        
        # S'assurer que gs pointe vers git status
        if ! alias gs >/dev/null 2>&1 || [ "$(alias gs 2>/dev/null | grep -c 'git status')" -eq 0 ]; then
            alias gs="git status"
        fi
    fi
fi

