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
            metadata: {
                user: $user,
                hostname: $hostname
            }
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
    
    # Sauvegarder les cibles chargées dans le fichier de persistance
    if typeset -f _save_targets_to_file >/dev/null 2>&1; then
        _save_targets_to_file
    elif [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
        if typeset -f _save_targets_to_file >/dev/null 2>&1; then
            _save_targets_to_file
        fi
    fi
    
    # Définir l'environnement actuel
    CYBER_CURRENT_ENV="$name"
    
    echo "✅ Environnement chargé: $name"
    echo "📝 Description: $desc"
    echo "📅 Créé: $created"
    echo "🎯 Cibles chargées: ${#CYBER_TARGETS[@]}"
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
        
        list_environments
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
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
}

