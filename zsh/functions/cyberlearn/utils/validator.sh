#!/bin/zsh
# =============================================================================
# VALIDATOR - Validation des exercices et challenges
# =============================================================================
# Description: Système de validation pour les exercices pratiques
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Valider une réponse d'exercice
validate_exercise() {
    local exercise_id="$1"
    local user_answer="$2"
    local expected_answer="$3"
    
    if [ "$user_answer" = "$expected_answer" ]; then
        echo "correct"
        return 0
    else
        echo "incorrect"
        return 1
    fi
}

# Valider une commande
validate_command() {
    local command="$1"
    local expected_output="$2"
    
    local actual_output=$(eval "$command" 2>/dev/null)
    
    if echo "$actual_output" | grep -q "$expected_output"; then
        echo "correct"
        return 0
    else
        echo "incorrect"
        return 1
    fi
}

# Valider un fichier créé
validate_file() {
    local file_path="$1"
    local expected_content="$2"
    
    if [ -f "$file_path" ]; then
        if [ -n "$expected_content" ]; then
            if grep -q "$expected_content" "$file_path"; then
                echo "correct"
                return 0
            fi
        else
            echo "correct"
            return 0
        fi
    fi
    
    echo "incorrect"
    return 1
}

