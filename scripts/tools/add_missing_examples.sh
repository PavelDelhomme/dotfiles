#!/bin/bash
# =============================================================================
# Script pour ajouter automatiquement des exemples aux fonctions qui n'en ont pas
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
FUNCTIONS_DIR="$DOTFILES_DIR/zsh/functions"

echo "🔍 Recherche des fonctions sans exemples..."

find "$FUNCTIONS_DIR" -type f \( -name "*.sh" -o -name "*.zsh" \) ! -name "*man.zsh" | while read -r file; do
    # Ignorer les fichiers qui sont des gestionnaires
    if [[ "$file" == *"man.zsh" ]] || [[ "$file" == *"backup"* ]]; then
        continue
    fi
    
    # Lire le fichier ligne par ligne
    in_function=false
    has_desc=false
    has_usage=false
    has_example=false
    func_name=""
    usage_line=""
    desc_line=""
    last_comment_line=0
    
    line_num=0
    while IFS= read -r line; do
        ((line_num++))
        
        # Détecter les commentaires DESC, USAGE, EXAMPLE
        if [[ "$line" =~ ^#\s*DESC: ]]; then
            has_desc=true
            desc_line="$line"
            last_comment_line=$line_num
        elif [[ "$line" =~ ^#\s*USAGE: ]]; then
            has_usage=true
            usage_line="$line"
            last_comment_line=$line_num
        elif [[ "$line" =~ ^#\s*EXAMPLE: ]]; then
            has_example=true
        fi
        
        # Détecter le début d'une fonction
        if [[ "$line" =~ ^[a-zA-Z_][a-zA-Z0-9_]*\s*\(\) ]] || [[ "$line" =~ ^function\s+[a-zA-Z_][a-zA-Z0-9_]* ]]; then
            # Si on avait une fonction précédente sans exemple, on l'ajoute
            if [[ "$in_function" == true ]] && [[ "$has_desc" == true ]] && [[ "$has_usage" == true ]] && [[ "$has_example" == false ]] && [[ -n "$func_name" ]]; then
                # Générer un exemple basique
                example="# EXAMPLE: $func_name"
                
                # Extraire les arguments de USAGE pour créer un exemple plus réaliste
                if [[ "$usage_line" =~ \<([^>]+)\> ]]; then
                    arg="${BASH_REMATCH[1]}"
                    # Créer un exemple avec un argument générique
                    case "$arg" in
                        *file*|*path*|*dir*) example="# EXAMPLE: $func_name ~/example.txt" ;;
                        *port*) example="# EXAMPLE: $func_name 8080" ;;
                        *process*) example="# EXAMPLE: $func_name firefox" ;;
                        *container*) example="# EXAMPLE: $func_name mycontainer" ;;
                        *) example="# EXAMPLE: $func_name" ;;
                    esac
                fi
                
                # Insérer l'exemple après la ligne USAGE
                sed -i "${last_comment_line}a$example" "$file"
                echo "✅ Ajouté exemple pour $func_name dans $(basename "$file")"
            fi
            
            # Réinitialiser pour la nouvelle fonction
            in_function=true
            has_desc=false
            has_usage=false
            has_example=false
            func_name=$(echo "$line" | sed -E 's/^(function )?([a-zA-Z_][a-zA-Z0-9_]*)\(.*/\2/')
            last_comment_line=0
        fi
    done < "$file"
    
    # Vérifier la dernière fonction du fichier
    if [[ "$has_desc" == true ]] && [[ "$has_usage" == true ]] && [[ "$has_example" == false ]] && [[ -n "$func_name" ]]; then
        example="# EXAMPLE: $func_name"
        if [[ "$usage_line" =~ \<([^>]+)\> ]]; then
            arg="${BASH_REMATCH[1]}"
            case "$arg" in
                *file*|*path*|*dir*) example="# EXAMPLE: $func_name ~/example.txt" ;;
                *port*) example="# EXAMPLE: $func_name 8080" ;;
                *process*) example="# EXAMPLE: $func_name firefox" ;;
                *) example="# EXAMPLE: $func_name" ;;
            esac
        fi
        sed -i "${last_comment_line}a$example" "$file"
        echo "✅ Ajouté exemple pour $func_name dans $(basename "$file")"
    fi
done

echo ""
echo "✅ Terminé !"

