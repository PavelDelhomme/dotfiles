#!/bin/zsh
# =============================================================================
# WORKFLOW MANAGER - Gestionnaire de workflows pour cyberman
# =============================================================================
# Description: Gère les workflows de tests de sécurité (séquences de scans)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger les dépendances
CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"
if [ -f "$CYBER_DIR/target_manager.sh" ]; then
    source "$CYBER_DIR/target_manager.sh"
fi
if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
    source "$CYBER_DIR/environment_manager.sh"
fi

# DESC: Crée un nouveau workflow
# USAGE: create_workflow <name> [description]
# EXAMPLE: create_workflow "full_pentest" "Test de pénétration complet"
create_workflow() {
    local name="$1"
    local description="${2:-Workflow créé le $(date '+%Y-%m-%d %H:%M:%S')}"
    
    if [ -z "$name" ]; then
        echo "❌ Usage: create_workflow <name> [description]"
        return 1
    fi
    
    local workflow_file="$CYBER_WORKFLOWS_DIR/${name}.json"
    
    if [ -f "$workflow_file" ]; then
        printf "⚠️  Le workflow '$name' existe déjà. Remplacer? (o/N): "
        read -r confirm
        if [ "$confirm" != "o" ] && [ "$confirm" != "O" ]; then
            return 1
        fi
    fi
    
    # Créer le workflow vide
    cat > "$workflow_file" <<EOF
{
  "name": "$name",
  "description": "$description",
  "created": "$(date -Iseconds)",
  "steps": []
}
EOF
    
    echo "✅ Workflow créé: $name"
    echo "💡 Utilisez 'add_workflow_step' pour ajouter des étapes"
    return 0
}

# DESC: Ajoute une étape à un workflow
# USAGE: add_workflow_step <workflow_name> <step_type> <function_name> [args]
# EXAMPLE: add_workflow_step "full_pentest" "scan" "port_scan"
# EXAMPLE: add_workflow_step "full_pentest" "vuln" "nmap_vuln_scan" "--script vuln"
add_workflow_step() {
    local workflow_name="$1"
    local step_type="$2"
    local function_name="$3"
    shift 3
    local args="$@"
    
    if [ -z "$workflow_name" ] || [ -z "$step_type" ] || [ -z "$function_name" ]; then
        echo "❌ Usage: add_workflow_step <workflow_name> <step_type> <function_name> [args]"
        echo "Types: scan, vuln, recon, attack, analysis"
        return 1
    fi
    
    local workflow_file="$CYBER_WORKFLOWS_DIR/${workflow_name}.json"
    
    if [ ! -f "$workflow_file" ]; then
        echo "❌ Workflow non trouvé: $workflow_name"
        echo "💡 Créez-le d'abord avec: create_workflow $workflow_name"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis pour gérer les workflows"
        return 1
    fi
    
    # Ajouter l'étape
    local step_json=$(jq -n \
        --arg type "$step_type" \
        --arg func "$function_name" \
        --arg args "$args" \
        '{type: $type, function: $func, args: $args, timestamp: now}')
    
    jq ".steps += [$step_json]" "$workflow_file" > "${workflow_file}.tmp" && \
    mv "${workflow_file}.tmp" "$workflow_file"
    
    echo "✅ Étape ajoutée au workflow '$workflow_name':"
    echo "   Type: $step_type"
    echo "   Fonction: $function_name"
    [ -n "$args" ] && echo "   Arguments: $args"
    return 0
}

# DESC: Exécute un workflow complet
# USAGE: run_workflow <workflow_name> [environment_name]
# EXAMPLE: run_workflow "full_pentest" "pentest_example_com"
run_workflow() {
    local workflow_name="$1"
    local env_name="$2"
    
    if [ -z "$workflow_name" ]; then
        echo "❌ Usage: run_workflow <workflow_name> [environment_name]"
        return 1
    fi
    
    local workflow_file="$CYBER_WORKFLOWS_DIR/${workflow_name}.json"
    
    if [ ! -f "$workflow_file" ]; then
        echo "❌ Workflow non trouvé: $workflow_name"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis pour exécuter les workflows"
        return 1
    fi
    
    # Charger l'environnement si fourni
    if [ -n "$env_name" ]; then
        load_environment "$env_name" || return 1
    fi
    
    # Vérifier qu'il y a des cibles
    if ! has_targets; then
        echo "❌ Aucune cible configurée"
        echo "💡 Chargez un environnement ou ajoutez des cibles"
        return 1
    fi
    
    local workflow_desc=$(jq -r '.description' "$workflow_file")
    local steps_count=$(jq '.steps | length' "$workflow_file")
    
    echo "🚀 Exécution du workflow: $workflow_name"
    echo "📝 Description: $workflow_desc"
    echo "📊 Étapes: $steps_count"
    echo ""
    
    # Générer un nom de rapport
    local report_name="${workflow_name}_$(date +%Y%m%d_%H%M%S)"
    local report_file="$CYBER_REPORTS_DIR/${report_name}.json"
    
    # Initialiser le rapport
    cat > "$report_file" <<EOF
{
  "workflow": "$workflow_name",
  "environment": "${env_name:-current}",
  "started": "$(date -Iseconds)",
  "targets": $(printf '%s\n' "${CYBER_TARGETS[@]}" | jq -R . | jq -s .),
  "steps": []
}
EOF
    
    # Exécuter chaque étape
    local step_num=1
    jq -c '.steps[]' "$workflow_file" | while IFS= read -r step; do
        local step_type=$(echo "$step" | jq -r '.type')
        local func_name=$(echo "$step" | jq -r '.function')
        local step_args=$(echo "$step" | jq -r '.args // ""')
        
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📋 Étape $step_num/$steps_count: $func_name"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        local step_start=$(date -Iseconds)
        local step_output=""
        
        # Exécuter la fonction pour chaque cible
        for target in "${CYBER_TARGETS[@]}"; do
            echo "🎯 Cible: $target"
            echo ""
            
            # Capturer la sortie
            if [ -n "$step_args" ]; then
                step_output+=$($func_name "$target" $step_args 2>&1)
            else
                step_output+=$($func_name "$target" 2>&1)
            fi
            step_output+="\n"
        done
        
        local step_end=$(date -Iseconds)
        
        # Ajouter l'étape au rapport
        local step_report=$(jq -n \
            --arg type "$step_type" \
            --arg func "$func_name" \
            --arg args "$step_args" \
            --arg start "$step_start" \
            --arg end "$step_end" \
            --arg output "$step_output" \
            '{type: $type, function: $func, args: $args, started: $start, ended: $end, output: $output}')
        
        jq ".steps += [$step_report]" "$report_file" > "${report_file}.tmp" && \
        mv "${report_file}.tmp" "$report_file"
        
        echo ""
        ((step_num++))
    done
    
    # Finaliser le rapport
    jq ". + {ended: \"$(date -Iseconds)\", status: \"completed\"}" "$report_file" > "${report_file}.tmp" && \
    mv "${report_file}.tmp" "$report_file"
    
    echo "✅ Workflow terminé"
    echo "📄 Rapport: $report_file"
    return 0
}

# DESC: Liste tous les workflows
# USAGE: list_workflows
# EXAMPLE: list_workflows
list_workflows() {
    if [ ! -d "$CYBER_WORKFLOWS_DIR" ] || [ -z "$(ls -A "$CYBER_WORKFLOWS_DIR" 2>/dev/null)" ]; then
        echo "⚠️  Aucun workflow sauvegardé"
        return 1
    fi
    
    echo "📋 Workflows disponibles:"
    echo ""
    
    if command -v jq >/dev/null 2>&1; then
        local count=1
        for workflow_file in "$CYBER_WORKFLOWS_DIR"/*.json; do
            if [ -f "$workflow_file" ]; then
                local name=$(jq -r '.name' "$workflow_file")
                local desc=$(jq -r '.description' "$workflow_file")
                local created=$(jq -r '.created' "$workflow_file")
                local steps_count=$(jq '.steps | length' "$workflow_file")
                
                echo "  $count. $name"
                echo "     📝 $desc"
                echo "     📅 $created"
                echo "     📊 $steps_count étape(s)"
                echo ""
                ((count++))
            fi
        done
    else
        local count=1
        for workflow_file in "$CYBER_WORKFLOWS_DIR"/*.json; do
            if [ -f "$workflow_file" ]; then
                local basename=$(basename "$workflow_file" .json)
                echo "  $count. $basename"
                ((count++))
            fi
        done
    fi
    
    return 0
}

# DESC: Affiche les détails d'un workflow
# USAGE: show_workflow <name>
# EXAMPLE: show_workflow "full_pentest"
show_workflow() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo "❌ Usage: show_workflow <name>"
        return 1
    fi
    
    local workflow_file="$CYBER_WORKFLOWS_DIR/${name}.json"
    
    if [ ! -f "$workflow_file" ]; then
        echo "❌ Workflow non trouvé: $name"
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        echo "📋 Détails du workflow: $name"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        jq '.' "$workflow_file"
    else
        cat "$workflow_file"
    fi
    
    return 0
}

# DESC: Supprime un workflow
# USAGE: delete_workflow <name>
# EXAMPLE: delete_workflow "full_pentest"
delete_workflow() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo "❌ Usage: delete_workflow <name>"
        return 1
    fi
    
    local workflow_file="$CYBER_WORKFLOWS_DIR/${name}.json"
    
    if [ ! -f "$workflow_file" ]; then
        echo "❌ Workflow non trouvé: $name"
        return 1
    fi
    
    printf "⚠️  Supprimer le workflow '$name'? (o/N): "
    read -r confirm
    if [ "$confirm" = "o" ] || [ "$confirm" = "O" ]; then
        rm "$workflow_file"
        echo "✅ Workflow supprimé: $name"
        return 0
    else
        echo "❌ Suppression annulée"
        return 1
    fi
}

