#!/bin/zsh
# =============================================================================
# CYBERLEARN - Système d'Apprentissage Cybersécurité
# =============================================================================
# Description: Plateforme complète d'apprentissage de la cybersécurité dans le terminal
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoires de base
CYBERLEARN_DIR="${CYBERLEARN_DIR:-$HOME/dotfiles/zsh/functions/cyberlearn}"
CYBERLEARN_DATA_DIR="${HOME}/.cyberlearn"
CYBERLEARN_PROGRESS_FILE="${CYBERLEARN_DATA_DIR}/progress.json"
CYBERLEARN_LABS_DIR="${CYBERLEARN_DATA_DIR}/labs"
CYBERLEARN_MODULES_DIR="${CYBERLEARN_DIR}/modules"

# Créer les répertoires nécessaires
mkdir -p "$CYBERLEARN_DATA_DIR" "$CYBERLEARN_LABS_DIR" "$CYBERLEARN_MODULES_DIR"

# Charger les utilitaires
[ -f "$CYBERLEARN_DIR/utils/progress.sh" ] && source "$CYBERLEARN_DIR/utils/progress.sh"
[ -f "$CYBERLEARN_DIR/utils/labs.sh" ] && source "$CYBERLEARN_DIR/utils/labs.sh"
[ -f "$CYBERLEARN_DIR/utils/validator.sh" ] && source "$CYBERLEARN_DIR/utils/validator.sh"

# =============================================================================
# FONCTION PRINCIPALE
# =============================================================================
# DESC: Système d'apprentissage complet de la cybersécurité
# USAGE: cyberlearn [command] [args]
# EXAMPLE: cyberlearn
# EXAMPLE: cyberlearn start-module basics
# EXAMPLE: cyberlearn lab start web-basics
cyberlearn() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local MAGENTA='\033[0;35m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    # Fonction pour afficher le header
    show_header() {
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║            CYBERLEARN - Apprentissage Cybersécurité              ║"
        echo "║              Plateforme d'Apprentissage Terminal               ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        
        # Afficher la progression globale
        local total_modules=$(get_total_modules)
        local completed_modules=$(get_completed_modules)
        local progress_percent=$((completed_modules * 100 / total_modules))
        
        echo -e "${CYAN}${BOLD}📊 Votre Progression:${RESET}"
        echo -e "   ${GREEN}Modules complétés:${RESET} ${completed_modules}/${total_modules} (${progress_percent}%)"
        echo -e "   ${GREEN}Labs complétés:${RESET} $(get_completed_labs_count)/$(get_total_labs_count)"
        echo ""
        
        echo -e "${YELLOW}${BOLD}📚 MENU PRINCIPAL${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        echo -e "${BOLD}1.${RESET} 📖 Modules de Cours"
        echo -e "${BOLD}2.${RESET} 🧪 Labs Pratiques"
        echo -e "${BOLD}3.${RESET} 📊 Ma Progression"
        echo -e "${BOLD}4.${RESET} 🎯 Exercices & Challenges"
        echo -e "${BOLD}5.${RESET} 🐳 Gérer les Environnements Docker"
        echo -e "${BOLD}6.${RESET} 📝 Certificats & Badges"
        echo -e "${BOLD}7.${RESET} ❓ Aide & Documentation"
        echo -e "${BOLD}0.${RESET} Quitter"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        case "$choice" in
            1|modules|cours) show_modules_menu ;;
            2|labs|lab) show_labs_menu ;;
            3|progress|progression) show_progress_menu ;;
            4|exercises|challenges) show_exercises_menu ;;
            5|docker|env) show_docker_menu ;;
            6|certificates|badges) show_certificates_menu ;;
            7|help|aide) show_help_menu ;;
            0|q|quit|exit) return 0 ;;
            *) echo -e "${RED}❌ Choix invalide: $choice${RESET}"; sleep 2 ;;
        esac
    }
    
    # Fonction pour afficher le menu des modules
    show_modules_menu() {
        show_header
        echo -e "${YELLOW}${BOLD}📖 MODULES DE COURS${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        echo -e "${BOLD}1.${RESET} 🎯 Bases de la Cybersécurité"
        echo -e "${BOLD}2.${RESET} 🌐 Sécurité Réseau"
        echo -e "${BOLD}3.${RESET} 🕸️  Sécurité Web"
        echo -e "${BOLD}4.${RESET} 🔐 Cryptographie"
        echo -e "${BOLD}5.${RESET} 🐧 Sécurité Linux"
        echo -e "${BOLD}6.${RESET} 🪟 Sécurité Windows"
        echo -e "${BOLD}7.${RESET} 📱 Sécurité Mobile"
        echo -e "${BOLD}8.${RESET} 🔍 Forensique Numérique"
        echo -e "${BOLD}9.${RESET} 🛡️  Tests de Pénétration"
        echo -e "${BOLD}10.${RESET} 🚨 Incident Response"
        echo -e "${BOLD}11.${RESET} 📋 Liste tous les modules"
        echo -e "${BOLD}0.${RESET} Retour"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        case "$choice" in
            1|basics) start_module "basics" ;;
            2|network) start_module "network" ;;
            3|web) start_module "web" ;;
            4|crypto) start_module "crypto" ;;
            5|linux) start_module "linux" ;;
            6|windows) start_module "windows" ;;
            7|mobile) start_module "mobile" ;;
            8|forensics) start_module "forensics" ;;
            9|pentest) start_module "pentest" ;;
            10|incident) start_module "incident" ;;
            11|list) list_all_modules ;;
            0) return ;;
            *) echo -e "${RED}❌ Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # Fonction pour démarrer un module
    start_module() {
        local module_name="$1"
        local module_file="${CYBERLEARN_MODULES_DIR}/${module_name}/module.zsh"
        
        if [ -f "$module_file" ]; then
            source "$module_file"
            run_module "$module_name"
        else
            echo -e "${RED}❌ Module '$module_name' non trouvé${RESET}"
            echo -e "${YELLOW}💡 Les modules seront créés progressivement${RESET}"
            sleep 2
        fi
    }
    
    # Fonction pour lister tous les modules
    list_all_modules() {
        show_header
        echo -e "${YELLOW}${BOLD}📋 TOUS LES MODULES DISPONIBLES${RESET}\n"
        
        local modules=("basics" "network" "web" "crypto" "linux" "windows" "mobile" "forensics" "pentest" "incident")
        
        for module in "${modules[@]}"; do
            local status=$(get_module_status "$module")
            local icon="⭕"
            if [ "$status" = "completed" ]; then
                icon="✅"
            elif [ "$status" = "in_progress" ]; then
                icon="🔄"
            fi
            
            echo -e "${icon} ${BOLD}${module}${RESET} - $(get_module_description "$module")"
        done
        
        echo ""
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Fonction pour afficher le menu des labs
    show_labs_menu() {
        show_header
        echo -e "${YELLOW}${BOLD}🧪 LABS PRATIQUES${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        echo -e "${BOLD}1.${RESET} 🚀 Démarrer un Lab"
        echo -e "${BOLD}2.${RESET} 📋 Lister les Labs Disponibles"
        echo -e "${BOLD}3.${RESET} 🛑 Arrêter un Lab Actif"
        echo -e "${BOLD}4.${RESET} 📊 Statut des Labs"
        echo -e "${BOLD}0.${RESET} Retour"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        case "$choice" in
            1|start) start_lab_interactive ;;
            2|list) list_available_labs ;;
            3|stop) stop_lab_interactive ;;
            4|status) show_labs_status ;;
            0) return ;;
            *) echo -e "${RED}❌ Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # Fonction pour afficher le menu de progression
    show_progress_menu() {
        show_header
        echo -e "${YELLOW}${BOLD}📊 MA PROGRESSION${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        show_detailed_progress
        
        echo ""
        echo -e "${BOLD}1.${RESET} 📈 Statistiques Détaillées"
        echo -e "${BOLD}2.${RESET} 🏆 Badges Obtenus"
        echo -e "${BOLD}3.${RESET} 📜 Historique d'Apprentissage"
        echo -e "${BOLD}4.${RESET} 🔄 Réinitialiser la Progression"
        echo -e "${BOLD}0.${RESET} Retour"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        case "$choice" in
            1|stats) show_detailed_stats ;;
            2|badges) show_badges ;;
            3|history) show_learning_history ;;
            4|reset) reset_progress_confirm ;;
            0) return ;;
            *) echo -e "${RED}❌ Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # Fonction pour afficher le menu des exercices
    show_exercises_menu() {
        show_header
        echo -e "${YELLOW}${BOLD}🎯 EXERCICES & CHALLENGES${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        echo -e "${BOLD}1.${RESET} 🎯 Challenge du Jour"
        echo -e "${BOLD}2.${RESET} 📝 Exercices par Module"
        echo -e "${BOLD}3.${RESET} 🏁 Challenges Avancés"
        echo -e "${BOLD}4.${RESET} 🎮 Mode Pratique"
        echo -e "${BOLD}0.${RESET} Retour"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        case "$choice" in
            1|daily) show_daily_challenge ;;
            2|module) show_module_exercises ;;
            3|advanced) show_advanced_challenges ;;
            4|practice) start_practice_mode ;;
            0) return ;;
            *) echo -e "${RED}❌ Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # Fonction pour afficher le menu Docker
    show_docker_menu() {
        show_header
        echo -e "${YELLOW}${BOLD}🐳 GESTION DES ENVIRONNEMENTS DOCKER${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        echo -e "${BOLD}1.${RESET} 🚀 Démarrer un Environnement"
        echo -e "${BOLD}2.${RESET} 🛑 Arrêter un Environnement"
        echo -e "${BOLD}3.${RESET} 📋 Lister les Environnements"
        echo -e "${BOLD}4.${RESET} 🔧 Construire une Image"
        echo -e "${BOLD}5.${RESET} 🧹 Nettoyer les Containers"
        echo -e "${BOLD}0.${RESET} Retour"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        case "$choice" in
            1|start) docker_start_environment ;;
            2|stop) docker_stop_environment ;;
            3|list) docker_list_environments ;;
            4|build) docker_build_image ;;
            5|clean) docker_cleanup ;;
            0) return ;;
            *) echo -e "${RED}❌ Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # Fonction pour afficher le menu des certificats
    show_certificates_menu() {
        show_header
        echo -e "${YELLOW}${BOLD}📝 CERTIFICATS & BADGES${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        show_badges
        echo ""
        echo -e "${BOLD}1.${RESET} 📜 Générer un Certificat"
        echo -e "${BOLD}2.${RESET} 🏆 Voir mes Badges"
        echo -e "${BOLD}0.${RESET} Retour"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        case "$choice" in
            1|cert) generate_certificate ;;
            2|badges) show_badges_detailed ;;
            0) return ;;
            *) echo -e "${RED}❌ Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # Fonction pour afficher l'aide
    show_help_menu() {
        show_header
        echo -e "${CYAN}${BOLD}❓ AIDE & DOCUMENTATION${RESET}\n"
        
        cat <<EOF
${BOLD}Commandes disponibles:${RESET}

${GREEN}cyberlearn${RESET}              - Menu interactif principal
${GREEN}cyberlearn start-module <nom>${RESET} - Démarrer un module
${GREEN}cyberlearn lab start <nom>${RESET}    - Démarrer un lab
${GREEN}cyberlearn progress${RESET}            - Voir la progression
${GREEN}cyberlearn help${RESET}                - Afficher cette aide

${BOLD}Modules disponibles:${RESET}
  - basics      : Bases de la cybersécurité
  - network     : Sécurité réseau
  - web         : Sécurité web
  - crypto      : Cryptographie
  - linux       : Sécurité Linux
  - windows     : Sécurité Windows
  - mobile      : Sécurité mobile
  - forensics   : Forensique numérique
  - pentest     : Tests de pénétration
  - incident    : Incident response

${BOLD}Labs disponibles:${RESET}
  - web-basics      : Lab sécurité web de base
  - network-scan    : Lab scan réseau
  - crypto-basics   : Lab cryptographie
  - linux-pentest   : Lab pentest Linux
  - forensics-basic : Lab forensique de base

${BOLD}Exemples:${RESET}
  cyberlearn
  cyberlearn start-module basics
  cyberlearn lab start web-basics
  cyberlearn progress

${BOLD}Pré-requis:${RESET}
  - Docker (pour les labs)
  - Outils de cybersécurité (nmap, wireshark, etc.)
  - Python 3 (pour certains exercices)

EOF
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Si un argument est fourni, lancer directement la commande
    if [ -n "$1" ]; then
        local cmd=$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        
        case "$cmd" in
            start-module|module)
                if [ -n "$2" ]; then
                    start_module "$2"
                else
                    show_modules_menu
                fi
                ;;
            lab)
                case "$2" in
                    start) [ -n "$3" ] && start_lab "$3" || start_lab_interactive ;;
                    stop) [ -n "$3" ] && stop_lab "$3" || stop_lab_interactive ;;
                    list) list_available_labs ;;
                    status) show_labs_status ;;
                    *) echo -e "${RED}❌ Usage: cyberlearn lab [start|stop|list|status] [nom]${RESET}"; return 1 ;;
                esac
                ;;
            progress|progression) show_progress_menu ;;
            help|aide|--help|-h) show_help_menu ;;
            *)
                echo -e "${RED}❌ Commande inconnue: $1${RESET}"
                echo ""
                echo -e "${YELLOW}Commandes disponibles:${RESET}"
                echo "  start-module <nom>  - Démarrer un module"
                echo "  lab [start|stop|list] [nom] - Gérer les labs"
                echo "  progress            - Voir la progression"
                echo "  help                - Afficher l'aide"
                echo ""
                return 1
                ;;
        esac
    else
        # Mode interactif
        while true; do
            show_main_menu
        done
    fi
}

# Alias
alias cl='cyberlearn'
alias cyberlearn-module='cyberlearn start-module'
alias cyberlearn-lab='cyberlearn lab'

