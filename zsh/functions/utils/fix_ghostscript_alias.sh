#!/bin/zsh

################################################################################
# Script pour résoudre le conflit entre gs (git status) et ghostscript
# Détecte si ghostscript est installé et configure les aliases automatiquement
# S'exécute à chaque ouverture de terminal
################################################################################

# Vérifier si ghostscript est installé (en utilisant command pour bypasser les alias)
if command -v gs >/dev/null 2>&1; then
    # Obtenir le chemin réel de gs (bypass alias)
    GS_PATH=$(command -v gs 2>/dev/null)
    
    # Vérifier que c'est bien un exécutable (ghostscript) et pas un alias
    if [ -n "$GS_PATH" ] && [ -x "$GS_PATH" ]; then
        # Vérifier que gs n'est pas déjà un alias pour git status
        GS_ALIAS=$(alias gs 2>/dev/null | grep -o "git status" || echo "")
        
        # Si gs n'est pas encore un alias pour git status, on configure
        if [ -z "$GS_ALIAS" ]; then
            # S'assurer que gs pointe vers git status
            alias gs="git status"
        fi
        
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
