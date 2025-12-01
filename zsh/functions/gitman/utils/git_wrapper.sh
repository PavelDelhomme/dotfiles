#!/bin/zsh
# =============================================================================
# GIT WRAPPER - Wrapper intelligent pour les commandes Git
# =============================================================================
# Description: Intercepte les commandes Git et vérifie si on est dans un dépôt
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Wrapper intelligent pour Git qui vérifie si on est dans un dépôt
# USAGE: git [command] [args]
# EXAMPLE: git status
# EXAMPLE: git commit -m "message"
git() {
    # Commandes Git qui ne nécessitent pas d'être dans un dépôt
    local no_repo_commands=(
        "init" "clone" "config" "version" "--version" "help" "--help"
        "credential" "credential-cache" "credential-store"
    )
    
    # Vérifier si la commande nécessite un dépôt
    local cmd="$1"
    local needs_repo=true
    
    for no_repo_cmd in "${no_repo_commands[@]}"; do
        if [[ "$cmd" == "$no_repo_cmd" ]]; then
            needs_repo=false
            break
        fi
    done
    
    # Si la commande nécessite un dépôt, vérifier qu'on est dans un dépôt Git
    if [[ "$needs_repo" == true ]]; then
        # Vérifier si on est dans un dépôt Git
        local git_dir
        git_dir=$(command git rev-parse --git-dir 2>/dev/null)
        
        if [[ $? -ne 0 ]] || [[ -z "$git_dir" ]]; then
            # Pas dans un dépôt Git
            echo "❌ Erreur: Ce répertoire n'est pas un dépôt Git"
            echo ""
            echo "💡 Solutions:"
            echo "   1. Initialiser un dépôt: git init"
            echo "   2. Cloner un dépôt: git clone <url>"
            echo "   3. Naviguer vers un dépôt Git existant"
            echo ""
            echo "📁 Répertoire actuel: $PWD"
            return 1
        fi
    fi
    
    # Exécuter la commande Git réelle
    command git "$@"
}

