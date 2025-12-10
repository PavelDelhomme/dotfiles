#!/bin/zsh
# =============================================================================
# PROGRESS - Gestion de la progression d'apprentissage
# =============================================================================
# Description: Suivi et gestion de la progression dans cyberlearn
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

CYBERLEARN_DATA_DIR="${HOME}/.cyberlearn"
CYBERLEARN_PROGRESS_FILE="${CYBERLEARN_DATA_DIR}/progress.json"

# Initialiser le fichier de progression s'il n'existe pas
init_progress() {
    if [ ! -f "$CYBERLEARN_PROGRESS_FILE" ]; then
        cat > "$CYBERLEARN_PROGRESS_FILE" <<EOF
{
  "started_at": "$(date -Iseconds)",
  "last_activity": "$(date -Iseconds)",
  "modules": {},
  "labs": {},
  "exercises": {},
  "badges": [],
  "total_time_spent": 0,
  "stats": {
    "modules_completed": 0,
    "labs_completed": 0,
    "exercises_completed": 0,
    "challenges_completed": 0
  }
}
EOF
    fi
}

# Charger la progression
load_progress() {
    init_progress
    if command -v jq &>/dev/null; then
        cat "$CYBERLEARN_PROGRESS_FILE"
    else
        echo "{}"
    fi
}

# Sauvegarder la progression
save_progress() {
    local progress_data="$1"
    echo "$progress_data" > "$CYBERLEARN_PROGRESS_FILE"
}

# Obtenir le statut d'un module
get_module_status() {
    local module_name="$1"
    if command -v jq &>/dev/null && [ -f "$CYBERLEARN_PROGRESS_FILE" ]; then
        jq -r ".modules.\"$module_name\".status // \"not_started\"" "$CYBERLEARN_PROGRESS_FILE" 2>/dev/null || echo "not_started"
    else
        echo "not_started"
    fi
}

# Marquer un module comme complété
complete_module() {
    local module_name="$1"
    local progress=$(load_progress)
    
    if command -v jq &>/dev/null; then
        progress=$(echo "$progress" | jq ".modules.\"$module_name\".status = \"completed\" | .modules.\"$module_name\".completed_at = \"$(date -Iseconds)\" | .last_activity = \"$(date -Iseconds)\" | .stats.modules_completed += 1")
        save_progress "$progress"
    fi
}

# Marquer un module comme en cours
start_module_progress() {
    local module_name="$1"
    local progress=$(load_progress)
    
    if command -v jq &>/dev/null; then
        progress=$(echo "$progress" | jq ".modules.\"$module_name\".status = \"in_progress\" | .modules.\"$module_name\".started_at = \"$(date -Iseconds)\" | .last_activity = \"$(date -Iseconds)\"")
        save_progress "$progress"
    fi
}

# Obtenir le nombre total de modules
get_total_modules() {
    echo "10"  # basics, network, web, crypto, linux, windows, mobile, forensics, pentest, incident
}

# Obtenir le nombre de modules complétés
get_completed_modules() {
    if command -v jq &>/dev/null && [ -f "$CYBERLEARN_PROGRESS_FILE" ]; then
        jq -r '.stats.modules_completed // 0' "$CYBERLEARN_PROGRESS_FILE" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Obtenir le nombre total de labs
get_total_labs_count() {
    echo "5"  # web-basics, network-scan, crypto-basics, linux-pentest, forensics-basic
}

# Obtenir le nombre de labs complétés
get_completed_labs_count() {
    if command -v jq &>/dev/null && [ -f "$CYBERLEARN_PROGRESS_FILE" ]; then
        jq -r '.stats.labs_completed // 0' "$CYBERLEARN_PROGRESS_FILE" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Afficher la progression détaillée
show_detailed_progress() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    init_progress
    
    local total_modules=$(get_total_modules)
    local completed_modules=$(get_completed_modules)
    local total_labs=$(get_total_labs_count)
    local completed_labs=$(get_completed_labs_count)
    
    echo -e "${CYAN}${BOLD}📊 Statistiques Globales${RESET}\n"
    echo -e "${BLUE}Modules:${RESET} ${completed_modules}/${total_modules} complétés"
    echo -e "${BLUE}Labs:${RESET} ${completed_labs}/${total_labs} complétés"
    echo ""
    
    echo -e "${CYAN}${BOLD}📖 Progression par Module${RESET}\n"
    local modules=("basics" "network" "web" "crypto" "linux" "windows" "mobile" "forensics" "pentest" "incident")
    
    for module in "${modules[@]}"; do
        local status=$(get_module_status "$module")
        local icon="⭕"
        local color="$YELLOW"
        
        case "$status" in
            completed)
                icon="✅"
                color="$GREEN"
                ;;
            in_progress)
                icon="🔄"
                color="$CYAN"
                ;;
            not_started)
                icon="⭕"
                color="$RED"
                ;;
        esac
        
        echo -e "${icon} ${color}${BOLD}${module}${RESET} - $(get_module_description "$module")"
    done
}

# Obtenir la description d'un module
get_module_description() {
    local module_name="$1"
    case "$module_name" in
        basics) echo "Bases de la Cybersécurité" ;;
        network) echo "Sécurité Réseau" ;;
        web) echo "Sécurité Web" ;;
        crypto) echo "Cryptographie" ;;
        linux) echo "Sécurité Linux" ;;
        windows) echo "Sécurité Windows" ;;
        mobile) echo "Sécurité Mobile" ;;
        forensics) echo "Forensique Numérique" ;;
        pentest) echo "Tests de Pénétration" ;;
        incident) echo "Incident Response" ;;
        *) echo "Module inconnu" ;;
    esac
}

# Fonction pour afficher le header
show_header() {
    clear
    echo -e "\033[0;36m\033[1m"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║            CYBERLEARN - Apprentissage Cybersécurité              ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "\033[0m"
}

# Afficher les statistiques détaillées
show_detailed_stats() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    show_header
    echo -e "${CYAN}${BOLD}📈 STATISTIQUES DÉTAILLÉES${RESET}\n"
    
    if command -v jq &>/dev/null && [ -f "$CYBERLEARN_PROGRESS_FILE" ]; then
        local started_at=$(jq -r '.started_at // "N/A"' "$CYBERLEARN_PROGRESS_FILE")
        local last_activity=$(jq -r '.last_activity // "N/A"' "$CYBERLEARN_PROGRESS_FILE")
        local total_time=$(jq -r '.total_time_spent // 0' "$CYBERLEARN_PROGRESS_FILE")
        
        echo -e "${BLUE}Début de l'apprentissage:${RESET} $started_at"
        echo -e "${BLUE}Dernière activité:${RESET} $last_activity"
        echo -e "${BLUE}Temps total passé:${RESET} ${total_time} minutes"
        echo ""
        
        echo -e "${CYAN}${BOLD}Modules:${RESET}"
        jq -r '.modules | to_entries[] | "\(.key): \(.value.status // "not_started")"' "$CYBERLEARN_PROGRESS_FILE" 2>/dev/null || echo "Aucune donnée"
    else
        echo -e "${YELLOW}⚠️  jq n'est pas installé. Installez-le pour voir les statistiques détaillées.${RESET}"
    fi
    
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Afficher les badges
show_badges() {
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    echo -e "${CYAN}${BOLD}🏆 BADGES OBTENUS${RESET}\n"
    
    if command -v jq &>/dev/null && [ -f "$CYBERLEARN_PROGRESS_FILE" ]; then
        local badges=$(jq -r '.badges[] // empty' "$CYBERLEARN_PROGRESS_FILE" 2>/dev/null)
        if [ -n "$badges" ]; then
            echo "$badges" | while read -r badge; do
                echo "  🏅 $badge"
            done
        else
            echo "  Aucun badge obtenu pour le moment"
        fi
    else
        echo "  Aucun badge obtenu pour le moment"
    fi
}

# Afficher l'historique d'apprentissage
show_learning_history() {
    clear
    echo -e "\033[0;36m\033[1m"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║            CYBERLEARN - Apprentissage Cybersécurité              ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "\033[0m"
    echo -e "${CYAN}${BOLD}📜 HISTORIQUE D'APPRENTISSAGE${RESET}\n"
    
    if command -v jq &>/dev/null && [ -f "$CYBERLEARN_PROGRESS_FILE" ]; then
        echo "Historique des activités récentes..."
        # TODO: Implémenter l'historique détaillé
    else
        echo -e "${YELLOW}⚠️  jq n'est pas installé${RESET}"
    fi
    
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Réinitialiser la progression (avec confirmation)
reset_progress_confirm() {
    local RED='\033[0;31m'
    local YELLOW='\033[1;33m'
    local RESET='\033[0m'
    
    echo -e "${RED}${BOLD}⚠️  ATTENTION: Cette action est irréversible !${RESET}\n"
    printf "${YELLOW}Êtes-vous sûr de vouloir réinitialiser toute votre progression ? (oui/NON): ${RESET}"
    read -r confirm
    
    if [ "$confirm" = "oui" ]; then
        rm -f "$CYBERLEARN_PROGRESS_FILE"
        init_progress
        echo -e "${GREEN}✅ Progression réinitialisée${RESET}"
    else
        echo -e "${YELLOW}Opération annulée${RESET}"
    fi
    
    sleep 2
}

# Initialiser au chargement
init_progress

