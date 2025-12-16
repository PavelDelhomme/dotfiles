#!/bin/sh
# =============================================================================
# Utilitaires de gestion des alias (fonctions standalone) - Version POSIX
# =============================================================================
# Description: Fonctions pour gérer les alias en ligne de commande (POSIX)
# Auteur: Paul Delhomme
# Version: 2.0 - POSIX Compliant
# =============================================================================

# Variables globales
export ALIASES_FILE="${ALIASES_FILE:-$HOME/dotfiles/zsh/aliases.zsh}"
export ALIASES_DOC_FILE="${ALIASES_DOC_FILE:-$HOME/dotfiles/zsh/aliases_doc.json}"

# Charger le système de logs
if [ -f "$HOME/dotfiles/scripts/lib/actions_logger.sh" ]; then
    . "$HOME/dotfiles/scripts/lib/actions_logger.sh" 2>/dev/null || true
else
    log_alias_action() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [alias] [$2] [$3] $1 | $4" >> "$HOME/dotfiles/logs/actions.log"
    }
fi

################################################################################
# DESC: Ajoute un nouvel alias avec documentation optionnelle
# USAGE: add_alias <name> <command> [description] [usage] [examples]
# EXAMPLE: add_alias ll "ls -lah" "Liste détaillée" "ll" "ll -R"
# RETURNS: 0 si succès, 1 si erreur
################################################################################
add_alias() {
    local name="$1"
    local command="$2"
    local description="${3:-}"
    local usage="${4:-}"
    local examples="${5:-}"
    
    if [ -z "$name" ] || [ -z "$command" ]; then
        echo "❌ Usage: add_alias <name> <command> [description] [usage] [examples]"
        return 1
    fi
    
    # Vérifier si l'alias existe déjà
    if grep -q "^alias $name=" "$ALIASES_FILE" 2>/dev/null; then
        echo "⚠️  L'alias '$name' existe déjà. Utilisez change_alias pour le modifier."
        return 1
    fi
    
    # Créer le fichier s'il n'existe pas
    if [ ! -f "$ALIASES_FILE" ]; then
        mkdir -p "$(dirname "$ALIASES_FILE")"
        echo "# ~/dotfiles/zsh/aliases.zsh - Fichier des alias ZSH" > "$ALIASES_FILE"
        echo "# Géré par ALIAS_UTILS - Fonctions de gestion d'alias" >> "$ALIASES_FILE"
        echo >> "$ALIASES_FILE"
    fi
    
    # Ajouter la documentation si fournie
    if [ -n "$description" ] || [ -n "$usage" ] || [ -n "$examples" ]; then
        echo "# DESC: $description" >> "$ALIASES_FILE"
        [ -n "$usage" ] && echo "# USAGE: $usage" >> "$ALIASES_FILE"
        [ -n "$examples" ] && echo "# EXAMPLES: $examples" >> "$ALIASES_FILE"
    fi
    
    # Ajouter l'alias
    echo "alias $name=\"$command\"" >> "$ALIASES_FILE"
    
    # Activer l'alias dans la session courante (si supporté)
    if [ -n "$ZSH_VERSION" ] || [ -n "$BASH_VERSION" ]; then
        alias "$name"="$command" 2>/dev/null || true
    fi
    
    # Logger l'action
    log_alias_action "$name" "add" "success" "Ajouté via add_alias: $command"
    
    echo "✅ Alias '$name' ajouté"
    return 0
}

################################################################################
# DESC: Supprime un alias
# USAGE: remove_alias <name>
# EXAMPLE: remove_alias ll
# RETURNS: 0 si succès, 1 si erreur
################################################################################
remove_alias() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo "❌ Usage: remove_alias <name>"
        return 1
    fi
    
    if ! grep -q "^alias $name=" "$ALIASES_FILE" 2>/dev/null; then
        echo "❌ Alias '$name' non trouvé"
        return 1
    fi
    
    # Sauvegarder avant suppression
    local backup_dir="$HOME/dotfiles/zsh/backups"
    mkdir -p "$backup_dir"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    cp "$ALIASES_FILE" "$backup_dir/aliases_backup_$timestamp.zsh" 2>/dev/null || true
    
    # Supprimer l'alias et sa documentation (POSIX-compatible sed)
    if command -v sed >/dev/null 2>&1; then
        # Supprimer la documentation et l'alias
        sed -i.tmp "/^# DESC:.*$name/,/^alias $name=/d" "$ALIASES_FILE" 2>/dev/null || true
        sed -i.tmp "/^# USAGE:.*$name/d" "$ALIASES_FILE" 2>/dev/null || true
        sed -i.tmp "/^# EXAMPLES:.*$name/d" "$ALIASES_FILE" 2>/dev/null || true
        sed -i.tmp "/^alias $name=/d" "$ALIASES_FILE" 2>/dev/null || true
        rm -f "$ALIASES_FILE.tmp" 2>/dev/null || true
    fi
    
    # Désactiver l'alias dans la session courante (si supporté)
    if [ -n "$ZSH_VERSION" ] || [ -n "$BASH_VERSION" ]; then
        unalias "$name" 2>/dev/null || true
    fi
    
    # Logger l'action
    log_alias_action "$name" "remove" "success" "Supprimé via remove_alias"
    
    echo "✅ Alias '$name' supprimé"
    return 0
}

################################################################################
# DESC: Modifie un alias existant
# USAGE: change_alias <name> <new_command> [new_description] [new_usage] [new_examples]
# EXAMPLE: change_alias ll "ls -lahR" "Liste détaillée récursive"
# RETURNS: 0 si succès, 1 si erreur
################################################################################
change_alias() {
    local name="$1"
    local new_command="$2"
    local new_description="${3:-}"
    local new_usage="${4:-}"
    local new_examples="${5:-}"
    
    if [ -z "$name" ] || [ -z "$new_command" ]; then
        echo "❌ Usage: change_alias <name> <new_command> [new_description] [new_usage] [new_examples]"
        return 1
    fi
    
    if ! grep -q "^alias $name=" "$ALIASES_FILE" 2>/dev/null; then
        echo "⚠️  Alias '$name' non trouvé. Utilisez add_alias pour le créer."
        return 1
    fi
    
    # Sauvegarder avant modification
    local backup_dir="$HOME/dotfiles/zsh/backups"
    mkdir -p "$backup_dir"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    cp "$ALIASES_FILE" "$backup_dir/aliases_backup_$timestamp.zsh" 2>/dev/null || true
    
    # Supprimer l'ancien alias et sa documentation
    if command -v sed >/dev/null 2>&1; then
        sed -i.tmp "/^# DESC:.*$name/,/^alias $name=/d" "$ALIASES_FILE" 2>/dev/null || true
        sed -i.tmp "/^# USAGE:.*$name/d" "$ALIASES_FILE" 2>/dev/null || true
        sed -i.tmp "/^# EXAMPLES:.*$name/d" "$ALIASES_FILE" 2>/dev/null || true
        sed -i.tmp "/^alias $name=/d" "$ALIASES_FILE" 2>/dev/null || true
        rm -f "$ALIASES_FILE.tmp" 2>/dev/null || true
    fi
    
    # Ajouter la nouvelle documentation si fournie
    if [ -n "$new_description" ] || [ -n "$new_usage" ] || [ -n "$new_examples" ]; then
        echo "# DESC: $new_description" >> "$ALIASES_FILE"
        [ -n "$new_usage" ] && echo "# USAGE: $new_usage" >> "$ALIASES_FILE"
        [ -n "$new_examples" ] && echo "# EXAMPLES: $new_examples" >> "$ALIASES_FILE"
    fi
    
    # Ajouter le nouvel alias
    echo "alias $name=\"$new_command\"" >> "$ALIASES_FILE"
    
    # Mettre à jour l'alias dans la session courante (si supporté)
    if [ -n "$ZSH_VERSION" ] || [ -n "$BASH_VERSION" ]; then
        alias "$name"="$new_command" 2>/dev/null || true
    fi
    
    # Logger l'action
    log_alias_action "$name" "modify" "success" "Modifié via change_alias: $new_command"
    
    echo "✅ Alias '$name' modifié"
    return 0
}

################################################################################
# DESC: Liste tous les alias avec leurs descriptions
# USAGE: list_alias [search_term]
# EXAMPLE: list_alias
# EXAMPLE: list_alias git
# RETURNS: 0 si succès
################################################################################
list_alias() {
    local search_term="${1:-}"
    
    if [ ! -f "$ALIASES_FILE" ]; then
        echo "❌ Fichier d'alias non trouvé: $ALIASES_FILE"
        return 1
    fi
    
    echo "📋 Liste des alias:"
    echo "────────────────────────────────────────────────────────────────"
    
    local current_desc=""
    local current_usage=""
    local current_examples=""
    
    while IFS= read -r line; do
        # Détecter la description
        case "$line" in
            "# DESC: "*)
                current_desc="${line#\# DESC: }"
                ;;
            "# USAGE: "*)
                current_usage="${line#\# USAGE: }"
                ;;
            "# EXAMPLES: "*)
                current_examples="${line#\# EXAMPLES: }"
                ;;
            "alias "*=*)
                # Extraire le nom et la commande de l'alias
                alias_line="${line#alias }"
                alias_name="${alias_line%%=*}"
                alias_command="${alias_line#*=}"
                alias_command="${alias_command#\"}"
                alias_command="${alias_command%\"}"
                
                # Filtrer par terme de recherche si fourni
                if [ -z "$search_term" ] || \
                   echo "$alias_name" | grep -q "$search_term" 2>/dev/null || \
                   echo "$alias_command" | grep -q "$search_term" 2>/dev/null || \
                   echo "$current_desc" | grep -q "$search_term" 2>/dev/null; then
                    
                    printf "\n%s%-20s%s %s\n" "$CYAN" "$alias_name" "$RESET" "$alias_command"
                    [ -n "$current_desc" ] && printf "  %sDescription:%s %s\n" "$YELLOW" "$RESET" "$current_desc"
                    [ -n "$current_usage" ] && printf "  %sUsage:%s %s\n" "$BLUE" "$RESET" "$current_usage"
                    [ -n "$current_examples" ] && printf "  %sExemples:%s %s\n" "$GREEN" "$RESET" "$current_examples"
                fi
                
                current_desc=""
                current_usage=""
                current_examples=""
                ;;
        esac
    done < "$ALIASES_FILE"
    
    return 0
}

################################################################################
# DESC: Recherche un alias par nom, commande ou description
# USAGE: search_alias <search_term>
# EXAMPLE: search_alias git
# EXAMPLE: search_alias "liste détaillée"
# RETURNS: 0 si trouvé, 1 si non trouvé
################################################################################
search_alias() {
    local search_term="$1"
    
    if [ -z "$search_term" ]; then
        echo "❌ Usage: search_alias <search_term>"
        return 1
    fi
    
    list_alias "$search_term"
}

################################################################################
# DESC: Affiche la documentation complète d'un alias
# USAGE: get_alias_doc <name>
# EXAMPLE: get_alias_doc ll
# RETURNS: 0 si trouvé, 1 si non trouvé
################################################################################
get_alias_doc() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo "❌ Usage: get_alias_doc <name>"
        return 1
    fi
    
    if ! grep -q "^alias $name=" "$ALIASES_FILE" 2>/dev/null; then
        echo "❌ Alias '$name' non trouvé"
        return 1
    fi
    
    echo "📖 Documentation de l'alias: ${CYAN}$name${RESET}"
    echo "────────────────────────────────────────────────────────────────"
    
    # Trouver la ligne de l'alias
    alias_line=$(grep -n "^alias $name=" "$ALIASES_FILE" | head -1 | cut -d: -f1)
    
    if [ -z "$alias_line" ]; then
        return 1
    fi
    
    # Extraire la commande
    alias_command=$(sed -n "${alias_line}p" "$ALIASES_FILE" | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/')
    echo "${YELLOW}Commande:${RESET} $alias_command"
    
    # Chercher la documentation précédente
    desc_line=$((alias_line - 3))
    usage_line=$((alias_line - 2))
    examples_line=$((alias_line - 1))
    
    description=$(sed -n "${desc_line}p" "$ALIASES_FILE" 2>/dev/null | grep "^# DESC:" | sed 's/^# DESC: //')
    usage=$(sed -n "${usage_line}p" "$ALIASES_FILE" 2>/dev/null | grep "^# USAGE:" | sed 's/^# USAGE: //')
    examples=$(sed -n "${examples_line}p" "$ALIASES_FILE" 2>/dev/null | grep "^# EXAMPLES:" | sed 's/^# EXAMPLES: //')
    
    [ -n "$description" ] && echo "${YELLOW}Description:${RESET} $description"
    [ -n "$usage" ] && echo "${BLUE}Usage:${RESET} $usage"
    [ -n "$examples" ] && echo "${GREEN}Exemples:${RESET} $examples"
    
    # Vérifier si actif (seulement pour ZSH/Bash)
    if [ -n "$ZSH_VERSION" ] || [ -n "$BASH_VERSION" ]; then
        if alias "$name" >/dev/null 2>&1; then
            echo "${GREEN}État: Actif${RESET}"
        else
            echo "${RED}État: Inactif${RESET}"
        fi
    fi
    
    return 0
}

################################################################################
# DESC: Navigue dans la documentation des alias de manière interactive
# USAGE: browse_alias_doc [category]
# EXAMPLE: browse_alias_doc
# EXAMPLE: browse_alias_doc git
# RETURNS: 0
################################################################################
browse_alias_doc() {
    local category="${1:-}"
    
    if [ ! -f "$ALIASES_FILE" ]; then
        echo "❌ Fichier d'alias non trouvé"
        return 1
    fi
    
    echo "📚 Navigation dans la documentation des alias"
    echo "────────────────────────────────────────────────────────────────"
    
    # Compter les alias avec documentation
    aliases_with_doc=0
    total_aliases=0
    
    while IFS= read -r line; do
        case "$line" in
            "alias "*=*)
                total_aliases=$((total_aliases + 1))
                alias_line="${line#alias }"
                alias_name="${alias_line%%=*}"
                prev_line=$(grep -B1 "^alias $alias_name=" "$ALIASES_FILE" | head -1)
                case "$prev_line" in
                    "# DESC: "*)
                        aliases_with_doc=$((aliases_with_doc + 1))
                        ;;
                esac
                ;;
        esac
    done < "$ALIASES_FILE"
    
    echo "Total alias: $total_aliases"
    echo "Avec documentation: $aliases_with_doc"
    echo
    
    if [ -n "$category" ]; then
        echo "Recherche dans catégorie: $category"
        list_alias "$category" | less -R
    else
        list_alias | less -R
    fi
    
    return 0
}

# Couleurs pour l'affichage
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RESET='\033[0m'

