#!/bin/zsh
# =============================================================================
# ENVIRONMENT MANAGER - Gestionnaire d'environnements pour cyberman
# =============================================================================
# Description: Gère les environnements de test (cibles, configurations, workflows)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoire de stockage des environnements
CYBER_ENV_DIR="${CYBER_ENV_DIR:-${HOME}/.cyberman/environments}"
CYBER_REPORTS_DIR="${CYBER_REPORTS_DIR:-${HOME}/.cyberman/reports}"
CYBER_WORKFLOWS_DIR="${CYBER_WORKFLOWS_DIR:-${HOME}/.cyberman/workflows}"

# Variable globale pour stocker l'environnement actuellement chargé
typeset -g CYBER_CURRENT_ENV=""

# Fichier de persistance de l'environnement actif
CYBER_CURRENT_ENV_FILE="${HOME}/.cyberman/current_env.txt"

# Créer les répertoires si nécessaire
mkdir -p "$CYBER_ENV_DIR" "$CYBER_REPORTS_DIR" "$CYBER_WORKFLOWS_DIR" "$(dirname "$CYBER_CURRENT_ENV_FILE")"

# Charger l'environnement actif depuis le fichier de persistance si disponible
# Seulement si la variable n'est pas déjà définie ET si le fichier existe vraiment
if [ -f "$CYBER_CURRENT_ENV_FILE" ] && [ -z "$CYBER_CURRENT_ENV" ]; then
    local saved_env=$(cat "$CYBER_CURRENT_ENV_FILE" 2>/dev/null | tr -d '\n' | head -c 100)
    if [ -n "$saved_env" ] && [ -f "$CYBER_ENV_DIR/${saved_env}.json" ]; then
        typeset -g CYBER_CURRENT_ENV="$saved_env"
    elif [ -z "$saved_env" ] || [ ! -f "$CYBER_ENV_DIR/${saved_env}.json" ]; then
        # Si le fichier existe mais contient un environnement invalide, le supprimer
        rm -f "$CYBER_CURRENT_ENV_FILE" 2>/dev/null
        typeset -g CYBER_CURRENT_ENV=""
    fi
fi

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
    local CYBER_DIR="${CYBER_DIR:-$HOME/dotfiles/zsh/functions/cyber}"
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh" 2>/dev/null
    fi
    
    # S'assurer que CYBER_TARGETS est défini
    if [ -z "${CYBER_TARGETS+x}" ]; then
        typeset -g -a CYBER_TARGETS=()
    fi
    
    local env_file="$CYBER_ENV_DIR/${name}.json"
    
    # Créer le JSON de l'environnement
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis pour sauvegarder les environnements"
        echo "💡 Installez jq: sudo pacman -S jq"
        return 1
    fi
    
    # Vérifier que les cibles sont chargées
    if [ ${#CYBER_TARGETS[@]} -eq 0 ]; then
        echo "⚠️  Aucune cible à sauvegarder"
        printf "Continuer quand même? (o/N): "
        read -r confirm
        if [ "$confirm" != "o" ] && [ "$confirm" != "O" ]; then
            return 1
        fi
    fi
    
    # Créer le JSON de l'environnement de manière robuste avec jq
    # Utiliser jq pour créer le JSON complet de manière sécurisée
    local temp_file=$(mktemp)
    local targets_json
    
    # Générer le tableau JSON des cibles
    if [ ${#CYBER_TARGETS[@]} -eq 0 ]; then
        targets_json="[]"
    else
        targets_json=$(printf '%s\n' "${CYBER_TARGETS[@]}" | jq -R . | jq -s .)
    fi
    
    # Créer le JSON complet avec jq pour éviter les problèmes d'échappement
    # Inclure les champs pour notes, historique et résultats
    jq -n \
        --arg name "$name" \
        --arg desc "$description" \
        --arg created "$(date -Iseconds)" \
        --arg user "$USER" \
        --arg hostname "$(hostname)" \
        --argjson targets "$targets_json" \
        '{
            name: $name,
            description: $desc,
            created: $created,
            targets: $targets,
            notes: [],
            history: [],
            results: [],
            metadata: {
                user: $user,
                hostname: $hostname,
                last_updated: $created
            },
            todos: []
        }' > "$temp_file" 2>/dev/null
    
    # Vérifier que le JSON est valide et le déplacer
    if [ $? -eq 0 ] && jq empty "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$env_file"
        echo "✅ Environnement sauvegardé: $name"
        echo "📁 Fichier: $env_file"
        echo "🎯 Cibles sauvegardées: ${#CYBER_TARGETS[@]}"
        return 0
    else
        rm -f "$temp_file"
        echo "❌ Erreur lors de la génération du JSON"
        echo "💡 Vérifiez que jq est installé: sudo pacman -S jq"
        return 1
    fi
}

# DESC: Trouve un environnement qui correspond aux cibles actuelles
# USAGE: find_environment_by_targets
# EXAMPLE: find_environment_by_targets
find_environment_by_targets() {
    if [ -z "${CYBER_TARGETS+x}" ] || [ ${#CYBER_TARGETS[@]} -eq 0 ]; then
        echo ""
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo ""
        return 1
    fi
    
    local env_dir="${CYBER_ENV_DIR}"
    if [ ! -d "$env_dir" ]; then
        echo ""
        return 1
    fi
    
    for env_file in "$env_dir"/*.json; do
        [ -f "$env_file" ] || continue
        local env_name=$(basename "$env_file" .json)
        local env_targets=$(jq -r '.targets[]?' "$env_file" 2>/dev/null)
        
        if [ -z "$env_targets" ]; then
            continue
        fi
        
        # Vérifier si toutes les cibles actuelles correspondent
        local match=true
        local env_target_count=$(echo "$env_targets" | grep -c . || echo "0")
        
        # Vérifier que le nombre de cibles correspond
        if [ "$env_target_count" -ne ${#CYBER_TARGETS[@]} ]; then
            continue
        fi
        
        # Vérifier que chaque cible actuelle est dans l'environnement
        for current_target in "${CYBER_TARGETS[@]}"; do
            if ! echo "$env_targets" | grep -qFx "$current_target"; then
                match=false
                break
            fi
        done
        
        if [ "$match" = true ]; then
            echo "$env_name"
            return 0
        fi
    done
    
    echo ""
    return 1
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
    local CYBER_DIR="${CYBER_DIR:-$HOME/dotfiles/zsh/functions/cyber}"
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    
    # Parser le JSON et charger les cibles
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis pour charger les environnements"
        echo "💡 Installez jq: sudo pacman -S jq"
        return 1
    fi
    
    # Vérifier que le fichier est un JSON valide
    if ! jq empty "$env_file" 2>/dev/null; then
        echo "❌ Fichier JSON invalide: $env_file"
        return 1
    fi
    
    # S'assurer que les champs notes, history, results, todos existent (pour compatibilité avec anciens environnements)
    local temp_file=$(mktemp)
    jq '.notes //= [] | .history //= [] | .results //= [] | .todos //= [] | .metadata.last_updated //= .created' \
       "$env_file" > "$temp_file" 2>/dev/null
    if [ $? -eq 0 ] && jq empty "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$env_file"
    else
        rm -f "$temp_file"
    fi
    
    # Charger les cibles depuis le JSON
    # Utiliser une méthode robuste pour charger le tableau
    local targets_array=()
    while IFS= read -r target; do
        if [ -n "$target" ] && [ "$target" != "null" ]; then
            targets_array+=("$target")
        fi
    done < <(jq -r '.targets[]?' "$env_file" 2>/dev/null)
    
    # Assigner les cibles à la variable globale
    CYBER_TARGETS=("${targets_array[@]}")
    
    local desc=$(jq -r '.description // "N/A"' "$env_file")
    local created=$(jq -r '.created // "N/A"' "$env_file")
    local notes_count=$(jq '.notes | length' "$env_file" 2>/dev/null || echo "0")
    local history_count=$(jq '.history | length' "$env_file" 2>/dev/null || echo "0")
    local results_count=$(jq '.results | length' "$env_file" 2>/dev/null || echo "0")
    local todos_count=$(jq '.todos | length' "$env_file" 2>/dev/null || echo "0")
    local todos_pending=$(jq '[.todos[]? | select(.status == "pending")] | length' "$env_file" 2>/dev/null || echo "0")
    
    # Sauvegarder les cibles chargées dans le fichier de persistance
    if typeset -f _save_targets_to_file >/dev/null 2>&1; then
        _save_targets_to_file
    elif [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
        if typeset -f _save_targets_to_file >/dev/null 2>&1; then
            _save_targets_to_file
        fi
    fi
    
    # Définir l'environnement actuel et le sauvegarder
    CYBER_CURRENT_ENV="$name"
    echo "$name" > "$CYBER_CURRENT_ENV_FILE" 2>/dev/null
    
    echo "✅ Environnement chargé: $name"
    echo "📝 Description: $desc"
    echo "📅 Créé: $created"
    echo "🎯 Cibles chargées: ${#CYBER_TARGETS[@]}"
    echo "📌 Notes: $notes_count | 📜 Historique: $history_count | 📊 Résultats: $results_count | ✅ TODOs: $todos_count ($todos_pending en attente)"
    if [ ${#CYBER_TARGETS[@]} -gt 0 ]; then
        show_targets
    else
        echo "⚠️  Aucune cible dans cet environnement"
    fi
    return 0
}

# DESC: Liste tous les environnements sauvegardés
# USAGE: list_environments
# EXAMPLE: list_environments
list_environments() {
    # Vérifier si le répertoire existe et contient des fichiers JSON
    if [ ! -d "$CYBER_ENV_DIR" ]; then
        echo "⚠️  Aucun environnement sauvegardé"
        return 1
    fi
    
    # Compter les fichiers JSON sans utiliser de glob qui pourrait échouer
    local json_count=$(find "$CYBER_ENV_DIR" -maxdepth 1 -name "*.json" -type f 2>/dev/null | wc -l)
    
    if [ "$json_count" -eq 0 ]; then
        echo "⚠️  Aucun environnement sauvegardé"
        return 1
    fi
    
    echo "📋 Environnements disponibles:"
    echo ""
    
    if command -v jq >/dev/null 2>&1; then
        local count=1
        # Utiliser find pour éviter les problèmes de glob pattern en Zsh
        while IFS= read -r env_file; do
            if [ -f "$env_file" ]; then
                local name=$(jq -r '.name' "$env_file" 2>/dev/null)
                local desc=$(jq -r '.description' "$env_file" 2>/dev/null)
                local created=$(jq -r '.created' "$env_file" 2>/dev/null)
                local targets_count=$(jq -r '.targets | length' "$env_file" 2>/dev/null)
                
                # Vérifier que les valeurs ne sont pas "null"
                [ "$name" = "null" ] && name=$(basename "$env_file" .json)
                [ "$desc" = "null" ] && desc="Pas de description"
                [ "$created" = "null" ] && created="Date inconnue"
                [ "$targets_count" = "null" ] && targets_count=0
                
                echo "  $count. $name"
                echo "     📝 $desc"
                echo "     📅 $created"
                echo "     🎯 $targets_count cible(s)"
                echo ""
                ((count++))
            fi
        done < <(find "$CYBER_ENV_DIR" -maxdepth 1 -name "*.json" -type f 2>/dev/null | sort)
    else
        # Fallback sans jq
        local count=1
        while IFS= read -r env_file; do
            if [ -f "$env_file" ]; then
                local basename=$(basename "$env_file" .json)
                echo "  $count. $basename"
                ((count++))
            fi
        done < <(find "$CYBER_ENV_DIR" -maxdepth 1 -name "*.json" -type f 2>/dev/null | sort)
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
        # Si l'environnement supprimé était l'environnement actif, le désactiver
        if [ "$CYBER_CURRENT_ENV" = "$name" ]; then
            CYBER_CURRENT_ENV=""
            rm -f "$CYBER_CURRENT_ENV_FILE" 2>/dev/null
        fi
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

# DESC: Restaure un environnement sauvegardé (alias de load_environment)
# USAGE: restore_environment <name>
# EXAMPLE: restore_environment "pentest_example_com"
restore_environment() {
    load_environment "$@"
}

# DESC: Supprime plusieurs environnements
# USAGE: delete_environments <name1> [name2...]
# EXAMPLE: delete_environments "env_test1" "env_test2"
delete_environments() {
    if [ $# -eq 0 ]; then
        echo "❌ Usage: delete_environments <name1> [name2...]"
        return 1
    fi

    local to_delete_names=("$@")
    local deleted_count=0
    local not_found_count=0

    echo "⚠️  Vous êtes sur le point de supprimer les environnements suivants:"
    for name in "${to_delete_names[@]}"; do
        echo "   - $name"
    done
    printf "Confirmer la suppression de ces ${#to_delete_names[@]} environnement(s)? (o/N): "
    read -r confirm

    if [ "$confirm" = "o" ] || [ "$confirm" = "O" ]; then
        for name in "${to_delete_names[@]}"; do
            local env_file="$CYBER_ENV_DIR/${name}.json"
            if [ -f "$env_file" ]; then
                rm "$env_file"
                echo "✅ Environnement supprimé: $name"
                ((deleted_count++))
                # Si l'environnement supprimé était l'environnement actif, le désactiver
                if [ "$CYBER_CURRENT_ENV" = "$name" ]; then
                    CYBER_CURRENT_ENV=""
                    rm -f "$CYBER_CURRENT_ENV_FILE" 2>/dev/null
                fi
            else
                echo "❌ Environnement non trouvé: $name"
                ((not_found_count++))
            fi
        done
        echo "📋 Résumé: $deleted_count supprimé(s), $not_found_count introuvable(s)."
        return 0
    else
        echo "❌ Suppression multiple annulée."
        return 1
    fi
}

# DESC: Obtient le nom de l'environnement actuellement chargé
# USAGE: get_current_environment
# EXAMPLE: get_current_environment
get_current_environment() {
    if [ -n "$CYBER_CURRENT_ENV" ]; then
        echo "$CYBER_CURRENT_ENV"
        return 0
    else
        return 1
    fi
}

# DESC: Vérifie si un environnement est actuellement chargé
# USAGE: has_active_environment
# EXAMPLE: has_active_environment
has_active_environment() {
    [ -n "$CYBER_CURRENT_ENV" ]
}

# DESC: Désactive l'environnement actif
# USAGE: deactivate_environment
# EXAMPLE: deactivate_environment
deactivate_environment() {
    if [ -z "$CYBER_CURRENT_ENV" ]; then
        echo "⚠️  Aucun environnement actif à désactiver"
        return 1
    fi
    
    local env_name="$CYBER_CURRENT_ENV"
    
    # Demander si on veut aussi supprimer les cibles
    printf "🗑️  Voulez-vous aussi supprimer les cibles de cet environnement? (o/N): "
    read -r remove_targets
    
    # Supprimer les cibles si demandé
    if [ "$remove_targets" = "o" ] || [ "$remove_targets" = "O" ]; then
        if [ -f "$CYBER_DIR/target_manager.sh" ]; then
            source "$CYBER_DIR/target_manager.sh" 2>/dev/null
            if has_targets 2>/dev/null; then
                clear_targets 2>/dev/null
                echo "✅ Cibles supprimées"
            fi
        fi
    fi
    
    # Supprimer le fichier de persistance
    rm -f "$CYBER_CURRENT_ENV_FILE" 2>/dev/null
    
    # Désactiver l'environnement en vidant la variable globale
    # Utiliser plusieurs méthodes pour s'assurer que ça fonctionne
    typeset -g CYBER_CURRENT_ENV=""
    eval "typeset -g CYBER_CURRENT_ENV=\"\""
    
    # Vérifier que la désactivation a bien fonctionné
    if [ -z "$CYBER_CURRENT_ENV" ] && [ ! -f "$CYBER_CURRENT_ENV_FILE" ]; then
        echo "✅ Environnement désactivé: $env_name"
        return 0
    else
        # Forcer la suppression si nécessaire
        typeset -g CYBER_CURRENT_ENV=""
        rm -f "$CYBER_CURRENT_ENV_FILE" 2>/dev/null
        echo "✅ Environnement désactivé: $env_name (forcé)"
        return 0
    fi
}

# DESC: Exporte un environnement vers un fichier JSON
# USAGE: export_environment <name> [output_file]
# EXAMPLE: export_environment "pentest_example_com" ~/backup_env.json
export_environment() {
    local name="$1"
    local output_file="${2:-${name}_export_$(date +%Y%m%d_%H%M%S).json}"
    
    if [ -z "$name" ]; then
        echo "❌ Usage: export_environment <name> [output_file]"
        return 1
    fi
    
    local env_file="$CYBER_ENV_DIR/${name}.json"
    
    if [ ! -f "$env_file" ]; then
        echo "❌ Environnement non trouvé: $name"
        return 1
    fi
    
    cp "$env_file" "$output_file"
    echo "✅ Environnement exporté: $output_file"
    return 0
}

# DESC: Importe un environnement depuis un fichier JSON
# USAGE: import_environment <input_file> [new_name]
# EXAMPLE: import_environment ~/backup_env.json "pentest_restored"
import_environment() {
    local input_file="$1"
    local new_name="$2"
    
    if [ -z "$input_file" ]; then
        echo "❌ Usage: import_environment <input_file> [new_name]"
        return 1
    fi
    
    if [ ! -f "$input_file" ]; then
        echo "❌ Fichier non trouvé: $input_file"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis pour importer les environnements"
        return 1
    fi
    
    # Vérifier que c'est un JSON valide
    if ! jq empty "$input_file" 2>/dev/null; then
        echo "❌ Fichier JSON invalide: $input_file"
        return 1
    fi
    
    # Si un nouveau nom est fourni, modifier le nom dans le JSON
    if [ -n "$new_name" ]; then
        local env_file="$CYBER_ENV_DIR/${new_name}.json"
        jq ".name = \"$new_name\"" "$input_file" > "$env_file"
        echo "✅ Environnement importé avec le nom: $new_name"
    else
        # Utiliser le nom du fichier source
        local name=$(jq -r '.name' "$input_file")
        if [ -z "$name" ] || [ "$name" = "null" ]; then
            name=$(basename "$input_file" .json)
        fi
        local env_file="$CYBER_ENV_DIR/${name}.json"
        
        # Demander confirmation si l'environnement existe déjà
        if [ -f "$env_file" ]; then
            printf "⚠️  L'environnement '$name' existe déjà. Remplacer? (o/N): "
            read -r confirm
            if [ "$confirm" != "o" ] && [ "$confirm" != "O" ]; then
                echo "❌ Import annulé"
                return 1
            fi
        fi
        
        cp "$input_file" "$env_file"
        echo "✅ Environnement importé: $name"
    fi
    
    return 0
}

# DESC: Enregistre automatiquement un résultat dans l'environnement actif (helper)
# USAGE: _auto_save_result <action_type> <description> <result_data> [status]
# EXAMPLE: _auto_save_result "whois" "WHOIS lookup" "Domain info..." "success"
_auto_save_result() {
    local action_type="$1"
    local description="$2"
    local result_data="$3"
    local status="${4:-success}"
    
    if [ -z "$action_type" ] || [ -z "$description" ]; then
        return 1
    fi
    
    # Vérifier si un environnement est actif
    if [ -z "${CYBER_CURRENT_ENV}" ]; then
        return 0  # Pas d'erreur, juste pas d'environnement actif
    fi
    
    # Enregistrer l'action et le résultat
    add_environment_action "$CYBER_CURRENT_ENV" "$action_type" "$description" "$result_data" 2>/dev/null
    add_environment_result "$CYBER_CURRENT_ENV" "${action_type}_$(date +%s)" "$result_data" "$status" 2>/dev/null
    
    return 0
}

# DESC: Ajoute une note à un environnement
# USAGE: add_environment_note <env_name> <note_text>
# EXAMPLE: add_environment_note "pentest_example" "Découverte d'une vulnérabilité SQLi sur /login"
add_environment_note() {
    local env_name="$1"
    local note_text="$2"
    
    if [ -z "$env_name" ] || [ -z "$note_text" ]; then
        echo "❌ Usage: add_environment_note <env_name> <note_text>"
        return 1
    fi
    
    local env_file="$CYBER_ENV_DIR/${env_name}.json"
    
    if [ ! -f "$env_file" ]; then
        echo "❌ Environnement non trouvé: $env_name"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis pour ajouter des notes"
        return 1
    fi
    
    # Ajouter la note avec timestamp
    local temp_file=$(mktemp)
    jq --arg note "$note_text" \
       --arg timestamp "$(date -Iseconds)" \
       '.notes += [{
           text: $note,
           timestamp: $timestamp,
           author: env.USER
       }] | .metadata.last_updated = $timestamp' \
       "$env_file" > "$temp_file" 2>/dev/null
    
    if [ $? -eq 0 ] && jq empty "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$env_file"
        echo "✅ Note ajoutée à l'environnement: $env_name"
        return 0
    else
        rm -f "$temp_file"
        echo "❌ Erreur lors de l'ajout de la note"
        return 1
    fi
}

# DESC: Ajoute une action à l'historique d'un environnement
# USAGE: add_environment_action <env_name> <action_type> <action_description> [result]
# EXAMPLE: add_environment_action "pentest_example" "scan" "Scan de ports avec nmap" "Ports 80,443 ouverts"
add_environment_action() {
    local env_name="$1"
    local action_type="$2"
    local action_desc="$3"
    local result="${4:-}"
    
    if [ -z "$env_name" ] || [ -z "$action_type" ] || [ -z "$action_desc" ]; then
        echo "❌ Usage: add_environment_action <env_name> <action_type> <action_description> [result]"
        return 1
    fi
    
    local env_file="$CYBER_ENV_DIR/${env_name}.json"
    
    if [ ! -f "$env_file" ]; then
        echo "❌ Environnement non trouvé: $env_name"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis pour ajouter des actions"
        return 1
    fi
    
    # Ajouter l'action à l'historique
    local temp_file=$(mktemp)
    jq --arg type "$action_type" \
       --arg desc "$action_desc" \
       --arg result "$result" \
       --arg timestamp "$(date -Iseconds)" \
       '.history += [{
           type: $type,
           description: $desc,
           result: $result,
           timestamp: $timestamp,
           user: env.USER
       }] | .metadata.last_updated = $timestamp' \
       "$env_file" > "$temp_file" 2>/dev/null
    
    if [ $? -eq 0 ] && jq empty "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$env_file"
        return 0
    else
        rm -f "$temp_file"
        echo "❌ Erreur lors de l'ajout de l'action"
        return 1
    fi
}

# DESC: Ajoute un résultat de test/analyse à un environnement
# USAGE: add_environment_result <env_name> <test_name> <result_data> [status]
# EXAMPLE: add_environment_result "pentest_example" "nmap_scan" "Ports 80,443 ouverts" "success"
add_environment_result() {
    local env_name="$1"
    local test_name="$2"
    local result_data="$3"
    local status="${4:-completed}"
    
    if [ -z "$env_name" ] || [ -z "$test_name" ] || [ -z "$result_data" ]; then
        echo "❌ Usage: add_environment_result <env_name> <test_name> <result_data> [status]"
        return 1
    fi
    
    local env_file="$CYBER_ENV_DIR/${env_name}.json"
    
    if [ ! -f "$env_file" ]; then
        echo "❌ Environnement non trouvé: $env_name"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis pour ajouter des résultats"
        return 1
    fi
    
    # Ajouter le résultat
    local temp_file=$(mktemp)
    jq --arg test "$test_name" \
       --arg data "$result_data" \
       --arg status "$status" \
       --arg timestamp "$(date -Iseconds)" \
       '.results += [{
           test_name: $test,
           result: $data,
           status: $status,
           timestamp: $timestamp,
           user: env.USER
       }] | .metadata.last_updated = $timestamp' \
       "$env_file" > "$temp_file" 2>/dev/null
    
    if [ $? -eq 0 ] && jq empty "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$env_file"
        echo "✅ Résultat ajouté à l'environnement: $env_name"
        return 0
    else
        rm -f "$temp_file"
        echo "❌ Erreur lors de l'ajout du résultat"
        return 1
    fi
}

# DESC: Affiche les notes d'un environnement
# USAGE: show_environment_notes <env_name>
# EXAMPLE: show_environment_notes "pentest_example"
show_environment_notes() {
    local env_name="$1"
    
    if [ -z "$env_name" ]; then
        echo "❌ Usage: show_environment_notes <env_name>"
        return 1
    fi
    
    local env_file="$CYBER_ENV_DIR/${env_name}.json"
    
    if [ ! -f "$env_file" ]; then
        echo "❌ Environnement non trouvé: $env_name"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis"
        return 1
    fi
    
    local notes_count=$(jq '.notes | length' "$env_file")
    
    if [ "$notes_count" -eq 0 ]; then
        echo "📝 Aucune note pour l'environnement: $env_name"
        return 0
    fi
    
    echo "📝 Notes de l'environnement: $env_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    jq -r '.notes[] | "📌 \(.timestamp) - \(.author)\n   \(.text)\n"' "$env_file"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    return 0
}

# DESC: Affiche l'historique des actions d'un environnement
# USAGE: show_environment_history <env_name>
# EXAMPLE: show_environment_history "pentest_example"
show_environment_history() {
    local env_name="$1"
    
    if [ -z "$env_name" ]; then
        echo "❌ Usage: show_environment_history <env_name>"
        return 1
    fi
    
    local env_file="$CYBER_ENV_DIR/${env_name}.json"
    
    if [ ! -f "$env_file" ]; then
        echo "❌ Environnement non trouvé: $env_name"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis"
        return 1
    fi
    
    local history_count=$(jq '.history | length' "$env_file")
    
    if [ "$history_count" -eq 0 ]; then
        echo "📜 Aucun historique pour l'environnement: $env_name"
        return 0
    fi
    
    echo "📜 Historique des actions - Environnement: $env_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    jq -r '.history[] | "🔹 [\(.type)] \(.timestamp) - \(.user)\n   \(.description)\n   \(if .result != "" then "   📊 Résultat: \(.result)" else "" end)\n"' "$env_file"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    return 0
}

# DESC: Affiche les résultats de tests d'un environnement
# USAGE: show_environment_results <env_name>
# EXAMPLE: show_environment_results "pentest_example"
show_environment_results() {
    local env_name="$1"
    
    if [ -z "$env_name" ]; then
        echo "❌ Usage: show_environment_results <env_name>"
        return 1
    fi
    
    local env_file="$CYBER_ENV_DIR/${env_name}.json"
    
    if [ ! -f "$env_file" ]; then
        echo "❌ Environnement non trouvé: $env_name"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis"
        return 1
    fi
    
    local results_count=$(jq '.results | length' "$env_file")
    
    if [ "$results_count" -eq 0 ]; then
        echo "📊 Aucun résultat pour l'environnement: $env_name"
        return 0
    fi
    
    echo "📊 Résultats de tests - Environnement: $env_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    jq -r '.results[] | "🧪 [\(.test_name)] \(.timestamp) - \(.status)\n   \(.result)\n"' "$env_file"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    return 0
}

# DESC: Ajoute un TODO à un environnement
# USAGE: add_environment_todo <env_name> <todo_text> [priority]
# EXAMPLE: add_environment_todo "pentest_example" "Vérifier vulnérabilité SQLi" "high"
add_environment_todo() {
    local env_name="$1"
    local todo_text="$2"
    local priority="${3:-medium}"
    
    if [ -z "$env_name" ] || [ -z "$todo_text" ]; then
        echo "❌ Usage: add_environment_todo <env_name> <todo_text> [priority: low|medium|high]"
        return 1
    fi
    
    local env_file="$CYBER_ENV_DIR/${env_name}.json"
    
    if [ ! -f "$env_file" ]; then
        echo "❌ Environnement non trouvé: $env_name"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis pour ajouter des TODOs"
        return 1
    fi
    
    # S'assurer que todos existe
    local temp_check=$(mktemp)
    jq '.todos //= []' "$env_file" > "$temp_check" 2>/dev/null
    if [ $? -eq 0 ]; then
        mv "$temp_check" "$env_file"
    else
        rm -f "$temp_check"
    fi
    
    # Ajouter le TODO avec timestamp
    local temp_file=$(mktemp)
    jq --arg todo "$todo_text" \
       --arg priority "$priority" \
       --arg timestamp "$(date -Iseconds)" \
       '.todos += [{
           text: $todo,
           priority: $priority,
           status: "pending",
           timestamp: $timestamp,
           author: env.USER
       }] | .metadata.last_updated = $timestamp' \
       "$env_file" > "$temp_file" 2>/dev/null
    
    if [ $? -eq 0 ] && jq empty "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$env_file"
        echo "✅ TODO ajouté à l'environnement: $env_name"
        return 0
    else
        rm -f "$temp_file"
        echo "❌ Erreur lors de l'ajout du TODO"
        return 1
    fi
}

# DESC: Marque un TODO comme complété
# USAGE: complete_environment_todo <env_name> <todo_index>
# EXAMPLE: complete_environment_todo "pentest_example" 1
complete_environment_todo() {
    local env_name="$1"
    local todo_index="$2"
    
    if [ -z "$env_name" ] || [ -z "$todo_index" ]; then
        echo "❌ Usage: complete_environment_todo <env_name> <todo_index>"
        return 1
    fi
    
    local env_file="$CYBER_ENV_DIR/${env_name}.json"
    
    if [ ! -f "$env_file" ]; then
        echo "❌ Environnement non trouvé: $env_name"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis"
        return 1
    fi
    
    # Marquer le TODO comme complété (index 0-based)
    local temp_file=$(mktemp)
    jq --argjson index "$((todo_index - 1))" \
       --arg timestamp "$(date -Iseconds)" \
       '.todos[$index].status = "completed" | .todos[$index].completed_at = $timestamp | .metadata.last_updated = $timestamp' \
       "$env_file" > "$temp_file" 2>/dev/null
    
    if [ $? -eq 0 ] && jq empty "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$env_file"
        echo "✅ TODO marqué comme complété"
        return 0
    else
        rm -f "$temp_file"
        echo "❌ Erreur lors de la mise à jour du TODO"
        return 1
    fi
}

# DESC: Affiche les TODOs d'un environnement
# USAGE: show_environment_todos <env_name>
# EXAMPLE: show_environment_todos "pentest_example"
show_environment_todos() {
    local env_name="$1"
    
    if [ -z "$env_name" ]; then
        echo "❌ Usage: show_environment_todos <env_name>"
        return 1
    fi
    
    local env_file="$CYBER_ENV_DIR/${env_name}.json"
    
    if [ ! -f "$env_file" ]; then
        echo "❌ Environnement non trouvé: $env_name"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis"
        return 1
    fi
    
    # S'assurer que todos existe
    local temp_check=$(mktemp)
    jq '.todos //= []' "$env_file" > "$temp_check" 2>/dev/null
    if [ $? -eq 0 ]; then
        mv "$temp_check" "$env_file"
    else
        rm -f "$temp_check"
    fi
    
    local todos_count=$(jq '.todos | length' "$env_file" 2>/dev/null || echo "0")
    
    if [ "$todos_count" -eq 0 ]; then
        echo "📝 Aucun TODO pour l'environnement: $env_name"
        return 0
    fi
    
    echo "📝 TODOs de l'environnement: $env_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    local index=1
    jq -r '.todos[] | "\(.status)|\(.priority)|\(.timestamp)|\(.text)"' "$env_file" 2>/dev/null | while IFS='|' read -r status priority timestamp text; do
        local status_icon="⏳"
        local priority_color=""
        [ "$status" = "completed" ] && status_icon="✅"
        [ "$priority" = "high" ] && priority_color="🔴"
        [ "$priority" = "medium" ] && priority_color="🟡"
        [ "$priority" = "low" ] && priority_color="🟢"
        echo "  $index. $status_icon $priority_color [$priority] $text"
        echo "     📅 $timestamp"
        ((index++))
    done
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    return 0
}

# DESC: Affiche le menu de gestion des TODOs
# USAGE: show_todos_menu <env_name>
# EXAMPLE: show_todos_menu "pentest_example"
show_todos_menu() {
    local env_name="$1"
    
    if [ -z "$env_name" ]; then
        echo "❌ Usage: show_todos_menu <env_name>"
        return 1
    fi
    
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
        echo "║              GESTION DES TODOs - CYBERMAN                      ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo ""
        echo -e "${YELLOW}📋 Environnement: ${BOLD}${env_name}${RESET}"
        echo ""
        
        show_environment_todos "$env_name"
        echo ""
        
        echo -e "${BLUE}Menu:${RESET}"
        echo "1.  Ajouter un TODO"
        echo "2.  Marquer un TODO comme complété"
        echo "3.  Voir les TODOs en attente"
        echo "4.  Voir les TODOs complétés"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                echo ""
                printf "📝 Texte du TODO: "
                read -r todo_text
                if [ -z "$todo_text" ]; then
                    echo "❌ Texte requis"
                    sleep 1
                    continue
                fi
                echo ""
                echo "Priorité:"
                echo "  1. Basse (low)"
                echo "  2. Moyenne (medium)"
                echo "  3. Haute (high)"
                printf "Choix (1-3, défaut: 2): "
                read -r priority_choice
                local priority="medium"
                case "$priority_choice" in
                    1) priority="low" ;;
                    3) priority="high" ;;
                    *) priority="medium" ;;
                esac
                add_environment_todo "$env_name" "$todo_text" "$priority"
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2)
                echo ""
                show_environment_todos "$env_name"
                echo ""
                printf "📝 Index du TODO à marquer comme complété: "
                read -r todo_index
                if [ -n "$todo_index" ] && [ "$todo_index" -gt 0 ]; then
                    complete_environment_todo "$env_name" "$todo_index"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3)
                echo ""
                echo "📝 TODOs en attente:"
                local env_file="$CYBER_ENV_DIR/${env_name}.json"
                if [ -f "$env_file" ] && command -v jq >/dev/null 2>&1; then
                    local index=1
                    jq -r '.todos[] | select(.status == "pending") | "\(.priority)|\(.timestamp)|\(.text)"' "$env_file" 2>/dev/null | while IFS='|' read -r priority timestamp text; do
                        local priority_color=""
                        [ "$priority" = "high" ] && priority_color="🔴"
                        [ "$priority" = "medium" ] && priority_color="🟡"
                        [ "$priority" = "low" ] && priority_color="🟢"
                        echo "  $index. $priority_color [$priority] $text"
                        echo "     📅 $timestamp"
                        ((index++))
                    done
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4)
                echo ""
                echo "✅ TODOs complétés:"
                local env_file="$CYBER_ENV_DIR/${env_name}.json"
                if [ -f "$env_file" ] && command -v jq >/dev/null 2>&1; then
                    jq -r '.todos[] | select(.status == "completed") | "✅ \(.text)\n   📅 Complété: \(.completed_at // .timestamp)\n"' "$env_file" 2>/dev/null
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            0) return 0 ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
}

# DESC: Charge et affiche toutes les informations d'un environnement de manière interactive
# USAGE: load_infos <env_name>
# EXAMPLE: load_infos "pentest_example"
# EXAMPLE: cyberman load_infos pentest_example
load_infos() {
    local env_name="$1"
    
    if [ -z "$env_name" ]; then
        echo "❌ Usage: load_infos <env_name>"
        echo "💡 Exemple: load_infos pentest_example"
        echo "💡 Ou: cyberman load_infos pentest_example"
        return 1
    fi
    
    local env_file="$CYBER_ENV_DIR/${env_name}.json"
    
    if [ ! -f "$env_file" ]; then
        echo "❌ Environnement non trouvé: $env_name"
        echo "💡 Liste des environnements disponibles:"
        list_environments
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq requis pour afficher les informations"
        return 1
    fi
    
    # Charger l'environnement d'abord
    load_environment "$env_name" 2>/dev/null || {
        echo "⚠️  Impossible de charger l'environnement, mais affichage des informations..."
    }
    
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
        echo "║           INFORMATIONS ENVIRONNEMENT - CYBERMAN                ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo ""
        
        # Informations de base
        local desc=$(jq -r '.description // "N/A"' "$env_file")
        local created=$(jq -r '.created // "N/A"' "$env_file")
        local notes_count=$(jq '.notes | length' "$env_file" 2>/dev/null || echo "0")
        local history_count=$(jq '.history | length' "$env_file" 2>/dev/null || echo "0")
        local results_count=$(jq '.results | length' "$env_file" 2>/dev/null || echo "0")
        local targets_count=$(jq '.targets | length' "$env_file" 2>/dev/null || echo "0")
        
        echo -e "${YELLOW}📋 Environnement: ${BOLD}${env_name}${RESET}"
        echo -e "   📝 Description: $desc"
        echo -e "   📅 Créé: $created"
        echo ""
        echo -e "${GREEN}📊 Statistiques:${RESET}"
        echo -e "   🎯 Cibles: $targets_count"
        echo -e "   📌 Notes: $notes_count"
        echo -e "   📜 Actions: $history_count"
        echo -e "   📊 Résultats: $results_count"
        echo ""
        
        # Afficher les cibles
        if [ "$targets_count" -gt 0 ]; then
            echo -e "${CYAN}🎯 Cibles:${RESET}"
            jq -r '.targets[]' "$env_file" | while IFS= read -r target; do
                echo -e "   • $target"
            done
            echo ""
        fi
        
        echo -e "${BLUE}Menu de navigation:${RESET}"
        echo "1.  Voir toutes les notes"
        echo "2.  Voir l'historique complet des actions"
        echo "3.  Voir tous les résultats de tests"
        echo "4.  Voir les détails complets (JSON)"
        echo "5.  Rechercher dans les informations"
        echo "6.  Exporter toutes les informations"
        echo "0.  Retour"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                echo ""
                show_environment_notes "$env_name"
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2)
                echo ""
                show_environment_history "$env_name"
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3)
                echo ""
                show_environment_results "$env_name"
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4)
                echo ""
                echo -e "${CYAN}📄 Détails complets (JSON):${RESET}"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                jq '.' "$env_file" | less -R
                ;;
            5)
                echo ""
                printf "🔍 Rechercher: "
                read -r search_term
                if [ -n "$search_term" ]; then
                    echo ""
                    echo -e "${CYAN}Résultats de recherche pour: ${BOLD}$search_term${RESET}"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    # Rechercher dans les notes
                    jq -r --arg term "$search_term" '.notes[] | select(.text | contains($term)) | "📌 Note: \(.text)\n   Date: \(.timestamp)\n"' "$env_file" 2>/dev/null
                    # Rechercher dans l'historique
                    jq -r --arg term "$search_term" '.history[] | select(.description | contains($term) or .result | contains($term)) | "📜 Action: \(.description)\n   Résultat: \(.result)\n   Date: \(.timestamp)\n"' "$env_file" 2>/dev/null
                    # Rechercher dans les résultats
                    jq -r --arg term "$search_term" '.results[] | select(.test_name | contains($term) or .result | contains($term)) | "🧪 Test: \(.test_name)\n   Résultat: \(.result)\n   Date: \(.timestamp)\n"' "$env_file" 2>/dev/null
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            6)
                echo ""
                local export_file="${env_name}_export_$(date +%Y%m%d_%H%M%S).txt"
                {
                    echo "════════════════════════════════════════════════════════════════"
                    echo "EXPORT COMPLET - ENVIRONNEMENT: $env_name"
                    echo "════════════════════════════════════════════════════════════════"
                    echo ""
                    echo "Description: $desc"
                    echo "Créé: $created"
                    echo ""
                    echo "════════════════════════════════════════════════════════════════"
                    echo "CIBLES"
                    echo "════════════════════════════════════════════════════════════════"
                    jq -r '.targets[]' "$env_file"
                    echo ""
                    echo "════════════════════════════════════════════════════════════════"
                    echo "NOTES"
                    echo "════════════════════════════════════════════════════════════════"
                    jq -r '.notes[] | "\(.timestamp) - \(.author)\n\(.text)\n"' "$env_file"
                    echo ""
                    echo "════════════════════════════════════════════════════════════════"
                    echo "HISTORIQUE DES ACTIONS"
                    echo "════════════════════════════════════════════════════════════════"
                    jq -r '.history[] | "[\(.type)] \(.timestamp) - \(.user)\n\(.description)\nRésultat: \(.result)\n"' "$env_file"
                    echo ""
                    echo "════════════════════════════════════════════════════════════════"
                    echo "RÉSULTATS DE TESTS"
                    echo "════════════════════════════════════════════════════════════════"
                    jq -r '.results[] | "[\(.test_name)] \(.timestamp) - \(.status)\n\(.result)\n"' "$env_file"
                } > "$export_file"
                echo "✅ Export créé: $export_file"
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            0) return 0 ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
}

# DESC: Affiche le menu interactif de gestion des environnements
# USAGE: show_environment_menu
# EXAMPLE: show_environment_menu
show_environment_menu() {
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
        echo "║           GESTION DES ENVIRONNEMENTS - CYBERMAN                ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo ""
        
        # Afficher l'état actuel
        echo -e "${YELLOW}📊 État actuel:${RESET}"
        
        # Afficher l'environnement actif
        if has_active_environment 2>/dev/null; then
            local current_env=$(get_current_environment 2>/dev/null)
            echo -e "   ${GREEN}🌍 Environnement actif: ${BOLD}${current_env}${RESET}"
            
            # Afficher les statistiques de l'environnement actif
            local env_file="$CYBER_ENV_DIR/${current_env}.json"
            if [ -f "$env_file" ] && command -v jq >/dev/null 2>&1; then
                local notes_count=$(jq '.notes | length' "$env_file" 2>/dev/null || echo "0")
                local history_count=$(jq '.history | length' "$env_file" 2>/dev/null || echo "0")
                local results_count=$(jq '.results | length' "$env_file" 2>/dev/null || echo "0")
                local todos_count=$(jq '.todos | length' "$env_file" 2>/dev/null || echo "0")
                local todos_pending=$(jq '[.todos[]? | select(.status == "pending")] | length' "$env_file" 2>/dev/null || echo "0")
                echo -e "      📌 Notes: ${notes_count} | 📜 Actions: ${history_count} | 📊 Résultats: ${results_count} | ✅ TODOs: ${todos_count} (${todos_pending} en attente)"
            fi
        else
            echo -e "   ${YELLOW}🌍 Aucun environnement actif${RESET}"
        fi
        
        # Afficher les cibles
        if [ -f "$CYBER_DIR/target_manager.sh" ]; then
            source "$CYBER_DIR/target_manager.sh" 2>/dev/null
            if has_targets 2>/dev/null; then
                show_targets 2>/dev/null
            else
                echo "  ⚠️  Aucune cible configurée"
            fi
        else
            echo "  ⚠️  Gestionnaire de cibles non disponible"
        fi
        echo ""
        
        # Lister les environnements (peut retourner 1 si aucun environnement)
        if ! list_environments 2>/dev/null; then
            # Si aucun environnement, afficher un message mais continuer
            echo ""
        fi
        echo ""
        echo "1.  Sauvegarder l'environnement actuel"
        echo "2.  Créer un nouvel environnement (avec gestion de cibles)"
        echo "3.  Charger un environnement"
        echo "4.  Restaurer un environnement"
        echo "5.  Afficher les détails d'un environnement"
        echo "6.  Supprimer un environnement"
        echo "7.  Supprimer plusieurs environnements"
        echo "8.  Exporter un environnement"
        echo "9.  Importer un environnement"
        echo "10. Gérer les cibles (ajouter/modifier)"
        echo "11. Lister tous les environnements"
        echo "12. Ajouter une note à un environnement"
        echo "13. Voir les notes d'un environnement"
        echo "14. Voir l'historique des actions"
        echo "15. Voir les résultats de tests"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                echo ""
                # Vérifier si des cibles sont configurées
                if [ -f "$CYBER_DIR/target_manager.sh" ]; then
                    source "$CYBER_DIR/target_manager.sh" 2>/dev/null
                    if ! has_targets 2>/dev/null; then
                        echo "⚠️  Aucune cible configurée actuellement"
                        printf "Voulez-vous ajouter des cibles maintenant? (O/n): "
                        read -r add_now
                        if [ "$add_now" != "n" ] && [ "$add_now" != "N" ]; then
                            echo ""
                            printf "🎯 Entrez les cibles (séparées par des espaces): "
                            read -r targets_input
                            if [ -n "$targets_input" ]; then
                                add_target $targets_input 2>/dev/null
                            fi
                        fi
                    fi
                fi
                echo ""
                printf "📝 Nom de l'environnement: "
                read -r name
                if [ -n "$name" ]; then
                    printf "📝 Description (optionnel): "
                    read -r desc
                    save_environment "$name" "$desc"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2)
                echo ""
                echo "📝 Création d'un nouvel environnement"
                echo ""
                printf "📝 Nom de l'environnement: "
                read -r name
                if [ -z "$name" ]; then
                    echo "❌ Nom requis"
                    sleep 1
                    continue
                fi
                printf "📝 Description (optionnel): "
                read -r desc
                echo ""
                echo "🎯 Gestion des cibles:"
                echo "  1. Ajouter des cibles maintenant"
                echo "  2. Utiliser les cibles actuelles (si disponibles)"
                echo "  3. Créer sans cibles (vide)"
                printf "Choix: "
                read -r target_choice
                echo ""
                
                # Charger le gestionnaire de cibles
                if [ -f "$CYBER_DIR/target_manager.sh" ]; then
                    source "$CYBER_DIR/target_manager.sh" 2>/dev/null
                    
                    case "$target_choice" in
                        1)
                            printf "🎯 Entrez les cibles (séparées par des espaces): "
                            read -r targets_input
                            if [ -n "$targets_input" ]; then
                                # Sauvegarder les cibles actuelles temporairement
                                local old_targets=("${CYBER_TARGETS[@]}")
                                clear_targets 2>/dev/null
                                add_target $targets_input 2>/dev/null
                                save_environment "$name" "$desc"
                                # Restaurer les anciennes cibles
                                CYBER_TARGETS=("${old_targets[@]}")
                                _save_targets_to_file 2>/dev/null
                            else
                                echo "❌ Aucune cible fournie"
                            fi
                            ;;
                        2)
                            if has_targets 2>/dev/null; then
                                save_environment "$name" "$desc"
                            else
                                echo "⚠️  Aucune cible actuelle. Création d'environnement vide."
                                local old_targets=("${CYBER_TARGETS[@]}")
                                CYBER_TARGETS=()
                                save_environment "$name" "$desc"
                                CYBER_TARGETS=("${old_targets[@]}")
                                _save_targets_to_file 2>/dev/null
                            fi
                            ;;
                        3)
                            local old_targets=("${CYBER_TARGETS[@]}")
                            CYBER_TARGETS=()
                            save_environment "$name" "$desc"
                            CYBER_TARGETS=("${old_targets[@]}")
                            _save_targets_to_file 2>/dev/null
                            ;;
                        *)
                            echo "❌ Choix invalide"
                            ;;
                    esac
                else
                    echo "❌ Gestionnaire de cibles non disponible"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3)
                echo ""
                list_environments
                echo ""
                printf "📂 Nom de l'environnement à charger: "
                read -r name
                if [ -n "$name" ]; then
                    load_environment "$name"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4)
                echo ""
                list_environments
                echo ""
                printf "📂 Nom de l'environnement à restaurer: "
                read -r name
                if [ -n "$name" ]; then
                    restore_environment "$name"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            5)
                echo ""
                list_environments
                echo ""
                printf "📋 Nom de l'environnement: "
                read -r name
                if [ -n "$name" ]; then
                    show_environment "$name"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            6)
                echo ""
                list_environments
                echo ""
                printf "🗑️  Nom de l'environnement à supprimer: "
                read -r name
                if [ -n "$name" ]; then
                    delete_environment "$name"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            7)
                echo ""
                list_environments
                echo ""
                echo "📝 Entrez les noms des environnements à supprimer (séparés par des espaces):"
                echo "   Exemple: env1 env2 env3"
                printf "Environnements: "
                read -r env_names
                if [ -n "$env_names" ]; then
                    delete_environments $env_names
                else
                    echo "❌ Aucun nom d'environnement spécifié"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            8)
                echo ""
                list_environments
                echo ""
                printf "📤 Nom de l'environnement à exporter: "
                read -r name
                if [ -n "$name" ]; then
                    printf "📄 Fichier de sortie (optionnel): "
                    read -r output_file
                    export_environment "$name" "$output_file"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            9)
                echo ""
                printf "📥 Chemin du fichier JSON à importer: "
                read -r input_file
                if [ -n "$input_file" ]; then
                    printf "📝 Nouveau nom (optionnel, laisse vide pour garder le nom original): "
                    read -r new_name
                    import_environment "$input_file" "$new_name"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            10)
                echo ""
                if [ -f "$CYBER_DIR/target_manager.sh" ]; then
                    source "$CYBER_DIR/target_manager.sh" 2>/dev/null
                    show_target_menu
                else
                    echo "❌ Gestionnaire de cibles non disponible"
                    echo ""
                    read -k 1 "?Appuyez sur une touche pour continuer..."
                fi
                ;;
            11)
                list_environments
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            12)
                echo ""
                list_environments
                echo ""
                printf "📝 Nom de l'environnement: "
                read -r env_name
                if [ -n "$env_name" ]; then
                    echo "💬 Entrez votre note (appuyez sur Entrée puis Ctrl+D pour terminer):"
                    local note_text=$(cat)
                    if [ -n "$note_text" ]; then
                        add_environment_note "$env_name" "$note_text"
                    else
                        echo "❌ Note vide, annulé"
                    fi
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            13)
                echo ""
                list_environments
                echo ""
                printf "📝 Nom de l'environnement: "
                read -r env_name
                if [ -n "$env_name" ]; then
                    echo ""
                    show_environment_notes "$env_name"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            14)
                echo ""
                list_environments
                echo ""
                printf "📝 Nom de l'environnement: "
                read -r env_name
                if [ -n "$env_name" ]; then
                    echo ""
                    show_environment_history "$env_name"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            15)
                echo ""
                list_environments
                echo ""
                printf "📝 Nom de l'environnement: "
                read -r env_name
                if [ -n "$env_name" ]; then
                    echo ""
                    show_environment_results "$env_name"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
}

