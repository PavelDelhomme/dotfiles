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

# Répertoires de base
HELPMAN_DIR="${HELPMAN_DIR:-$HOME/dotfiles/zsh/functions/helpman}"
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
    
    # S'assurer que DOTFILES_DIR est défini
    if [ -z "$DOTFILES_DIR" ]; then
        DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    fi
    
    # S'assurer que COLUMNS est défini
    if [ -z "$COLUMNS" ]; then
        COLUMNS=$(tput cols 2>/dev/null || echo "80")
    fi
    
    if [ -f "$python_script" ] && command -v python3 >/dev/null 2>&1; then
        # Exporter les variables nécessaires
        export DOTFILES_DIR COLUMNS
        # Exécuter le script Python
        python3 "$python_script" 2>&1
    else
        # Fallback vers la version shell si Python n'est pas disponible
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📋 FONCTIONS DISPONIBLES"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        if ! command -v python3 >/dev/null 2>&1; then
            echo "⚠️  Python3 requis pour l'affichage organisé par catégories"
            echo "💡 Installez Python3 ou utilisez: help <nom_fonction>"
        else
            echo "⚠️  Script list_functions.py introuvable: $python_script"
        fi
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

# Fonction pour afficher une page man depuis un fichier Markdown
create_man_page() {
    local func_name="$1"
    local man_file="$MAN_DIR/${func_name}.md"
    
    if [ ! -f "$man_file" ]; then
        echo "❌ Page man pour '$func_name' non trouvée"
        echo ""
        echo "💡 Documentation disponible via: help $func_name"
        echo "💡 Générer la page man: make generate-man"
        return 1
    fi
    
    # Configurer l'encodage UTF-8
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    
    # Essayer différentes méthodes d'affichage selon les outils disponibles
    
    # Méthode 1: bat pour afficher avec coloration Markdown (MEILLEUR CHOIX)
    if command -v bat >/dev/null 2>&1; then
        # bat supporte nativement UTF-8 et Markdown avec couleurs
        bat --style=plain --color=always --language=markdown "$man_file" 2>/dev/null || \
        bat --plain --language=markdown "$man_file"
        return 0
    fi
    
    # Méthode 2: glow pour afficher Markdown (excellent pour UTF-8 et couleurs)
    if command -v glow >/dev/null 2>&1; then
        glow "$man_file" 2>/dev/null
        return 0
    fi
    
    # Méthode 3: mdcat pour afficher Markdown (bon support UTF-8)
    if command -v mdcat >/dev/null 2>&1; then
        mdcat "$man_file" 2>/dev/null
        return 0
    fi
    
    # Méthode 4: pandoc + groff avec support UTF-8
    if command -v pandoc >/dev/null 2>&1 && command -v groff >/dev/null 2>&1; then
        # Forcer UTF-8 dans la conversion
        pandoc -s -f markdown -t man "$man_file" 2>/dev/null | \
        groff -T utf8 -man -P -c 2>/dev/null | \
        less -R -r
        return 0
    fi
    
    # Méthode 5: pygmentize avec less pour coloration et UTF-8
    if command -v pygmentize >/dev/null 2>&1 && command -v less >/dev/null 2>&1; then
        # Forcer UTF-8 et coloration
        export PYTHONIOENCODING=utf-8
        pygmentize -l markdown -f terminal256 -O style=monokai "$man_file" 2>/dev/null | \
        less -R -r || \
        pygmentize -l markdown "$man_file" 2>/dev/null | less -R -r
        return 0
    fi
    
    # Méthode 6: source-highlight avec less
    if command -v source-highlight >/dev/null 2>&1 && command -v less >/dev/null 2>&1; then
        source-highlight -s md -f esc256 -i "$man_file" 2>/dev/null | less -R -r
        return 0
    fi
    
    # Méthode 7: Script Python personnalisé (fallback avec UTF-8 et couleurs)
    local python_viewer="$DOTFILES_DIR/zsh/functions/utils/markdown_viewer.py"
    if [ -f "$python_viewer" ] && command -v python3 >/dev/null 2>&1; then
        python3 "$python_viewer" "$man_file" 2>/dev/null
        return 0
    fi
    
    # Méthode 8: less avec UTF-8 forcé
    if command -v less >/dev/null 2>&1; then
        # Forcer UTF-8 et couleurs si disponibles
        export LESSCHARSET=utf-8
        export LESS=-R
        less "$man_file" 2>/dev/null || \
        LESSCHARSET=utf-8 less "$man_file"
        return 0
    fi
    
    # Méthode 9: cat avec UTF-8 (dernier recours)
    # Forcer UTF-8 dans l'environnement
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    cat "$man_file"
}

# Alias man pour les fonctions personnalisées
# DESC: Affiche la page man pour une fonction personnalisée ou utilise le man système pour les commandes standards.
# USAGE: man <function_or_command>
# EXAMPLE: man extract
man() {
    local cmd="$1"
    
    if [ -z "$cmd" ]; then
        echo "❌ Usage: man <function_or_command>"
        echo ""
        echo "💡 Exemples:"
        echo "  man extract       - Documentation de la fonction extract"
        echo "  man ls            - Page man système pour ls"
        return 1
    fi
    
    # Vérifier si c'est une fonction personnalisée
    if [ -f "$MAN_DIR/${cmd}.md" ]; then
        create_man_page "$cmd"
    else
        # Utiliser le man système normal
        command man "$@"
    fi
}
