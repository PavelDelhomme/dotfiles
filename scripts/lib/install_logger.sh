#!/bin/bash

################################################################################
# Système de logs d'installation pour dotfiles
# Trace toutes les installations, configurations et actions
################################################################################

INSTALL_LOG_FILE="${DOTFILES_DIR:-$HOME/dotfiles}/install.log"

# Fonction pour logger une action
log_install_action() {
    local action="$1"      # "install", "config", "uninstall", "test", etc.
    local component="$2"   # Nom du composant
    local status="$3"      # "success", "failed", "skipped", "info"
    local details="$4"     # Détails supplémentaires (optionnel)
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [$action] [$status] $component"
    
    if [ -n "$details" ]; then
        log_entry="$log_entry | $details"
    fi
    
    echo "$log_entry" >> "$INSTALL_LOG_FILE"
    
    # Afficher dans la console si demandé
    case "$status" in
        success)
            echo -e "${GREEN}[✓]${NC} $component - $action - $status"
            ;;
        failed)
            echo -e "${RED}[✗]${NC} $component - $action - $status"
            ;;
        skipped)
            echo -e "${YELLOW}[→]${NC} $component - $action - $status"
            ;;
        info)
            echo -e "${BLUE}[ℹ]${NC} $component - $action - $details"
            ;;
    esac
}

# Fonction pour afficher les logs avec pagination
show_install_logs() {
    local filter="${1:-}"  # Filtrer par action ou composant (optionnel)
    local lines="${2:-50}"  # Nombre de lignes à afficher (défaut: 50)
    
    if [ ! -f "$INSTALL_LOG_FILE" ]; then
        echo "Aucun log d'installation trouvé."
        return 1
    fi
    
    if [ -z "$filter" ]; then
        tail -n "$lines" "$INSTALL_LOG_FILE" | less -R
    else
        grep -i "$filter" "$INSTALL_LOG_FILE" | tail -n "$lines" | less -R
    fi
}

# Fonction pour obtenir le résumé des installations
get_install_summary() {
    if [ ! -f "$INSTALL_LOG_FILE" ]; then
        echo "Aucun log d'installation."
        return 1
    fi
    
    local total=$(wc -l < "$INSTALL_LOG_FILE" 2>/dev/null || echo "0")
    local success=$(grep -c "\[success\]" "$INSTALL_LOG_FILE" 2>/dev/null || echo "0")
    local failed=$(grep -c "\[failed\]" "$INSTALL_LOG_FILE" 2>/dev/null || echo "0")
    local skipped=$(grep -c "\[skipped\]" "$INSTALL_LOG_FILE" 2>/dev/null || echo "0")
    
    echo "Résumé des installations:"
    echo "  Total d'actions: $total"
    echo "  Réussies: $success"
    echo "  Échouées: $failed"
    echo "  Ignorées: $skipped"
}

# Fonction pour obtenir les dernières actions
get_recent_actions() {
    local count="${1:-10}"
    if [ ! -f "$INSTALL_LOG_FILE" ]; then
        return 1
    fi
    tail -n "$count" "$INSTALL_LOG_FILE"
}

