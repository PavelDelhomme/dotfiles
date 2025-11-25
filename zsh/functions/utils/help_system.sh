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
# DESC: Affiche l'aide détaillée pour une fonction spécifique en extrayant la documentation depuis les commentaires.
# USAGE: show_function_help <function_name>
# EXAMPLE: show_function_help extract
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
# DESC: Liste toutes les fonctions personnalisées disponibles avec leurs descriptions, organisées par catégories.
# USAGE: list_functions
# EXAMPLE: list_functions
list_functions() {
    # Utiliser le script Python pour un affichage correct
    local python_script="$DOTFILES_DIR/zsh/functions/utils/list_functions.py"
    
    if [ -f "$python_script" ] && command -v python3 >/dev/null 2>&1; then
        export DOTFILES_DIR COLUMNS
        python3 "$python_script"
    else
        # Fallback vers la version shell si Python n'est pas disponible
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📋 FONCTIONS DISPONIBLES"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "⚠️  Python3 requis pour l'affichage organisé par catégories"
        echo "💡 Installez Python3 ou utilisez: help <nom_fonction>"
        echo ""
    fi
}

# Fonction help principale
# DESC: Système d'aide principal. Liste toutes les fonctions ou affiche l'aide pour une fonction spécifique.
# USAGE: help [function_name]
# EXAMPLE: help extract
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
# DESC: Affiche la page man pour une fonction personnalisée ou utilise le man système pour les commandes standards.
# USAGE: man <function_or_command>
# EXAMPLE: man extract
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
