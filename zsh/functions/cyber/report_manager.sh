#!/bin/zsh
# =============================================================================
# REPORT MANAGER - Gestionnaire de rapports pour cyberman
# =============================================================================
# Description: Gère la génération, stockage et visualisation des rapports
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Liste tous les rapports disponibles
# USAGE: list_reports [--recent N]
# EXAMPLE: list_reports
# EXAMPLE: list_reports --recent 5
list_reports() {
    local recent_count=0
    
    # Parser les arguments
    if [ "$1" = "--recent" ] && [ -n "$2" ]; then
        recent_count="$2"
    fi
    
    if [ ! -d "$CYBER_REPORTS_DIR" ] || [ -z "$(ls -A "$CYBER_REPORTS_DIR" 2>/dev/null)" ]; then
        echo "⚠️  Aucun rapport disponible"
        return 1
    fi
    
    echo "📋 Rapports disponibles:"
    echo ""
    
    if command -v jq >/dev/null 2>&1; then
        local count=1
        local files=($(ls -t "$CYBER_REPORTS_DIR"/*.json 2>/dev/null))
        
        if [ $recent_count -gt 0 ]; then
            files=(${files[@]:0:$recent_count})
        fi
        
        for report_file in "${files[@]}"; do
            if [ -f "$report_file" ]; then
                local basename=$(basename "$report_file" .json)
                local workflow=$(jq -r '.workflow // "N/A"' "$report_file")
                local env=$(jq -r '.environment // "N/A"' "$report_file")
                local started=$(jq -r '.started // "N/A"' "$report_file")
                local status=$(jq -r '.status // "unknown"' "$report_file")
                local steps_count=$(jq '.steps | length' "$report_file")
                local targets_count=$(jq '.targets | length' "$report_file")
                
                echo "  $count. $basename"
                echo "     📊 Workflow: $workflow"
                echo "     🌍 Environnement: $env"
                echo "     📅 Début: $started"
                echo "     ✅ Statut: $status"
                echo "     📋 Étapes: $steps_count | 🎯 Cibles: $targets_count"
                echo ""
                ((count++))
            fi
        done
    else
        local count=1
        for report_file in "$CYBER_REPORTS_DIR"/*.json; do
            if [ -f "$report_file" ]; then
                local basename=$(basename "$report_file" .json)
                echo "  $count. $basename"
                ((count++))
            fi
        done
    fi
    
    return 0
}

# DESC: Affiche un rapport complet
# USAGE: show_report <report_name>
# EXAMPLE: show_report "full_pentest_20240101_120000"
show_report() {
    local report_name="$1"
    
    if [ -z "$report_name" ]; then
        echo "❌ Usage: show_report <report_name>"
        echo "💡 Liste des rapports: list_reports"
        return 1
    fi
    
    local report_file="$CYBER_REPORTS_DIR/${report_name}.json"
    
    # Si pas d'extension, essayer avec .json
    if [ ! -f "$report_file" ]; then
        report_file="$CYBER_REPORTS_DIR/${report_name}"
    fi
    
    if [ ! -f "$report_file" ]; then
        echo "❌ Rapport non trouvé: $report_name"
        echo "💡 Liste des rapports: list_reports"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis pour afficher les rapports"
        return 1
    fi
    
    local workflow=$(jq -r '.workflow // "N/A"' "$report_file")
    local env=$(jq -r '.environment // "N/A"' "$report_file")
    local started=$(jq -r '.started' "$report_file")
    local ended=$(jq -r '.ended // "En cours..."' "$report_file")
    local status=$(jq -r '.status // "unknown"' "$report_file")
    local targets=($(jq -r '.targets[]' "$report_file"))
    local steps_count=$(jq '.steps | length' "$report_file")
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 RAPPORT DE TEST DE SÉCURITÉ"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📋 Workflow: $workflow"
    echo "🌍 Environnement: $env"
    echo "📅 Début: $started"
    echo "📅 Fin: $ended"
    echo "✅ Statut: $status"
    echo "🎯 Cibles: ${#targets[@]}"
    for target in "${targets[@]}"; do
        echo "   • $target"
    done
    echo "📊 Étapes: $steps_count"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Afficher chaque étape
    local step_num=1
    jq -c '.steps[]' "$report_file" | while IFS= read -r step; do
        local step_type=$(echo "$step" | jq -r '.type')
        local func_name=$(echo "$step" | jq -r '.function')
        local step_start=$(echo "$step" | jq -r '.started')
        local step_end=$(echo "$step" | jq -r '.ended')
        local step_output=$(echo "$step" | jq -r '.output')
        
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📋 Étape $step_num: $func_name"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Type: $step_type"
        echo "Début: $step_start"
        echo "Fin: $step_end"
        echo ""
        echo "📄 Sortie:"
        echo "$step_output"
        echo ""
        
        ((step_num++))
    done
    
    return 0
}

# DESC: Affiche un résumé d'un rapport
# USAGE: report_summary <report_name>
# EXAMPLE: report_summary "full_pentest_20240101_120000"
report_summary() {
    local report_name="$1"
    
    if [ -z "$report_name" ]; then
        echo "❌ Usage: report_summary <report_name>"
        return 1
    fi
    
    local report_file="$CYBER_REPORTS_DIR/${report_name}.json"
    
    if [ ! -f "$report_file" ]; then
        report_file="$CYBER_REPORTS_DIR/${report_name}"
    fi
    
    if [ ! -f "$report_file" ]; then
        echo "❌ Rapport non trouvé: $report_name"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis"
        return 1
    fi
    
    local workflow=$(jq -r '.workflow // "N/A"' "$report_file")
    local started=$(jq -r '.started' "$report_file")
    local ended=$(jq -r '.ended // "En cours..."' "$report_file")
    local status=$(jq -r '.status // "unknown"' "$report_file")
    local steps_count=$(jq '.steps | length' "$report_file")
    
    echo "📊 Résumé: $report_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Workflow: $workflow"
    echo "Statut: $status"
    echo "Début: $started"
    echo "Fin: $ended"
    echo "Étapes: $steps_count"
    echo ""
    
    return 0
}

# DESC: Exporte un rapport en format texte
# USAGE: export_report <report_name> [output_file]
# EXAMPLE: export_report "full_pentest_20240101_120000" report.txt
export_report() {
    local report_name="$1"
    local output_file="${2:-${report_name}_export.txt}"
    
    if [ -z "$report_name" ]; then
        echo "❌ Usage: export_report <report_name> [output_file]"
        return 1
    fi
    
    local report_file="$CYBER_REPORTS_DIR/${report_name}.json"
    
    if [ ! -f "$report_file" ]; then
        report_file="$CYBER_REPORTS_DIR/${report_name}"
    fi
    
    if [ ! -f "$report_file" ]; then
        echo "❌ Rapport non trouvé: $report_name"
        return 1
    fi
    
    # Générer le rapport texte
    show_report "$report_name" > "$output_file" 2>&1
    
    echo "✅ Rapport exporté: $output_file"
    return 0
}

# DESC: Supprime un rapport
# USAGE: delete_report <report_name>
# EXAMPLE: delete_report "full_pentest_20240101_120000"
delete_report() {
    local report_name="$1"
    
    if [ -z "$report_name" ]; then
        echo "❌ Usage: delete_report <report_name>"
        return 1
    fi
    
    local report_file="$CYBER_REPORTS_DIR/${report_name}.json"
    
    if [ ! -f "$report_file" ]; then
        report_file="$CYBER_REPORTS_DIR/${report_name}"
    fi
    
    if [ ! -f "$report_file" ]; then
        echo "❌ Rapport non trouvé: $report_name"
        return 1
    fi
    
    printf "⚠️  Supprimer le rapport '$report_name'? (o/N): "
    read -r confirm
    if [ "$confirm" = "o" ] || [ "$confirm" = "O" ]; then
        rm "$report_file"
        echo "✅ Rapport supprimé: $report_name"
        return 0
    else
        echo "❌ Suppression annulée"
        return 1
    fi
}

