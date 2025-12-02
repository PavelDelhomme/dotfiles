#!/bin/zsh
# =============================================================================
# PATH UTILS - Utilitaires pour la gestion du PATH dans env.sh
# =============================================================================
# Description: Fonctions utilitaires pour ajouter des chemins au PATH
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Chemins
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
ENV_FILE="${ENV_FILE:-$DOTFILES_DIR/zsh/env.sh}"

# =============================================================================
# AJOUTER AU PATH DANS env.sh
# =============================================================================
# DESC: Ajoute un chemin au PATH dans env.sh de manière permanente
# USAGE: add_path_to_env <path> [comment]
# EXAMPLE: add_path_to_env "/opt/flutter/bin" "Flutter SDK"
add_path_to_env() {
    local path_to_add="$1"
    local comment="$2"
    
    if [ -z "$path_to_add" ]; then
        echo "❌ Erreur: Chemin vide, impossible d'ajouter au PATH" >&2
        return 1
    fi
    
    echo "→ Ajout de $path_to_add au PATH dans env.sh..."
    
    # Vérifier si le chemin existe déjà dans env.sh (chercher la ligne exacte)
    if grep -q "add_to_path.*\"$path_to_add\"" "$ENV_FILE" 2>/dev/null || \
       grep -q "add_to_path.*'$path_to_add'" "$ENV_FILE" 2>/dev/null || \
       grep -q "$path_to_add" "$ENV_FILE" 2>/dev/null; then
        echo "✓ Le chemin $path_to_add est déjà présent dans env.sh"
        return 0
    fi
    
    # Trouver la dernière ligne avec add_to_path pour insérer après
    local insert_line
    insert_line=$(grep -n "add_to_path" "$ENV_FILE" 2>/dev/null | tail -1 | cut -d: -f1)
    
    if [ -z "$insert_line" ]; then
        # Si pas de add_to_path, trouver la section PATH
        insert_line=$(grep -n "^# === Ajout des chemins au PATH ===" "$ENV_FILE" 2>/dev/null | cut -d: -f1)
        if [ -n "$insert_line" ]; then
            # Chercher la première ligne add_to_path après cette section
            local section_start=$insert_line
            insert_line=$(sed -n "${section_start},\$p" "$ENV_FILE" | grep -n "add_to_path" | head -1 | cut -d: -f1)
            if [ -n "$insert_line" ]; then
                insert_line=$((section_start + insert_line - 1))
            else
                # Aucune ligne add_to_path trouvée, ajouter après la section
                insert_line=$(grep -n "^# ===" "$ENV_FILE" | grep -A1 "Ajout des chemins" | tail -1 | cut -d: -f1)
                insert_line=$((insert_line + 1))
            fi
        else
            # Pas de section trouvée, ajouter à la fin
            insert_line=$(wc -l < "$ENV_FILE" 2>/dev/null || echo "0")
            if [ "$insert_line" = "0" ]; then
                echo "❌ Erreur: Fichier env.sh vide ou inaccessible" >&2
                return 1
            fi
        fi
    else
        # Insérer après la dernière ligne add_to_path
        insert_line=$((insert_line + 1))
    fi
    
    # Préparer les lignes à ajouter
    local indent="    "
    local new_lines=""
    if [ -n "$comment" ]; then
        new_lines="${indent}# $comment\n${indent}add_to_path \"$path_to_add\" 2>/dev/null || true"
    else
        new_lines="${indent}add_to_path \"$path_to_add\" 2>/dev/null || true"
    fi
    
    # Créer un fichier temporaire avec la modification
    local temp_file=$(mktemp)
    
    # Ajouter les lignes avant et après l'insertion
    if [ -n "$insert_line" ] && [ "$insert_line" -gt 0 ]; then
        head -n $((insert_line - 1)) "$ENV_FILE" 2>/dev/null > "$temp_file"
        echo -e "$new_lines" >> "$temp_file"
        tail -n +$insert_line "$ENV_FILE" 2>/dev/null >> "$temp_file"
    else
        # Ajouter à la fin
        cat "$ENV_FILE" 2>/dev/null > "$temp_file"
        echo "" >> "$temp_file"
        echo -e "$new_lines" >> "$temp_file"
    fi
    
    # Remplacer le fichier original
    mv "$temp_file" "$ENV_FILE" 2>/dev/null || {
        echo "❌ Erreur: Impossible de modifier env.sh (permissions?)" >&2
        echo "⚠️  Vous pouvez ajouter manuellement: add_to_path \"$path_to_add\" dans $ENV_FILE" >&2
        return 1
    }
    
    echo "✓ Chemin $path_to_add ajouté à env.sh"
    
    # Ajouter aussi au PATH actuel de la session
    if [ -d "$path_to_add" ] && [[ ":$PATH:" != *":$path_to_add:"* ]]; then
        export PATH="$path_to_add:$PATH"
        echo "✓ Chemin ajouté au PATH de la session actuelle"
    fi
    
    return 0
}

