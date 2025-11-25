#!/bin/sh
# =============================================================================
# SYSTÈME D'AIDE UNIFIÉ POUR TOUTES LES FONCTIONS
# =============================================================================
# Ce script fournit un système d'aide générique pour toutes les fonctions
# personnalisées, avec support pour help, man, et documentation automatique
# =============================================================================

# Détection du shell
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_TYPE="fish"
else
    SHELL_TYPE="sh"
fi

# Répertoire de documentation
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DOC_DIR="$DOTFILES_DIR/docs/functions"
MAN_DIR="$DOTFILES_DIR/docs/man"

# Créer les répertoires si nécessaire
mkdir -p "$DOC_DIR" "$MAN_DIR"

# Fonction générique pour afficher l'aide d'une fonction
show_function_help() {
    local func_name="$1"
    local func_file=""
    
    # Chercher la fonction dans les fichiers sources
    if [ -n "$ZSH_VERSION" ]; then
        func_file=$(grep -r "^${func_name}()" "$DOTFILES_DIR/zsh/functions" 2>/dev/null | head -1 | cut -d: -f1)
    fi
    
    # Si on trouve un fichier, extraire la documentation
    if [ -f "$func_file" ]; then
        # Extraire les commentaires DESC et USAGE
        local desc=$(grep -E "^#\s*DESC:" "$func_file" | head -1 | sed 's/^#\s*DESC:\s*//')
        local usage=$(grep -E "^#\s*USAGE:" "$func_file" | head -1 | sed 's/^#\s*USAGE:\s*//')
        local examples=$(grep -E "^#\s*EXAMPLE:" "$func_file" | sed 's/^#\s*EXAMPLE:\s*//')
        
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📖 AIDE: $func_name"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        if [ -n "$desc" ]; then
            echo "📝 Description:"
            echo "   $desc"
            echo ""
        fi
        
        if [ -n "$usage" ]; then
            echo "💻 Usage:"
            echo "   $usage"
            echo ""
        fi
        
        if [ -n "$examples" ]; then
            echo "📚 Exemples:"
            echo "$examples" | sed 's/^/   /'
            echo ""
        fi
        
        # Afficher la page man si elle existe
        if [ -f "$MAN_DIR/${func_name}.md" ]; then
            echo "📄 Documentation complète disponible via: man ${func_name}"
            echo ""
        fi
        
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    else
        echo "❌ Fonction '$func_name' non trouvée ou non documentée"
        echo ""
        echo "💡 Astuce: Utilisez 'help' pour lister toutes les fonctions disponibles"
    fi
}

# Fonction pour lister toutes les fonctions disponibles
list_functions() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 FONCTIONS DISPONIBLES"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Lister toutes les fonctions dans zsh/functions
    find "$DOTFILES_DIR/zsh/functions" -type f -name "*.sh" -o -name "*.zsh" 2>/dev/null | while read -r file; do
        grep -E "^[a-zA-Z_][a-zA-Z0-9_]*\s*\(\)|^function [a-zA-Z_]" "$file" 2>/dev/null | while read -r line; do
            local func_name=$(echo "$line" | sed -E 's/^(function )?([a-zA-Z_][a-zA-Z0-9_]*)\(.*/\2/')
            local desc=$(grep -E "^#\s*DESC:" "$file" | head -1 | sed 's/^#\s*DESC:\s*//')
            
            if [ -n "$func_name" ]; then
                printf "  • %-25s" "$func_name"
                if [ -n "$desc" ]; then
                    echo " - $desc"
                else
                    echo ""
                fi
            fi
        done
    done
    
    echo ""
    echo "💡 Utilisez 'help <nom_fonction>' pour obtenir l'aide détaillée"
    echo "💡 Utilisez 'man <nom_fonction>' pour la documentation complète"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Fonction help principale
help() {
    if [ -z "$1" ]; then
        list_functions
    else
        show_function_help "$1"
    fi
}

# Fonction pour créer une page man depuis la documentation
create_man_page() {
    local func_name="$1"
    local man_file="$MAN_DIR/${func_name}.md"
    
    if [ -f "$man_file" ]; then
        # Afficher avec less ou cat
        if command -v less >/dev/null 2>&1; then
            less "$man_file"
        else
            cat "$man_file"
        fi
    else
        echo "❌ Page man pour '$func_name' non trouvée"
        echo ""
        echo "💡 Documentation disponible via: help $func_name"
    fi
}

# Alias man pour les fonctions personnalisées
man() {
    local cmd="$1"
    
    # Vérifier si c'est une fonction personnalisée
    if [ -f "$MAN_DIR/${cmd}.md" ]; then
        create_man_page "$cmd"
    else
        # Utiliser le man système normal
        command man "$@"
    fi
}

