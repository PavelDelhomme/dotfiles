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
# DESC: Liste toutes les fonctions personnalisées disponibles avec leurs descriptions.
# USAGE: list_functions
# EXAMPLE: list_functions
list_functions() {
    # Obtenir la largeur du terminal (par défaut 80)
    local term_width=${COLUMNS:-80}
    if [ "$term_width" -lt 60 ]; then
        term_width=80
    fi
    local desc_max_width=$((term_width - 45))  # Réserver 45 caractères pour le nom de fonction
    
    # Fonction pour tronquer une description
    truncate_desc() {
        local text="$1"
        local max_len="$2"
        local text_len=${#text}
        if [ "$text_len" -gt "$max_len" ]; then
            echo "${text:0:$((max_len - 3))}..."
        else
            echo "$text"
        fi
    }
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 FONCTIONS DISPONIBLES (organisées par catégories)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Créer un fichier temporaire pour stocker les fonctions par catégorie
    local temp_file=$(mktemp)
    
    # Parcourir tous les fichiers de fonctions et collecter les données
    find "$DOTFILES_DIR/zsh/functions" -type f \( -name "*.sh" -o -name "*.zsh" \) 2>/dev/null | while read -r file; do
        # Déterminer la catégorie à partir du chemin du fichier
        local relative_path="${file#$DOTFILES_DIR/zsh/functions/}"
        local category=""
        
        # Extraire la catégorie (dossier/sous-dossier)
        if echo "$relative_path" | grep -q "/"; then
            # Extraire le premier niveau (dossier)
            category=$(echo "$relative_path" | cut -d'/' -f1)
            # Si c'est un sous-dossier, inclure le sous-dossier aussi
            if echo "$relative_path" | grep -qE "^[^/]+/[^/]+/"; then
                category=$(echo "$relative_path" | cut -d'/' -f1-2)
            fi
        else
            # Fichiers à la racine (comme les *man.zsh)
            category="gestionnaires"
        fi
        
        # Nettoyer le nom de catégorie
        category=$(echo "$category" | sed 's/\.zsh$//' | sed 's/\.sh$//')
        
        # Extraire les fonctions du fichier
        grep -E "^[a-zA-Z_][a-zA-Z0-9_]*\s*\(\)|^function [a-zA-Z_]" "$file" 2>/dev/null | while read -r line; do
            local func_name=$(echo "$line" | sed -E 's/^(function )?([a-zA-Z_][a-zA-Z0-9_]*)\(.*/\2/')
            # Ignorer les fonctions système
            if [ -z "$func_name" ] || echo "$func_name" | grep -qE "^(if|for|while|case|function)$"; then
                continue
            fi
            # Extraire la description (première ligne DESC trouvée pour cette fonction)
            local desc=$(grep -E "^#\s*DESC:" "$file" | head -1 | sed 's/^#\s*DESC:\s*//')
            
            if [ -n "$func_name" ]; then
                echo "$category|$func_name|$desc" >> "$temp_file"
            fi
        done
    done
    
    # Supprimer les doublons (même fonction dans plusieurs fichiers)
    sort -t'|' -k2 -u "$temp_file" > "${temp_file}.sorted" && mv "${temp_file}.sorted" "$temp_file"
    
    # Définir l'ordre d'affichage des catégories avec sous-catégories cyber
    local category_order="gestionnaires misc/system misc/clipboard misc/files misc/backup misc/security dev/go dev/docker dev/c dev/make dev/projects cyber/reconnaissance cyber/scanning cyber/vulnerability cyber/attacks cyber/analysis cyber/privacy git utils"
    
    # Afficher les catégories dans l'ordre défini
    for cat in $category_order; do
        # Extraire les fonctions de cette catégorie
        local funcs_in_cat=$(grep "^${cat}|" "$temp_file" 2>/dev/null | sort -t'|' -k2)
        
        if [ -n "$funcs_in_cat" ]; then
            # Formater le nom de catégorie pour l'affichage
            local display_name="$cat"
            case "$cat" in
                "gestionnaires")
                    display_name="🎛️  GESTIONNAIRES (Managers)"
                    ;;
                "misc/system")
                    display_name="💻 SYSTÈME (System)"
                    ;;
                "misc/clipboard")
                    display_name="📋 PRESSE-PAPIER (Clipboard)"
                    ;;
                "misc/files")
                    display_name="📁 FICHIERS (Files)"
                    ;;
                "misc/backup")
                    display_name="💾 SAUVEGARDE (Backup)"
                    ;;
                "misc/security")
                    display_name="🔒 SÉCURITÉ (Security)"
                    ;;
                "dev/go")
                    display_name="🐹 GO (Go Language)"
                    ;;
                "dev/docker")
                    display_name="🐳 DOCKER (Docker)"
                    ;;
                "dev/c")
                    display_name="⚙️  C/C++ (C/C++)"
                    ;;
                "dev/make")
                    display_name="🔨 MAKE (Make)"
                    ;;
                "dev/projects")
                    display_name="📦 PROJETS (Projects)"
                    ;;
                "cyber/reconnaissance")
                    display_name="🛡️  CYBER / RECONNAISSANCE"
                    ;;
                "cyber/scanning")
                    display_name="🛡️  CYBER / SCANNING"
                    ;;
                "cyber/vulnerability")
                    display_name="🛡️  CYBER / VULNERABILITY"
                    ;;
                "cyber/attacks")
                    display_name="🛡️  CYBER / ATTACKS"
                    ;;
                "cyber/analysis")
                    display_name="🛡️  CYBER / ANALYSIS"
                    ;;
                "cyber/privacy")
                    display_name="🛡️  CYBER / PRIVACY"
                    ;;
                "cyber")
                    display_name="🛡️  CYBERSÉCURITÉ (Cybersecurity)"
                    ;;
                "git")
                    display_name="🔀 GIT (Git)"
                    ;;
                "utils")
                    display_name="🛠️  UTILITAIRES (Utils)"
                    ;;
                *)
                    # Formater automatiquement les catégories non listées
                    display_name=$(echo "$cat" | sed 's|/| / |g' | tr '[:lower:]' '[:upper:]')
                    display_name="📂 $display_name"
                    ;;
            esac
            
            # Afficher l'en-tête de catégorie
            echo "$display_name"
            echo "──────────────────────────────────────────────────────────────────────────"
            
            # Afficher les fonctions de cette catégorie
            echo "$funcs_in_cat" | while IFS='|' read -r cat_name func_name desc; do
                if [ -z "$func_name" ]; then
                    continue
                fi
                # Tronquer la description si nécessaire
                local short_desc=""
                if [ -n "$desc" ]; then
                    short_desc=$(truncate_desc "$desc" "$desc_max_width")
                fi
                printf "  • %-30s" "$func_name"
                if [ -n "$short_desc" ]; then
                    echo " - $short_desc"
                else
                    echo ""
                fi
            done
            
            echo ""
            # Retirer cette catégorie du fichier temporaire pour éviter les doublons
            grep -v "^${cat}|" "$temp_file" > "${temp_file}.new" 2>/dev/null && mv "${temp_file}.new" "$temp_file" 2>/dev/null || true
        fi
    done
    
    # Afficher les catégories restantes (non listées dans l'ordre)
    if [ -s "$temp_file" ]; then
        local remaining_cats=$(cut -d'|' -f1 "$temp_file" | sort -u)
        for cat in $remaining_cats; do
            local display_cat=$(echo "$cat" | sed 's|/| / |g' | tr '[:lower:]' '[:upper:]')
            echo "📂 $display_cat"
            echo "──────────────────────────────────────────────────────────────────────────"
            
            grep "^${cat}|" "$temp_file" | sort -t'|' -k2 | while IFS='|' read -r cat_name func_name desc; do
                if [ -z "$func_name" ]; then
                    continue
                fi
                local short_desc=""
                if [ -n "$desc" ]; then
                    short_desc=$(truncate_desc "$desc" "$desc_max_width")
                fi
                printf "  • %-30s" "$func_name"
                if [ -n "$short_desc" ]; then
                    echo " - $short_desc"
                else
                    echo ""
                fi
            done
            
            echo ""
        done
    fi
    
    rm -f "$temp_file"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "💡 Utilisez 'help <nom_fonction>' pour obtenir l'aide détaillée"
    echo "💡 Utilisez 'man <nom_fonction>' pour la documentation complète"
    echo ""
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

