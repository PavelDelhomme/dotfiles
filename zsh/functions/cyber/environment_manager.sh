#!/bin/zsh
# =============================================================================
# ENVIRONMENT MANAGER - Gestionnaire d'environnements pour cyberman
# =============================================================================
# Description: Gère les environnements de test (cibles, configurations, workflows)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoire de stockage des environnements
CYBER_ENV_DIR="${HOME}/.cyberman/environments"
CYBER_REPORTS_DIR="${HOME}/.cyberman/reports"
CYBER_WORKFLOWS_DIR="${HOME}/.cyberman/workflows"

# Créer les répertoires si nécessaire
mkdir -p "$CYBER_ENV_DIR" "$CYBER_REPORTS_DIR" "$CYBER_WORKFLOWS_DIR"

# DESC: Sauvegarde l'environnement actuel (cibles, configuration)
# USAGE: save_environment <name> [description]
# EXAMPLE: save_environment "pentest_example_com" "Test de pénétration example.com"
save_environment() {
    local name="$1"
    local description="${2:-Environnement sauvegardé le $(date '+%Y-%m-%d %H:%M:%S')}"
    
    if [ -z "$name" ]; then
        echo "❌ Usage: save_environment <name> [description]"
        return 1
    fi
    
    # Charger les cibles actuelles
    local CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    
    local env_file="$CYBER_ENV_DIR/${name}.json"
    
    # Créer le JSON de l'environnement
    cat > "$env_file" <<EOF
{
  "name": "$name",
  "description": "$description",
  "created": "$(date -Iseconds)",
  "targets": $(printf '%s\n' "${CYBER_TARGETS[@]}" | jq -R . | jq -s .),
  "metadata": {
    "user": "$USER",
    "hostname": "$(hostname)"
  }
}
EOF
    
    echo "✅ Environnement sauvegardé: $name"
    echo "📁 Fichier: $env_file"
    return 0
}

# DESC: Charge un environnement sauvegardé
# USAGE: load_environment <name>
# EXAMPLE: load_environment "pentest_example_com"
load_environment() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo "❌ Usage: load_environment <name>"
        return 1
    fi
    
    local env_file="$CYBER_ENV_DIR/${name}.json"
    
    if [ ! -f "$env_file" ]; then
        echo "❌ Environnement non trouvé: $name"
        echo "💡 Liste des environnements: list_environments"
        return 1
    fi
    
    # Charger le gestionnaire de cibles
    local CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    
    # Parser le JSON et charger les cibles
    if command -v jq >/dev/null 2>&1; then
        CYBER_TARGETS=($(jq -r '.targets[]' "$env_file"))
        local desc=$(jq -r '.description' "$env_file")
        local created=$(jq -r '.created' "$env_file")
        
        echo "✅ Environnement chargé: $name"
        echo "📝 Description: $desc"
        echo "📅 Créé: $created"
        echo "🎯 Cibles chargées: ${#CYBER_TARGETS[@]}"
        show_targets
        return 0
    else
        echo "❌ jq requis pour charger les environnements"
        echo "💡 Installez jq: sudo pacman -S jq"
        return 1
    fi
}

# DESC: Liste tous les environnements sauvegardés
# USAGE: list_environments
# EXAMPLE: list_environments
list_environments() {
    if [ ! -d "$CYBER_ENV_DIR" ] || [ -z "$(ls -A "$CYBER_ENV_DIR" 2>/dev/null)" ]; then
        echo "⚠️  Aucun environnement sauvegardé"
        return 1
    fi
    
    echo "📋 Environnements disponibles:"
    echo ""
    
    if command -v jq >/dev/null 2>&1; then
        local count=1
        for env_file in "$CYBER_ENV_DIR"/*.json; do
            if [ -f "$env_file" ]; then
                local name=$(jq -r '.name' "$env_file")
                local desc=$(jq -r '.description' "$env_file")
                local created=$(jq -r '.created' "$env_file")
                local targets_count=$(jq -r '.targets | length' "$env_file")
                
                echo "  $count. $name"
                echo "     📝 $desc"
                echo "     📅 $created"
                echo "     🎯 $targets_count cible(s)"
                echo ""
                ((count++))
            fi
        done
    else
        # Fallback sans jq
        local count=1
        for env_file in "$CYBER_ENV_DIR"/*.json; do
            if [ -f "$env_file" ]; then
                local basename=$(basename "$env_file" .json)
                echo "  $count. $basename"
                ((count++))
            fi
        done
    fi
    
    return 0
}

# DESC: Supprime un environnement
# USAGE: delete_environment <name>
# EXAMPLE: delete_environment "pentest_example_com"
delete_environment() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo "❌ Usage: delete_environment <name>"
        return 1
    fi
    
    local env_file="$CYBER_ENV_DIR/${name}.json"
    
    if [ ! -f "$env_file" ]; then
        echo "❌ Environnement non trouvé: $name"
        return 1
    fi
    
    printf "⚠️  Supprimer l'environnement '$name'? (o/N): "
    read -r confirm
    if [ "$confirm" = "o" ] || [ "$confirm" = "O" ]; then
        rm "$env_file"
        echo "✅ Environnement supprimé: $name"
        return 0
    else
        echo "❌ Suppression annulée"
        return 1
    fi
}

# DESC: Affiche les détails d'un environnement
# USAGE: show_environment <name>
# EXAMPLE: show_environment "pentest_example_com"
show_environment() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo "❌ Usage: show_environment <name>"
        return 1
    fi
    
    local env_file="$CYBER_ENV_DIR/${name}.json"
    
    if [ ! -f "$env_file" ]; then
        echo "❌ Environnement non trouvé: $name"
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        echo "📋 Détails de l'environnement: $name"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        jq '.' "$env_file"
    else
        cat "$env_file"
    fi
    
    return 0
}

