#!/bin/zsh
# =============================================================================
# WORKFLOW MANAGER - Gestionnaire de workflows pour cyberman
# =============================================================================
# Description: Gère les workflows de tests de sécurité (séquences de scans)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger les dépendances
CYBER_DIR="${CYBER_DIR:-$HOME/dotfiles/zsh/functions/cyber}"

# Répertoires de stockage
CYBER_WORKFLOWS_DIR="${CYBER_WORKFLOWS_DIR:-${HOME}/.cyberman/workflows}"
CYBER_REPORTS_DIR="${CYBER_REPORTS_DIR:-${HOME}/.cyberman/reports}"

# Créer les répertoires si nécessaire
mkdir -p "$CYBER_WORKFLOWS_DIR" "$CYBER_REPORTS_DIR"

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
    
    local workflow_file="${CYBER_WORKFLOWS_DIR}/${name}.json"
    
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
    # Vérifier si le répertoire existe
    if [ ! -d "$CYBER_WORKFLOWS_DIR" ]; then
        echo "⚠️  Aucun workflow sauvegardé"
        return 1
    fi
    
    # Compter les fichiers JSON sans utiliser de glob qui pourrait échouer
    local json_count=$(find "$CYBER_WORKFLOWS_DIR" -maxdepth 1 -name "*.json" -type f 2>/dev/null | wc -l)
    
    if [ "$json_count" -eq 0 ]; then
        echo "⚠️  Aucun workflow sauvegardé"
        return 1
    fi
    
    echo "📋 Workflows disponibles:"
    echo ""
    
    if command -v jq >/dev/null 2>&1; then
        local count=1
        # Utiliser find pour éviter les problèmes de glob pattern en Zsh
        while IFS= read -r workflow_file; do
            if [ -f "$workflow_file" ]; then
                local name=$(jq -r '.name' "$workflow_file" 2>/dev/null)
                local desc=$(jq -r '.description' "$workflow_file" 2>/dev/null)
                local created=$(jq -r '.created' "$workflow_file" 2>/dev/null)
                local steps_count=$(jq '.steps | length' "$workflow_file" 2>/dev/null || echo "0")
                
                # Vérifier que les valeurs ne sont pas "null"
                [ "$name" = "null" ] && name=$(basename "$workflow_file" .json)
                [ "$desc" = "null" ] && desc="Pas de description"
                [ "$created" = "null" ] && created="Date inconnue"
                
                echo "  $count. $name"
                echo "     📝 $desc"
                echo "     📅 $created"
                echo "     📊 $steps_count étape(s)"
                echo ""
                ((count++))
            fi
        done < <(find "$CYBER_WORKFLOWS_DIR" -maxdepth 1 -name "*.json" -type f 2>/dev/null | sort)
    else
        local count=1
        # Utiliser find pour éviter les problèmes de glob pattern en Zsh
        while IFS= read -r workflow_file; do
            if [ -f "$workflow_file" ]; then
                local basename=$(basename "$workflow_file" .json)
                echo "  $count. $basename"
                ((count++))
            fi
        done < <(find "$CYBER_WORKFLOWS_DIR" -maxdepth 1 -name "*.json" -type f 2>/dev/null | sort)
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
    
    local workflow_file="${CYBER_WORKFLOWS_DIR}/${name}.json"
    
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
    
    local workflow_file="${CYBER_WORKFLOWS_DIR}/${name}.json"
    
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

# DESC: Affiche le menu interactif de gestion des workflows
# USAGE: show_workflow_menu
# EXAMPLE: show_workflow_menu
show_workflow_menu() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    while true; do
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║              GESTION DES WORKFLOWS - CYBERMAN                  ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo ""
        
        # Lister les workflows (peut retourner 1 si aucun workflow)
        if ! list_workflows 2>/dev/null; then
            # Si aucun workflow, afficher un message mais continuer
            echo ""
        fi
        echo ""
        echo "1.  Créer un nouveau workflow"
        echo "2.  Ajouter une étape à un workflow"
        echo "3.  Exécuter un workflow"
        echo "4.  Afficher les détails d'un workflow"
        echo "5.  Supprimer un workflow"
        echo "6.  Lister tous les workflows"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                echo ""
                printf "📝 Nom du workflow: "
                read -r name
                if [ -n "$name" ]; then
                    printf "📝 Description (optionnel): "
                    read -r desc
                    create_workflow "$name" "$desc"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2)
                echo ""
                list_workflows
                echo ""
                printf "📝 Nom du workflow: "
                read -r workflow_name
                if [ -n "$workflow_name" ]; then
                    printf "📋 Type d'étape (scan/vuln/recon/attack/analysis): "
                    read -r step_type
                    printf "🔧 Nom de la fonction: "
                    read -r func_name
                    printf "📝 Arguments (optionnel): "
                    read -r args
                    if [ -n "$step_type" ] && [ -n "$func_name" ]; then
                        add_workflow_step "$workflow_name" "$step_type" "$func_name" "$args"
                    fi
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3)
                echo ""
                list_workflows
                echo ""
                printf "🚀 Nom du workflow à exécuter: "
                read -r name
                if [ -n "$name" ]; then
                    printf "🌍 Nom de l'environnement (optionnel): "
                    read -r env_name
                    run_workflow "$name" "$env_name"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4)
                echo ""
                list_workflows
                echo ""
                printf "📋 Nom du workflow: "
                read -r name
                if [ -n "$name" ]; then
                    show_workflow "$name"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            5)
                echo ""
                list_workflows
                echo ""
                printf "🗑️  Nom du workflow à supprimer: "
                read -r name
                if [ -n "$name" ]; then
                    delete_workflow "$name"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            6)
                list_workflows
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
}

