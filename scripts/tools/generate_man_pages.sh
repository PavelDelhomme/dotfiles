#!/bin/bash
# =============================================================================
# Générateur automatique de pages man pour les fonctions personnalisées
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
FUNCTIONS_DIR="$DOTFILES_DIR/zsh/functions"
MAN_DIR="$DOTFILES_DIR/docs/man"
DOC_DIR="$DOTFILES_DIR/docs/functions"

mkdir -p "$MAN_DIR" "$DOC_DIR"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📚 Génération des pages man pour les fonctions personnalisées...${NC}"
echo ""

# Fonction pour extraire la documentation d'un fichier
extract_docs() {
    local file="$1"
    local func_name="$2"
    
    # Extraire DESC, USAGE, EXAMPLE
    local desc=$(grep -E "^#\s*DESC:" "$file" | head -1 | sed 's/^#\s*DESC:\s*//')
    local usage=$(grep -E "^#\s*USAGE:" "$file" | head -1 | sed 's/^#\s*USAGE:\s*//')
    local examples=$(grep -E "^#\s*EXAMPLE:" "$file" | sed 's/^#\s*EXAMPLE:\s*//')
    
    if [ -z "$desc" ] && [ -z "$usage" ]; then
        return 1
    fi
    
    # Créer la page man
    local man_file="$MAN_DIR/${func_name}.md"
    
    cat > "$man_file" <<EOF
# ${func_name^^}(1) - $(echo "$desc" | cut -d'.' -f1)

## NOM

${func_name} - $desc

## SYNOPSIS

**${func_name}** $usage

## DESCRIPTION

$desc

## OPTIONS

(À compléter selon les besoins de la fonction)

## ARGUMENTS

(À compléter selon les besoins de la fonction)

## EXEMPLES

$(if [ -n "$examples" ]; then
    echo "$examples" | sed 's/^/```\n/; s/$/\n```/'
else
    echo "Aucun exemple disponible pour le moment."
fi)

## VOIR AUSSI

- **help**(1) - Système d'aide pour les fonctions personnalisées
- **man**(1) - Pages de manuel système

## AUTEUR

Paul Delhomme - Système de dotfiles personnalisé

EOF
    
    echo -e "${GREEN}✓${NC} Page man créée: ${func_name}.md"
}

# Parcourir tous les fichiers de fonctions
count=0
find "$FUNCTIONS_DIR" -type f \( -name "*.sh" -o -name "*.zsh" \) 2>/dev/null | while read -r file; do
    # Extraire les noms de fonctions
    grep -E "^[a-zA-Z_][a-zA-Z0-9_]*\s*\(\)|^function [a-zA-Z_]" "$file" 2>/dev/null | while read -r line; do
        func_name=$(echo "$line" | sed -E 's/^(function )?([a-zA-Z_][a-zA-Z0-9_]*)\(.*/\2/')
        
        if [ -n "$func_name" ] && [ "$func_name" != "function" ]; then
            # Vérifier si une page man existe déjà
            if [ ! -f "$MAN_DIR/${func_name}.md" ]; then
                extract_docs "$file" "$func_name" && ((count++))
            fi
        fi
    done
done

echo ""
echo -e "${GREEN}✅ Génération terminée${NC}"
echo ""
echo "💡 Les pages man sont disponibles dans: $MAN_DIR"
echo "💡 Utilisez 'man <nom_fonction>' pour les consulter"

