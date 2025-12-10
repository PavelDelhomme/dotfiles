#!/bin/zsh
# =============================================================================
# REPORT GENERATOR - Générateur de rapports structurés pour cyberman
# =============================================================================
# Description: Génère des rapports structurés en JSON et HTML
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoires de stockage organisés
CYBER_REPORTS_BASE="${CYBER_REPORTS_BASE:-${HOME}/.cyberman/reports}"
CYBER_REPORTS_DIR="${CYBER_REPORTS_DIR:-$CYBER_REPORTS_BASE}"

# DESC: Crée la structure de répertoires pour les rapports
# USAGE: setup_report_structure [env_name]
# EXAMPLE: setup_report_structure "pentest_example"
setup_report_structure() {
    local env_name="$1"
    local year=$(date +%Y)
    local month=$(date +%m)
    
    # Structure: reports/env_name/YYYY/MM/
    if [ -n "$env_name" ]; then
        mkdir -p "$CYBER_REPORTS_BASE/$env_name/$year/$month"
        echo "$CYBER_REPORTS_BASE/$env_name/$year/$month"
    else
        # Structure globale: reports/YYYY/MM/
        mkdir -p "$CYBER_REPORTS_BASE/$year/$month"
        echo "$CYBER_REPORTS_BASE/$year/$month"
    fi
}

# DESC: Génère un rapport structuré JSON
# USAGE: generate_structured_report <env_name> <report_type> <data>
# EXAMPLE: generate_structured_report "pentest_example" "network_scan" "$scan_data"
generate_structured_report() {
    local env_name="$1"
    local report_type="$2"
    local data="$3"
    local description="${4:-Rapport automatique}"
    
    if [ -z "$env_name" ] || [ -z "$report_type" ] || [ -z "$data" ]; then
        echo "❌ Usage: generate_structured_report <env_name> <report_type> <data> [description]"
        return 1
    fi
    
    # Créer la structure de répertoires
    local report_dir=$(setup_report_structure "$env_name")
    
    # Générer le nom du rapport
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local report_name="${env_name}_${report_type}_${timestamp}"
    local report_file="$report_dir/${report_name}.json"
    
    # Structure JSON du rapport
    local report_json=$(cat <<EOF
{
  "report_id": "$report_name",
  "environment": "$env_name",
  "report_type": "$report_type",
  "description": "$description",
  "created": "$(date -Iseconds)",
  "created_timestamp": "$timestamp",
  "status": "completed",
  "data": $data,
  "metadata": {
    "tool": "cyberman",
    "version": "1.0",
    "hostname": "$(hostname)",
    "user": "$(whoami)"
  }
}
EOF
)
    
    # Vérifier que le JSON est valide
    if echo "$report_json" | jq empty 2>/dev/null; then
        echo "$report_json" > "$report_file"
        echo "✅ Rapport généré: $report_file"
        echo "$report_file"
        return 0
    else
        echo "❌ Erreur: JSON invalide généré"
        return 1
    fi
}

# DESC: Génère un rapport HTML depuis un rapport JSON
# USAGE: generate_html_report <report_json_file> [output_html]
# EXAMPLE: generate_html_report "report.json" "report.html"
generate_html_report() {
    local report_json="$1"
    local output_html="${2:-${report_json%.json}.html}"
    
    if [ ! -f "$report_json" ] || ! command -v jq >/dev/null 2>&1; then
        echo "❌ Fichier JSON requis ou jq non disponible"
        return 1
    fi
    
    # Vérifier que le JSON est valide
    if ! jq empty "$report_json" 2>/dev/null; then
        echo "❌ Fichier JSON invalide"
        return 1
    fi
    
    local report_id=$(jq -r '.report_id // "N/A"' "$report_json")
    local env_name=$(jq -r '.environment // "N/A"' "$report_json")
    local report_type=$(jq -r '.report_type // "N/A"' "$report_json")
    local description=$(jq -r '.description // "N/A"' "$report_json")
    local created=$(jq -r '.created // "N/A"' "$report_json")
    local status=$(jq -r '.status // "unknown"' "$report_json")
    
    # Générer le HTML
    cat > "$output_html" <<EOF
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapport Cyberman - $report_id</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
            color: #333;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        .info-card {
            background: #ecf0f1;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #3498db;
        }
        .info-card strong {
            color: #2c3e50;
            display: block;
            margin-bottom: 5px;
        }
        .data-section {
            margin: 30px 0;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 5px;
        }
        .data-section h2 {
            color: #34495e;
            margin-top: 0;
        }
        pre {
            background: #2c3e50;
            color: #ecf0f1;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
            font-size: 14px;
        }
        .status {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-weight: bold;
        }
        .status.completed {
            background: #2ecc71;
            color: white;
        }
        .status.failed {
            background: #e74c3c;
            color: white;
        }
        .status.in-progress {
            background: #f39c12;
            color: white;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Rapport Cyberman</h1>
        
        <div class="info-grid">
            <div class="info-card">
                <strong>ID du rapport</strong>
                $report_id
            </div>
            <div class="info-card">
                <strong>Environnement</strong>
                $env_name
            </div>
            <div class="info-card">
                <strong>Type de rapport</strong>
                $report_type
            </div>
            <div class="info-card">
                <strong>Date de création</strong>
                $created
            </div>
            <div class="info-card">
                <strong>Statut</strong>
                <span class="status $status">$status</span>
            </div>
        </div>
        
        <div class="info-card" style="margin: 20px 0;">
            <strong>Description</strong>
            $description
        </div>
        
        <div class="data-section">
            <h2>📋 Données du rapport</h2>
            <pre>$(jq -r '.data' "$report_json" 2>/dev/null | jq '.' 2>/dev/null || echo "Données non disponibles")</pre>
        </div>
        
        <div class="data-section">
            <h2>🔧 Métadonnées</h2>
            <pre>$(jq -r '.metadata' "$report_json" 2>/dev/null | jq '.' 2>/dev/null || echo "Métadonnées non disponibles")</pre>
        </div>
    </div>
</body>
</html>
EOF
    
    echo "✅ Rapport HTML généré: $output_html"
    return 0
}

# DESC: Liste les rapports avec pagination
# USAGE: list_reports_paginated [env_name] [--recent N]
# EXAMPLE: list_reports_paginated "pentest_example"
list_reports_paginated() {
    local env_name="$1"
    local recent_count=0
    
    # Parser les arguments
    if [ "$1" = "--recent" ] && [ -n "$2" ]; then
        recent_count="$2"
        env_name=""
    elif [ "$2" = "--recent" ] && [ -n "$3" ]; then
        recent_count="$3"
    fi
    
    # Charger la pagination
    local UTILS_DIR="$HOME/dotfiles/zsh/functions/cyberman/modules/legacy/utils"
    if [ -f "$UTILS_DIR/pagination.sh" ]; then
        source "$UTILS_DIR/pagination.sh" 2>/dev/null
    fi
    
    # Trouver les rapports
    local -a report_files=()
    if [ -n "$env_name" ]; then
        # Rapports pour un environnement spécifique
        report_files=($(find "$CYBER_REPORTS_BASE/$env_name" -name "*.json" -type f 2>/dev/null | sort -r))
    else
        # Tous les rapports
        report_files=($(find "$CYBER_REPORTS_BASE" -name "*.json" -type f ! -name "README.json" ! -name "STATUS.json" 2>/dev/null | sort -r))
    fi
    
    if [ ${#report_files[@]} -eq 0 ]; then
        echo "⚠️  Aucun rapport disponible"
        return 1
    fi
    
    # Filtrer les vrais rapports (avec structure valide)
    local -a valid_reports=()
    for report_file in "${report_files[@]}"; do
        if jq empty "$report_file" 2>/dev/null && \
           jq -e '.environment // .report_type // .data' "$report_file" >/dev/null 2>&1; then
            valid_reports+=("$report_file")
        fi
    done
    
    if [ $recent_count -gt 0 ]; then
        valid_reports=(${valid_reports[@]:0:$recent_count})
    fi
    
    # Utiliser la pagination si disponible
    if type paginate_list >/dev/null 2>&1; then
        local display_report() {
            local report_file="$1"
            local idx="$2"
            local basename=$(basename "$report_file" .json)
            if command -v jq >/dev/null 2>&1; then
                local env=$(jq -r '.environment // "N/A"' "$report_file" 2>/dev/null || echo "N/A")
                local report_type=$(jq -r '.report_type // "N/A"' "$report_file" 2>/dev/null || echo "N/A")
                local created=$(jq -r '.created // "N/A"' "$report_file" 2>/dev/null || echo "N/A")
                local report_status=$(jq -r '.status // "unknown"' "$report_file" 2>/dev/null || echo "unknown")
                
                echo "  $idx. $basename"
                echo "     🌍 Env: $env | 📊 Type: $report_type"
                echo "     📅 Créé: $created | ✅ Statut: $report_status"
            else
                echo "  $idx. $basename"
            fi
        }
        
        paginate_list "valid_reports" 10 "display_report"
    else
        # Fallback sans pagination
        local count=1
        for report_file in "${valid_reports[@]}"; do
            local basename=$(basename "$report_file" .json)
            echo "  $count. $basename"
            ((count++))
        done
    fi
}

