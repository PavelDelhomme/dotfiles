#!/bin/zsh
# =============================================================================
# AUTO SAVE HELPER - Helper pour enregistrer automatiquement les résultats
# =============================================================================
# Description: Fonction helper pour enregistrer automatiquement les résultats
#              des tests dans l'environnement actif
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger le gestionnaire d'environnements
CYBER_DIR="${CYBER_DIR:-$HOME/dotfiles/zsh/functions/cyberman/modules/legacy}"
if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
    source "$CYBER_DIR/environment_manager.sh" 2>/dev/null
fi

# DESC: Enregistre automatiquement un résultat dans l'environnement actif
# USAGE: auto_save_recon_result <action_type> <description> <result_data> [status]
# EXAMPLE: auto_save_recon_result "whois" "WHOIS lookup" "Domain info..." "success"
auto_save_recon_result() {
    local action_type="$1"
    local description="$2"
    local result_data="$3"
    local status="${4:-success}"
    
    if [ -z "$action_type" ] || [ -z "$description" ]; then
        return 1
    fi
    
    # Vérifier si un environnement est actif
    if [ -z "${CYBER_CURRENT_ENV+x}" ] || [ -z "$CYBER_CURRENT_ENV" ]; then
        # Essayer de charger l'environnement manager pour vérifier
        if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
            source "$CYBER_DIR/environment_manager.sh" 2>/dev/null
            if type has_active_environment >/dev/null 2>&1 && has_active_environment 2>/dev/null; then
                CYBER_CURRENT_ENV=$(get_current_environment 2>/dev/null)
            fi
        fi
        if [ -z "${CYBER_CURRENT_ENV+x}" ] || [ -z "$CYBER_CURRENT_ENV" ]; then
            return 0  # Pas d'erreur, juste pas d'environnement actif
        fi
    fi
    
    # S'assurer que les fonctions sont chargées
    if ! command -v add_environment_action >/dev/null 2>&1; then
        if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
            source "$CYBER_DIR/environment_manager.sh" 2>/dev/null
        fi
    fi
    
    # Enregistrer l'action et le résultat
    if command -v add_environment_action >/dev/null 2>&1; then
        # Limiter la taille du résultat pour éviter les problèmes
        local result_preview=$(echo "$result_data" | head -100 | tr '\n' ' ' | cut -c1-500)
        add_environment_action "$CYBER_CURRENT_ENV" "$action_type" "$description" "$result_preview" 2>/dev/null
        add_environment_result "$CYBER_CURRENT_ENV" "${action_type}_$(date +%s)" "$result_data" "$status" 2>/dev/null
        # Ne pas afficher le message ici, laisser la fonction appelante le faire
    fi
    
    return 0
}

