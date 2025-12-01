# =============================================================================
# GIT WRAPPER - Wrapper intelligent pour les commandes Git (Fish)
# =============================================================================
# Description: Intercepte les commandes Git et vérifie si on est dans un dépôt
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Wrapper intelligent pour Git qui vérifie si on est dans un dépôt
# USAGE: git [command] [args]
function git --description "Wrapper intelligent pour Git"
    # Commandes Git qui ne nécessitent pas d'être dans un dépôt
    set -l no_repo_commands init clone config version --version help --help credential credential-cache credential-store
    
    # Vérifier si la commande nécessite un dépôt
    set -l cmd $argv[1]
    set -l needs_repo true
    
    for no_repo_cmd in $no_repo_commands
        if test "$cmd" = "$no_repo_cmd"
            set needs_repo false
            break
        end
    end
    
    # Si la commande nécessite un dépôt, vérifier qu'on est dans un dépôt Git
    if test "$needs_repo" = "true"
        # Vérifier si on est dans un dépôt Git
        set -l git_dir (command git rev-parse --git-dir 2>/dev/null)
        
        if test $status -ne 0 -o -z "$git_dir"
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
        end
    end
    
    # Exécuter la commande Git réelle
    command git $argv
end

