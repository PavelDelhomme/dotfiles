#!/bin/zsh
# =============================================================================
# MANAGEMENT MENU - Menu principal de gestion pour cyberman
# =============================================================================
# Description: Menu principal qui regroupe tous les menus de gestion
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger les dépendances
# Utiliser CYBER_DIR défini dans cyberman.zsh, sinon utiliser le chemin par défaut
CYBER_DIR="${CYBER_DIR:-$HOME/dotfiles/zsh/functions/cyberman/modules/legacy}"

# Charger tous les gestionnaires
if [ -f "$CYBER_DIR/target_manager.sh" ]; then
    source "$CYBER_DIR/target_manager.sh" 2>/dev/null
fi
if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
    source "$CYBER_DIR/environment_manager.sh" 2>/dev/null
fi
if [ -f "$CYBER_DIR/workflow_manager.sh" ]; then
    source "$CYBER_DIR/workflow_manager.sh" 2>/dev/null
fi
if [ -f "$CYBER_DIR/report_manager.sh" ]; then
    source "$CYBER_DIR/report_manager.sh" 2>/dev/null
fi
if [ -f "$CYBER_DIR/anonymity_manager.sh" ]; then
    source "$CYBER_DIR/anonymity_manager.sh" 2>/dev/null
fi

# Si show_target_menu n'est pas défini, le définir ici
if ! type show_target_menu >/dev/null 2>&1; then
    show_target_menu() {
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
            echo "║                  GESTION DES CIBLES                            ║"
            echo "╚════════════════════════════════════════════════════════════════╝"
            echo -e "${RESET}"
            echo ""
            
            if has_targets 2>/dev/null; then
                show_targets 2>/dev/null
                echo ""
            else
                echo "⚠️  Aucune cible configurée"
                echo ""
            fi
            
            echo "1.  Ajouter une cible"
            echo "2.  Ajouter plusieurs cibles"
            echo "3.  Supprimer une cible"
            echo "4.  Vider toutes les cibles"
            echo "5.  Afficher les cibles"
            echo "0.  Retour"
            echo ""
            printf "Choix: "
            read -r choice
            choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
            
            case "$choice" in
                1)
                    echo ""
                    printf "🎯 Entrez la cible (IP, domaine ou URL): "
                    read -r target
                    if [ -n "$target" ]; then
                        add_target "$target" 2>/dev/null
                        echo ""
                        read -k 1 "?Appuyez sur une touche pour continuer..."
                    fi
                    ;;
                2)
                    echo ""
                    echo "🎯 Entrez les cibles (séparées par des espaces): "
                    echo "Exemple: 192.168.1.1 192.168.1.2 example.com"
                    printf "Cibles: "
                    read -r targets
                    if [ -n "$targets" ]; then
                        add_target $targets 2>/dev/null
                        echo ""
                        read -k 1 "?Appuyez sur une touche pour continuer..."
                    fi
                    ;;
                3)
                    if has_targets 2>/dev/null; then
                        echo ""
                        show_targets 2>/dev/null
                        echo ""
                        printf "🎯 Entrez l'index ou le nom de la cible à supprimer: "
                        read -r target
                        if [ -n "$target" ]; then
                            remove_target "$target" 2>/dev/null
                            echo ""
                            read -k 1 "?Appuyez sur une touche pour continuer..."
                        fi
                    else
                        echo "❌ Aucune cible à supprimer"
                        sleep 1
                    fi
                    ;;
                4)
                    if has_targets 2>/dev/null; then
                        echo ""
                        printf "⚠️  Êtes-vous sûr de vouloir supprimer toutes les cibles? (o/N): "
                        read -r confirm
                        if [ "$confirm" = "o" ] || [ "$confirm" = "O" ]; then
                            clear_targets 2>/dev/null
                            echo ""
                            read -k 1 "?Appuyez sur une touche pour continuer..."
                        fi
                    else
                        echo "❌ Aucune cible à supprimer"
                        sleep 1
                    fi
                    ;;
                5)
                    echo ""
                    if has_targets 2>/dev/null; then
                        show_targets 2>/dev/null
                    else
                        echo "⚠️  Aucune cible configurée"
                    fi
                    echo ""
                    read -k 1 "?Appuyez sur une touche pour continuer..."
                    ;;
                0) return ;;
                *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
            esac
        done
    }
fi

# DESC: Affiche le menu principal de gestion et configuration
# USAGE: show_management_menu
# EXAMPLE: show_management_menu
show_management_menu() {
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
        echo "║          GESTION & CONFIGURATION - CYBERMAN                    ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo ""
        
        # Afficher l'état actuel
        echo -e "${YELLOW}📊 État actuel:${RESET}"
        if has_active_environment 2>/dev/null; then
            echo -e "   🌍 Environnement actif: ${GREEN}$(get_current_environment)${RESET}"
        else
            echo -e "   🌍 Aucun environnement actif${RESET}"
        fi
        
        if has_targets 2>/dev/null; then
            echo -e "   🎯 Cibles actives: ${GREEN}${#CYBER_TARGETS[@]}${RESET}"
        else
            echo -e "   🎯 Aucune cible configurée${RESET}"
        fi
        echo ""
        
        echo -e "${CYAN}${BOLD}Menu principal${RESET}\n"
        echo "1.  🌍 Environnements (création, chargement, notes, TODOs, résultats)"
        echo "2.  🎯 Cibles (ajouter, modifier, supprimer)"
        echo "3.  🔄 Workflows (créer, exécuter, gérer)"
        echo "4.  📊 Rapports (consulter, exporter)"
        echo "5.  🔒 Anonymat (configuration, vérification)"
        echo ""
        # Proposer de charger l'environnement correspondant aux cibles si détecté
        if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
            source "$CYBER_DIR/environment_manager.sh" 2>/dev/null
            if type find_environment_by_targets >/dev/null 2>&1 && has_targets 2>/dev/null; then
                local detected_env=$(find_environment_by_targets 2>/dev/null)
                if [ -n "$detected_env" ] && ! has_active_environment 2>/dev/null; then
                    echo -e "${CYAN}💡 Environnement détecté: ${BOLD}${detected_env}${RESET} (correspond aux cibles)"
                    echo "6.  🔄 Charger l'environnement détecté: ${detected_env}"
                    echo ""
                fi
            fi
        fi
        echo "0.  Retour au menu principal cyberman"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1) show_environment_management_menu ;;
            2) show_target_menu ;;
            3) show_workflow_menu ;;
            4) show_report_menu ;;
            5) show_anonymity_menu ;;
            6)
                # Charger l'environnement détecté
                if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
                    source "$CYBER_DIR/environment_manager.sh" 2>/dev/null
                    if type find_environment_by_targets >/dev/null 2>&1 && has_targets 2>/dev/null; then
                        local detected_env=$(find_environment_by_targets 2>/dev/null)
                        if [ -n "$detected_env" ]; then
                            echo ""
                            echo "🔄 Chargement de l'environnement: $detected_env"
                            load_environment "$detected_env" 2>/dev/null
                            echo ""
                            read -k 1 "?Appuyez sur une touche pour continuer..."
                        else
                            echo "❌ Aucun environnement correspondant trouvé"
                            sleep 1
                        fi
                    fi
                fi
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
}

# DESC: Affiche le menu de gestion des environnements avec sous-menus
# USAGE: show_environment_management_menu
# EXAMPLE: show_environment_management_menu
show_environment_management_menu() {
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
        echo "║          GESTION DES ENVIRONNEMENTS - CYBERMAN                  ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo ""
        
        # Afficher l'environnement actif
        if has_active_environment 2>/dev/null; then
            local env_name=$(get_current_environment)
            echo -e "${GREEN}🌍 Environnement actif: $env_name${RESET}"
            
            # Afficher les statistiques
            local env_file="$CYBER_ENV_DIR/${env_name}.json"
            if [ -f "$env_file" ] && command -v jq >/dev/null 2>&1; then
                local notes_count=$(jq '.notes | length' "$env_file" 2>/dev/null || echo "0")
                local history_count=$(jq '.history | length' "$env_file" 2>/dev/null || echo "0")
                local results_count=$(jq '.results | length' "$env_file" 2>/dev/null || echo "0")
                local todos_pending=$(jq '[.todos[]? | select(.status == "pending")] | length' "$env_file" 2>/dev/null || echo "0")
                
                echo -e "   📝 Notes: $notes_count | 📜 Historique: $history_count | 📊 Résultats: $results_count | ✅ TODOs: $todos_pending"
            fi
        else
            echo -e "${YELLOW}⚠️  Aucun environnement actif${RESET}"
        fi
        echo ""
        
        # Lister les environnements (peut retourner 1 si aucun environnement)
        if ! list_environments 2>/dev/null; then
            # Si aucun environnement, afficher un message mais continuer
            echo ""
        fi
        echo ""
        
        echo -e "${CYAN}${BOLD}Menu principal${RESET}\n"
        echo "1.  📦 Création & Gestion (créer, charger, sauvegarder, supprimer)"
        echo "2.  📝 Informations & Documentation (notes, historique, résultats)"
        echo "3.  ✅ TODOs (gérer les tâches)"
        echo "4.  🎯 Gérer les cibles de l'environnement actif"
        echo ""
        echo "0.  Retour au menu de gestion"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1) show_environment_creation_menu ;;
            2) show_environment_info_menu ;;
            3) show_environment_todos_menu ;;
            4) show_target_menu ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
}

# DESC: Sous-menu pour la création et gestion des environnements
# USAGE: show_environment_creation_menu
# EXAMPLE: show_environment_creation_menu
show_environment_creation_menu() {
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
        echo "║       CRÉATION & GESTION DES ENVIRONNEMENTS                    ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo ""
        
        # Lister les environnements
        if ! list_environments 2>/dev/null; then
            echo ""
        fi
        echo ""
        
        echo "1.  Créer un nouvel environnement (avec gestion de cibles)"
        echo "2.  Sauvegarder l'environnement actuel"
        echo "3.  Charger un environnement"
        echo "4.  Restaurer un environnement (alias de charger)"
        echo "5.  Afficher les détails d'un environnement"
        echo "6.  Exporter un environnement"
        echo "7.  Importer un environnement"
        echo "8.  Supprimer un environnement"
        echo "9.  Supprimer plusieurs environnements"
        echo "10. Lister tous les environnements"
        echo ""
        echo "0.  Retour"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
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
                
                if [ -f "$CYBER_DIR/target_manager.sh" ]; then
                    source "$CYBER_DIR/target_manager.sh" 2>/dev/null
                    
                    case "$target_choice" in
                        1)
                            printf "🎯 Entrez les cibles (séparées par des espaces): "
                            read -r targets_input
                            if [ -n "$targets_input" ]; then
                                local old_targets=("${CYBER_TARGETS[@]}")
                                clear_targets 2>/dev/null
                                add_target $targets_input 2>/dev/null
                                save_environment "$name" "$desc"
                                CYBER_TARGETS=("${old_targets[@]}")
                                _save_targets_to_file 2>/dev/null
                            else
                                echo "❌ Aucune cible fournie"
                                sleep 1
                            fi
                            ;;
                        2)
                            if has_targets 2>/dev/null; then
                                save_environment "$name" "$desc"
                            else
                                echo "⚠️  Aucune cible actuelle, création sans cibles"
                                save_environment "$name" "$desc"
                            fi
                            ;;
                        3)
                            local old_targets=("${CYBER_TARGETS[@]}")
                            clear_targets 2>/dev/null
                            save_environment "$name" "$desc"
                            CYBER_TARGETS=("${old_targets[@]}")
                            _save_targets_to_file 2>/dev/null
                            ;;
                    esac
                else
                    save_environment "$name" "$desc"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2)
                echo ""
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
            3)
                echo ""
                list_environments
                echo ""
                printf "📝 Nom de l'environnement à charger: "
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
                printf "📝 Nom de l'environnement à restaurer: "
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
                printf "📝 Nom de l'environnement: "
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
                printf "📝 Nom de l'environnement à exporter: "
                read -r name
                if [ -n "$name" ]; then
                    printf "📁 Fichier de sortie (optionnel): "
                    read -r output_file
                    export_environment "$name" "$output_file"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            7)
                echo ""
                printf "📥 Chemin du fichier JSON à importer: "
                read -r input_file
                if [ -n "$input_file" ] && [ -f "$input_file" ]; then
                    printf "📝 Nouveau nom (optionnel, laisser vide pour utiliser le nom original): "
                    read -r new_name
                    import_environment "$input_file" "$new_name"
                else
                    echo "❌ Fichier introuvable"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            8)
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
            9)
                echo ""
                list_environments
                echo ""
                printf "🗑️  Entrez les noms des environnements à supprimer (séparés par des espaces): "
                read -r names_to_delete
                if [ -n "$names_to_delete" ]; then
                    delete_environments $names_to_delete
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            10)
                list_environments
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
}

# DESC: Sous-menu pour les informations et documentation des environnements
# USAGE: show_environment_info_menu
# EXAMPLE: show_environment_info_menu
show_environment_info_menu() {
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
        echo "║       INFORMATIONS & DOCUMENTATION DES ENVIRONNEMENTS            ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo ""
        
        # Afficher l'environnement actif
        if has_active_environment 2>/dev/null; then
            local env_name=$(get_current_environment)
            echo -e "${GREEN}🌍 Environnement actif: $env_name${RESET}"
        else
            echo -e "${YELLOW}⚠️  Aucun environnement actif${RESET}"
            echo ""
            list_environments
            echo ""
            printf "📝 Nom de l'environnement: "
            read -r env_name
            if [ -z "$env_name" ]; then
                return
            fi
        fi
        echo ""
        
        echo "1.  Voir toutes les notes"
        echo "2.  Ajouter une note"
        echo "3.  Voir l'historique complet des actions"
        echo "4.  Ajouter une action à l'historique"
        echo "5.  Voir tous les résultats de tests"
        echo "6.  Ajouter un résultat de test"
        echo "7.  Voir les détails complets (JSON)"
        echo "8.  Rechercher dans les informations"
        echo "9.  Exporter toutes les informations"
        echo "10. Charger et naviguer toutes les infos (menu interactif)"
        echo ""
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
                printf "📝 Note à ajouter: "
                read -r note_text
                if [ -n "$note_text" ]; then
                    add_environment_note "$env_name" "$note_text"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3)
                echo ""
                show_environment_history "$env_name"
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4)
                echo ""
                printf "📝 Type d'action: "
                read -r action_type
                printf "📝 Description: "
                read -r action_desc
                printf "📝 Résultat (optionnel): "
                read -r action_result
                if [ -n "$action_type" ] && [ -n "$action_desc" ]; then
                    add_environment_action "$env_name" "$action_type" "$action_desc" "$action_result"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            5)
                echo ""
                show_environment_results "$env_name"
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            6)
                echo ""
                printf "📝 Nom du test: "
                read -r test_name
                printf "📝 Données du résultat: "
                read -r result_data
                printf "📝 Statut (success/warning/error, optionnel): "
                read -r result_status
                if [ -n "$test_name" ] && [ -n "$result_data" ]; then
                    add_environment_result "$env_name" "$test_name" "$result_data" "$result_status"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            7)
                echo ""
                show_environment "$env_name"
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            8)
                echo ""
                printf "🔍 Terme de recherche: "
                read -r search_term
                if [ -n "$search_term" ]; then
                    # Recherche simple dans le JSON
                    local env_file="$CYBER_ENV_DIR/${env_name}.json"
                    if [ -f "$env_file" ] && command -v jq >/dev/null 2>&1; then
                        echo ""
                        echo "Résultats de recherche pour '$search_term':"
                        jq -r --arg term "$search_term" '
                            .notes[]? | select(. | tostring | test($term; "i")) | "📝 Note: \(.)"
                        ' "$env_file" 2>/dev/null
                        jq -r --arg term "$search_term" '
                            .history[]? | select(.description | test($term; "i")) | "📜 Action: \(.type) - \(.description)"
                        ' "$env_file" 2>/dev/null
                        jq -r --arg term "$search_term" '
                            .results[]? | select(.test_name | test($term; "i")) | "📊 Test: \(.test_name) - \(.result)"
                        ' "$env_file" 2>/dev/null
                    fi
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            9)
                echo ""
                printf "📁 Fichier de sortie (optionnel): "
                read -r output_file
                export_environment "$env_name" "$output_file"
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            10)
                echo ""
                load_infos "$env_name"
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
}

# DESC: Sous-menu pour la gestion des TODOs des environnements
# USAGE: show_environment_todos_menu
# EXAMPLE: show_environment_todos_menu
show_environment_todos_menu() {
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
        echo "║            GESTION DES TODOs DES ENVIRONNEMENTS                  ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo ""
        
        # Afficher l'environnement actif
        if has_active_environment 2>/dev/null; then
            local env_name=$(get_current_environment)
            echo -e "${GREEN}🌍 Environnement actif: $env_name${RESET}"
        else
            echo -e "${YELLOW}⚠️  Aucun environnement actif${RESET}"
            echo ""
            list_environments
            echo ""
            printf "📝 Nom de l'environnement: "
            read -r env_name
            if [ -z "$env_name" ]; then
                return
            fi
        fi
        echo ""
        
        # Afficher les TODOs en attente
        show_environment_todos "$env_name"
        echo ""
        
        echo "1.  Ajouter un TODO"
        echo "2.  Marquer un TODO comme complété"
        echo "3.  Voir les TODOs en attente"
        echo "4.  Voir les TODOs complétés"
        echo ""
        echo "0.  Retour"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                echo ""
                printf "📝 Texte du TODO: "
                read -r todo_text
                if [ -n "$todo_text" ]; then
                    echo ""
                    echo "Priorité:"
                    echo "  1. 🟢 Low (basse)"
                    echo "  2. 🟡 Medium (moyenne)"
                    echo "  3. 🔴 High (haute)"
                    printf "Choix (1-3, défaut: 2): "
                    read -r priority_choice
                    local priority="medium"
                    case "$priority_choice" in
                        1) priority="low" ;;
                        3) priority="high" ;;
                        *) priority="medium" ;;
                    esac
                    add_environment_todo "$env_name" "$todo_text" "$priority"
                fi
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
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
}

