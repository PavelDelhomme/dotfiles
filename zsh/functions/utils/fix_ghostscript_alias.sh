#!/bin/zsh

################################################################################
# Script pour résoudre le conflit entre gs (git status) et ghostscript
# Détecte si ghostscript est installé et configure les aliases automatiquement
# S'exécute à chaque ouverture de terminal
################################################################################

# Vérifier si ghostscript est installé en cherchant directement dans le PATH système
# On utilise 'whence -p' ou 'which' pour bypasser les alias et fonctions
GS_BINARY=""
if whence -p gs >/dev/null 2>&1; then
    GS_BINARY=$(whence -p gs)
elif which gs >/dev/null 2>&1; then
    GS_BINARY=$(which gs)
fi

# Si on trouve un binaire gs et que c'est un exécutable
if [ -n "$GS_BINARY" ] && [ -x "$GS_BINARY" ]; then
    # Vérifier que c'est bien ghostscript (pas un autre binaire)
    # Ghostscript se trouve généralement dans /usr/bin/gs
    if [ -f "$GS_BINARY" ]; then
        # S'assurer que gs pointe vers git status (priorité sur le binaire)
        alias gs="git status" 2>/dev/null || true
        
        # Créer l'alias ghs pour ghostscript si pas déjà défini
        if ! alias ghs >/dev/null 2>&1; then
            alias ghs="command gs"
            # Utiliser les couleurs si disponibles, sinon texte simple
            if [ -n "$YELLOW" ] && [ -n "$NC" ]; then
                echo -e "${YELLOW}  ℹ️  Ghostscript détecté : alias 'ghs' créé pour accéder à ghostscript${NC}"
                echo -e "${YELLOW}     (l'alias 'gs' est configuré pour 'git status')${NC}"
            else
                echo "  ℹ️  Ghostscript détecté : alias 'ghs' créé pour accéder à ghostscript"
                echo "     (l'alias 'gs' est configuré pour 'git status')"
            fi
        fi
    fi
fi
