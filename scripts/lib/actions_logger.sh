#!/bin/bash
# =============================================================================
# Actions Logger - Système de logs centralisé pour toutes les actions
# =============================================================================
# Description: Log toutes les actions utilisateur (alias, fonctions, etc.)
# Auteur: Paul Delhomme
# Version: 1.0
# =============================================================================

# Fichier de log principal
ACTIONS_LOG_FILE="${ACTIONS_LOG_FILE:-$HOME/dotfiles/actions.log}"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

################################################################################
# DESC: Assure que le fichier de log existe
# USAGE: ensure_actions_log_file
# RETURNS: 0 si succès
################################################################################
ensure_actions_log_file() {
    if [[ ! -f "$ACTIONS_LOG_FILE" ]]; then
        mkdir -p "$(dirname "$ACTIONS_LOG_FILE")"
        touch "$ACTIONS_LOG_FILE"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [init] [info] actions_logger | Fichier de log créé" >> "$ACTIONS_LOG_FILE"
    fi
}

################################################################################
# DESC: Log une action utilisateur
# USAGE: log_action <action_type> <component> <action> <status> <details>
# Args:
#   action_type: alias, function, path, config, etc.
#   component: Nom du composant (nom de l'alias, nom de la fonction, etc.)
#   action: add, remove, modify, execute, etc.
#   status: success, failed, skipped, info, warn, error
#   details: Détails supplémentaires
# EXAMPLES:
#   log_action "alias" "ll" "add" "success" "Ajouté via add_alias: ls -lah"
# RETURNS: 0 si succès
################################################################################
log_action() {
    ensure_actions_log_file
    local action_type="$1"
    local component="$2"
    local action="$3"
    local status="$4"
    local details="$5"
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$action_type] [$action] [$status] $component | $details" >> "$ACTIONS_LOG_FILE"
}

################################################################################
# DESC: Log une action d'alias
# USAGE: log_alias_action <name> <action> <status> <details>
# EXAMPLES:
#   log_alias_action "ll" "add" "success" "ls -lah"
# RETURNS: 0 si succès
################################################################################
log_alias_action() {
    log_action "alias" "$1" "$2" "$3" "$4"
}

################################################################################
# DESC: Log une action de fonction
# USAGE: log_function_action <name> <action> <status> <details>
# EXAMPLES:
#   log_function_action "myfunc" "execute" "success" "Avec arguments: arg1 arg2"
# RETURNS: 0 si succès
################################################################################
log_function_action() {
    log_action "function" "$1" "$2" "$3" "$4"
}

################################################################################
# DESC: Log une action PATH
# USAGE: log_path_action <path> <action> <status> <details>
# EXAMPLES:
#   log_path_action "/usr/local/bin" "add" "success" "Ajouté via pathman"
# RETURNS: 0 si succès
################################################################################
log_path_action() {
    log_action "path" "$1" "$2" "$3" "$4"
}

################################################################################
# DESC: Log une action de configuration
# USAGE: log_config_action <config_item> <action> <status> <details>
# EXAMPLES:
#   log_config_action "git.user.name" "set" "success" "PavelDelhomme"
# RETURNS: 0 si succès
################################################################################
log_config_action() {
    log_action "config" "$1" "$2" "$3" "$4"
}

################################################################################
# DESC: Affiche les logs d'actions avec filtres
# USAGE: show_actions_log [lines] [action_type] [component] [action]
# EXAMPLES:
#   show_actions_log 50
#   show_actions_log 100 "alias" "" "add"
# RETURNS: 0 si succès
################################################################################
show_actions_log() {
    ensure_actions_log_file
    local lines="${1:-50}"
    local filter_type="$2"
    local filter_component="$3"
    local filter_action="$4"
    
    local cmd="tail -n $lines \"$ACTIONS_LOG_FILE\""
    
    if [[ -n "$filter_type" ]]; then
        cmd="$cmd | grep \"\\[$filter_type\\]\""
    fi
    if [[ -n "$filter_component" ]]; then
        cmd="$cmd | grep \" $filter_component |\""
    fi
    if [[ -n "$filter_action" ]]; then
        cmd="$cmd | grep \"\\[$filter_action\\]\""
    fi
    
    echo -e "${BLUE}═══════════════════════════════════${RESET}"
    echo -e "${BLUE}Logs d'actions (dernières $lines lignes)${RESET}"
    echo -e "${BLUE}═══════════════════════════════════${RESET}"
    eval "$cmd" | less -R
}

################################################################################
# DESC: Obtient un résumé des actions
# USAGE: get_actions_summary [action_type]
# EXAMPLES:
#   get_actions_summary
#   get_actions_summary "alias"
# RETURNS: 0 si succès
################################################################################
get_actions_summary() {
    ensure_actions_log_file
    local filter_type="$1"
    
    local cmd="grep"
    if [[ -n "$filter_type" ]]; then
        cmd="$cmd \"\\[$filter_type\\]\""
    fi
    
    cmd="$cmd \"$ACTIONS_LOG_FILE\""
    
    local total=$(eval "$cmd" | wc -l)
    local success=$(eval "$cmd | grep \"\\[success\\]\" | wc -l")
    local failed=$(eval "$cmd | grep \"\\[failed\\]\" | wc -l")
    local skipped=$(eval "$cmd | grep \"\\[skipped\\]\" | wc -l")
    
    echo -e "${BLUE}═══════════════════════════════════${RESET}"
    if [[ -n "$filter_type" ]]; then
        echo -e "${BLUE}Résumé des actions ($filter_type)${RESET}"
    else
        echo -e "${BLUE}Résumé des actions${RESET}"
    fi
    echo -e "${BLUE}═══════════════════════════════════${RESET}"
    echo -e "Total des actions: $total"
    echo -e "${GREEN}  Réussies: $success${RESET}"
    echo -e "${RED}  Échouées: $failed${RESET}"
    echo -e "${YELLOW}  Ignorées: $skipped${RESET}"
}

################################################################################
# DESC: Recherche dans les logs d'actions
# USAGE: search_actions_log <search_term>
# EXAMPLES:
#   search_actions_log "ll"
#   search_actions_log "add"
# RETURNS: 0 si succès
################################################################################
search_actions_log() {
    local search_term="$1"
    
    if [[ -z "$search_term" ]]; then
        echo "❌ Usage: search_actions_log <search_term>"
        return 1
    fi
    
    ensure_actions_log_file
    echo -e "${BLUE}Recherche: '$search_term'${RESET}"
    echo -e "${BLUE}═══════════════════════════════════${RESET}"
    grep -i "$search_term" "$ACTIONS_LOG_FILE" | less -R
}

################################################################################
# DESC: Affiche les dernières actions
# USAGE: get_recent_actions [count] [action_type]
# EXAMPLES:
#   get_recent_actions 10
#   get_recent_actions 20 "alias"
# RETURNS: 0 si succès
################################################################################
get_recent_actions() {
    local count="${1:-10}"
    local filter_type="$2"
    
    ensure_actions_log_file
    
    local cmd="tail -n $count \"$ACTIONS_LOG_FILE\""
    if [[ -n "$filter_type" ]]; then
        cmd="$cmd | grep \"\\[$filter_type\\]\""
    fi
    
    echo -e "${BLUE}═══════════════════════════════════${RESET}"
    if [[ -n "$filter_type" ]]; then
        echo -e "${BLUE}Dernières $count actions ($filter_type)${RESET}"
    else
        echo -e "${BLUE}Dernières $count actions${RESET}"
    fi
    echo -e "${BLUE}═══════════════════════════════════${RESET}"
    eval "$cmd" | less -R
}

################################################################################
# DESC: Statistiques par type d'action
# USAGE: get_actions_stats [action_type]
# EXAMPLES:
#   get_actions_stats
#   get_actions_stats "alias"
# RETURNS: 0 si succès
################################################################################
get_actions_stats() {
    local filter_type="$1"
    
    ensure_actions_log_file
    
    echo -e "${BLUE}═══════════════════════════════════${RESET}"
    echo -e "${BLUE}Statistiques des actions${RESET}"
    echo -e "${BLUE}═══════════════════════════════════${RESET}"
    
    if [[ -n "$filter_type" ]]; then
        local cmd="grep \"\\[$filter_type\\]\" \"$ACTIONS_LOG_FILE\""
        eval "$cmd" | awk -F'|' '{print $1}' | awk '{print $2}' | sort | uniq -c | sort -rn
    else
        # Statistiques par type
        echo -e "\n${CYAN}Par type d'action:${RESET}"
        awk -F']' '{print $2}' "$ACTIONS_LOG_FILE" | awk -F'[' '{print $2}' | sort | uniq -c | sort -rn | head -10
        
        # Statistiques par action
        echo -e "\n${CYAN}Par action:${RESET}"
        awk -F']' '{print $3}' "$ACTIONS_LOG_FILE" | awk -F'[' '{print $2}' | sort | uniq -c | sort -rn | head -10
    fi
}

# S'assurer que le fichier de log existe au chargement
ensure_actions_log_file

