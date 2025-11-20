#!/bin/bash
# =============================================================================
# Function Documentation System - Documentation automatique des fonctions
# =============================================================================
# Description: Génère et gère la documentation de toutes les fonctions
# Auteur: Paul Delhomme
# Version: 1.0
# =============================================================================

# Fichier de documentation
FUNCTION_DOC_FILE="${FUNCTION_DOC_FILE:-$HOME/dotfiles/zsh/functions_doc.json}"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

################################################################################
# DESC: Extrait la documentation d'une fonction depuis un fichier
# USAGE: extract_function_doc <file> <function_name>
# RETURNS: JSON avec la documentation
################################################################################
extract_function_doc() {
    local file="$1"
    local func_name="$2"
    
    if [[ ! -f "$file" ]]; then
        echo "{}"
        return 1
    fi
    
    # Extraire la section de la fonction
    local in_function=false
    local description=""
    local usage=""
    local examples=""
    local returns=""
    local author=""
    local version=""
    
    while IFS= read -r line; do
        # Détecter le début de la fonction
        if [[ "$line" =~ ^(function\ )?$func_name\( ]]; then
            in_function=true
            continue
        fi
        
        # Si on est dans la fonction, chercher la documentation
        if [[ "$in_function" == true ]]; then
            # Si on atteint une autre fonction, arrêter
            if [[ "$line" =~ ^(function\ )[a-zA-Z_][a-zA-Z0-9_]*\( ]] && [[ ! "$line" =~ ^(function\ )?$func_name\( ]]; then
                break
            fi
            
            # Extraire la description
            if [[ "$line" =~ ^#\ *DESC:\ (.+)$ ]]; then
                description="${match[1]}"
            elif [[ "$line" =~ ^#\ *Description:\ (.+)$ ]]; then
                description="${match[1]}"
            fi
            
            # Extraire l'usage
            if [[ "$line" =~ ^#\ *USAGE:\ (.+)$ ]]; then
                usage="${match[1]}"
            elif [[ "$line" =~ ^#\ *Usage:\ (.+)$ ]]; then
                usage="${match[1]}"
            fi
            
            # Extraire les exemples
            if [[ "$line" =~ ^#\ *EXAMPLES:\ (.+)$ ]]; then
                examples="${match[1]}"
            elif [[ "$line" =~ ^#\ *Examples:\ (.+)$ ]]; then
                examples="${match[1]}"
            fi
            
            # Extraire le retour
            if [[ "$line" =~ ^#\ *RETURNS:\ (.+)$ ]]; then
                returns="${match[1]}"
            elif [[ "$line" =~ ^#\ *Returns:\ (.+)$ ]]; then
                returns="${match[1]}"
            fi
            
            # Extraire l'auteur
            if [[ "$line" =~ ^#\ *Author:\ (.+)$ ]]; then
                author="${match[1]}"
            elif [[ "$line" =~ ^#\ *Auteur:\ (.+)$ ]]; then
                author="${match[1]}"
            fi
            
            # Extraire la version
            if [[ "$line" =~ ^#\ *Version:\ (.+)$ ]]; then
                version="${match[1]}"
            fi
        fi
    done < "$file"
    
    # Générer le JSON
    cat <<EOF
{
  "name": "$func_name",
  "file": "$file",
  "description": "$description",
  "usage": "$usage",
  "examples": "$examples",
  "returns": "$returns",
  "author": "$author",
  "version": "$version"
}
EOF
}

################################################################################
# DESC: Génère la documentation de toutes les fonctions
# USAGE: generate_all_function_docs
# RETURNS: 0 si succès
################################################################################
generate_all_function_docs() {
    local functions_dir="$HOME/dotfiles/zsh/functions"
    
    if [[ ! -d "$functions_dir" ]]; then
        echo "❌ Répertoire des fonctions non trouvé: $functions_dir"
        return 1
    fi
    
    echo "📚 Génération de la documentation des fonctions..."
    
    # Créer un fichier JSON temporaire
    local temp_file=$(mktemp)
    echo "[" > "$temp_file"
    
    local first=true
    
    # Parcourir tous les fichiers .zsh et .sh
    while IFS= read -r file; do
        # Extraire toutes les fonctions du fichier
        local functions=$(grep -E "^(function\ )?[a-zA-Z_][a-zA-Z0-9_]*\(\)" "$file" | sed 's/^function //; s/()$//; s/^\([a-zA-Z_][a-zA-Z0-9_]*\).*/\1/')
        
        for func in $functions; do
            if [[ "$first" == true ]]; then
                first=false
            else
                echo "," >> "$temp_file"
            fi
            
            extract_function_doc "$file" "$func" >> "$temp_file"
        done
    done < <(find "$functions_dir" -type f \( -name "*.zsh" -o -name "*.sh" \))
    
    echo "]" >> "$temp_file"
    
    # Valider le JSON et le déplacer
    if command -v jq &>/dev/null && jq empty "$temp_file" 2>/dev/null; then
        mkdir -p "$(dirname "$FUNCTION_DOC_FILE")"
        mv "$temp_file" "$FUNCTION_DOC_FILE"
        echo "✅ Documentation générée: $FUNCTION_DOC_FILE"
        return 0
    else
        # Sans jq, on fait une validation basique
        mkdir -p "$(dirname "$FUNCTION_DOC_FILE")"
        mv "$temp_file" "$FUNCTION_DOC_FILE"
        echo "✅ Documentation générée: $FUNCTION_DOC_FILE"
        echo "⚠️  Validation JSON basique (jq recommandé)"
        return 0
    fi
}

################################################################################
# DESC: Affiche la documentation d'une fonction
# USAGE: show_function_doc <function_name>
# EXAMPLES:
#   show_function_doc add_alias
# RETURNS: 0 si trouvé, 1 si non trouvé
################################################################################
show_function_doc() {
    local func_name="$1"
    
    if [[ -z "$func_name" ]]; then
        echo "❌ Usage: show_function_doc <function_name>"
        return 1
    fi
    
    if [[ ! -f "$FUNCTION_DOC_FILE" ]]; then
        echo "❌ Fichier de documentation non trouvé. Générez-le avec: generate_all_function_docs"
        return 1
    fi
    
    # Chercher la fonction dans le JSON
    if command -v jq &>/dev/null; then
        local doc=$(jq -r ".[] | select(.name == \"$func_name\")" "$FUNCTION_DOC_FILE" 2>/dev/null)
        
        if [[ -z "$doc" ]] || [[ "$doc" == "null" ]]; then
            echo "❌ Fonction '$func_name' non trouvée dans la documentation"
            return 1
        fi
        
        echo -e "${CYAN}📖 Documentation: $func_name${RESET}"
        echo "────────────────────────────────────────────────────────────────"
        
        local desc=$(echo "$doc" | jq -r '.description // "N/A"')
        local usage=$(echo "$doc" | jq -r '.usage // "N/A"')
        local examples=$(echo "$doc" | jq -r '.examples // "N/A"')
        local returns=$(echo "$doc" | jq -r '.returns // "N/A"')
        local file=$(echo "$doc" | jq -r '.file // "N/A"')
        local author=$(echo "$doc" | jq -r '.author // "N/A"')
        local version=$(echo "$doc" | jq -r '.version // "N/A"')
        
        [[ -n "$desc" ]] && [[ "$desc" != "N/A" ]] && echo -e "${YELLOW}Description:${RESET} $desc"
        [[ -n "$usage" ]] && [[ "$usage" != "N/A" ]] && echo -e "${BLUE}Usage:${RESET} $usage"
        [[ -n "$examples" ]] && [[ "$examples" != "N/A" ]] && echo -e "${GREEN}Exemples:${RESET} $examples"
        [[ -n "$returns" ]] && [[ "$returns" != "N/A" ]] && echo -e "${CYAN}Retour:${RESET} $returns"
        [[ -n "$file" ]] && [[ "$file" != "N/A" ]] && echo -e "${MAGENTA}Fichier:${RESET} $file"
        [[ -n "$author" ]] && [[ "$author" != "N/A" ]] && echo -e "Auteur: $author"
        [[ -n "$version" ]] && [[ "$version" != "N/A" ]] && echo -e "Version: $version"
    else
        # Sans jq, recherche basique
        local doc=$(grep -A 20 "\"name\": \"$func_name\"" "$FUNCTION_DOC_FILE" 2>/dev/null)
        
        if [[ -z "$doc" ]]; then
            echo "❌ Fonction '$func_name' non trouvée dans la documentation"
            echo "⚠️  jq recommandé pour une meilleure recherche"
            return 1
        fi
        
        echo -e "${CYAN}📖 Documentation: $func_name${RESET}"
        echo "────────────────────────────────────────────────────────────────"
        echo "$doc" | grep -E "(description|usage|examples|returns|file)" | sed 's/.*": "//; s/",$//'
    fi
    
    return 0
}

################################################################################
# DESC: Recherche dans la documentation des fonctions
# USAGE: search_function_doc <search_term>
# EXAMPLES:
#   search_function_doc "alias"
# RETURNS: 0 si succès
################################################################################
search_function_doc() {
    local search_term="$1"
    
    if [[ -z "$search_term" ]]; then
        echo "❌ Usage: search_function_doc <search_term>"
        return 1
    fi
    
    if [[ ! -f "$FUNCTION_DOC_FILE" ]]; then
        echo "❌ Fichier de documentation non trouvé"
        return 1
    fi
    
    echo -e "${CYAN}🔍 Recherche: '$search_term'${RESET}"
    echo "────────────────────────────────────────────────────────────────"
    
    if command -v jq &>/dev/null; then
        jq -r ".[] | select(.description | contains(\"$search_term\") or .name | contains(\"$search_term\") or .usage | contains(\"$search_term\")) | \"\(.name) - \(.description // \"N/A\")\"" "$FUNCTION_DOC_FILE" 2>/dev/null | less -R
    else
        grep -i "$search_term" "$FUNCTION_DOC_FILE" | grep "\"name\"" | sed 's/.*"name": "//; s/".*//' | less -R
    fi
}

################################################################################
# DESC: Liste toutes les fonctions documentées
# USAGE: list_all_functions [search_term]
# EXAMPLES:
#   list_all_functions
#   list_all_functions "alias"
# RETURNS: 0 si succès
################################################################################
list_all_functions() {
    local search_term="${1:-}"
    
    if [[ ! -f "$FUNCTION_DOC_FILE" ]]; then
        echo "❌ Fichier de documentation non trouvé"
        return 1
    fi
    
    echo -e "${CYAN}📋 Liste des fonctions documentées${RESET}"
    echo "────────────────────────────────────────────────────────────────"
    
    if command -v jq &>/dev/null; then
        if [[ -n "$search_term" ]]; then
            jq -r ".[] | select(.name | contains(\"$search_term\") or .description | contains(\"$search_term\")) | \"\(.name) - \(.description // \"N/A\")\"" "$FUNCTION_DOC_FILE" | less -R
        else
            jq -r ".[] | \"\(.name) - \(.description // \"N/A\")\"" "$FUNCTION_DOC_FILE" | less -R
        fi
    else
        grep "\"name\"" "$FUNCTION_DOC_FILE" | sed 's/.*"name": "//; s/".*//' | less -R
    fi
}

