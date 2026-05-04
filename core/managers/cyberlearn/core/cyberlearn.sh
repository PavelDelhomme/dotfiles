#!/bin/sh
# =============================================================================
# CYBERLEARN - Système d'Apprentissage Cybersécurité (Code Commun POSIX)
# =============================================================================
# Description: Plateforme complète d'apprentissage de la cybersécurité dans le terminal
# Author: Paul Delhomme
# Version: 2.0 - Migration POSIX Complète
# =============================================================================

# Détecter le shell pour adapter certaines syntaxes
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_TYPE="fish"
else
    SHELL_TYPE="sh"
fi

_nc_lib="${DOTFILES_DIR:-$HOME/dotfiles}/scripts/lib/ncurses_menu.sh"
[ -f "$_nc_lib" ] && . "$_nc_lib"

# DESC: Système d'apprentissage complet de la cybersécurité
# USAGE: cyberlearn [command] [args]
# EXAMPLE: cyberlearn
# EXAMPLE: cyberlearn start-module basics
# EXAMPLE: cyberlearn lab start web-basics
cyberlearn() {
    # Configuration des couleurs
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'

    cyberlearn_pick_menu() {
        _title="$1"
        _choice=""
        if [ -t 0 ] && [ -t 1 ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
            _menu_file=$(mktemp)
            cat > "$_menu_file"
            _choice=$(dotfiles_ncmenu_select "$_title" < "$_menu_file" 2>/dev/null || true)
            rm -f "$_menu_file"
        fi
        if [ -z "$_choice" ]; then
            printf "Choix: "
            read _choice
        fi
        printf "%s" "$_choice"
    }

    pause_if_tty() {
        if [ -t 0 ] && [ -t 1 ]; then printf "Appuyez sur Entrée pour continuer... "; read dummy; fi
    }
    
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    CYBERLEARN_DIR="$DOTFILES_DIR/zsh/functions/cyberlearn"
    CYBERLEARN_DATA_DIR="$HOME/.cyberlearn"
    CYBERLEARN_PROGRESS_FILE="$CYBERLEARN_DATA_DIR/progress.json"
    CYBERLEARN_LABS_DIR="$CYBERLEARN_DATA_DIR/labs"
    CYBERLEARN_MODULES_DIR="$CYBERLEARN_DIR/modules"
    
    # Créer les répertoires nécessaires avec permissions sécurisées
    mkdir -p "$CYBERLEARN_DATA_DIR" "$CYBERLEARN_LABS_DIR" "$CYBERLEARN_MODULES_DIR"
    # Sécuriser les permissions (700 pour dossiers, 600 pour fichiers)
    chmod 700 "$CYBERLEARN_DATA_DIR" "$CYBERLEARN_LABS_DIR" 2>/dev/null || true
    chown "$USER:$USER" "$CYBERLEARN_DATA_DIR" 2>/dev/null || true
    
    # Charger les utilitaires si disponibles
    [ -f "$CYBERLEARN_DIR/utils/progress.sh" ] && . "$CYBERLEARN_DIR/utils/progress.sh" 2>/dev/null || true
    [ -f "$CYBERLEARN_DIR/utils/labs.sh" ] && . "$CYBERLEARN_DIR/utils/labs.sh" 2>/dev/null || true
    [ -f "$CYBERLEARN_DIR/utils/validator.sh" ] && . "$CYBERLEARN_DIR/utils/validator.sh" 2>/dev/null || true
    
    # Fonctions helper pour la progression (si non chargées)
    get_total_modules() {
        echo "10"
    }
    
    get_completed_modules() {
        if [ -f "$CYBERLEARN_PROGRESS_FILE" ] && command -v jq >/dev/null 2>&1; then
            jq -r '.completed_modules | length' "$CYBERLEARN_PROGRESS_FILE" 2>/dev/null || echo "0"
        else
            echo "0"
        fi
    }
    
    get_completed_labs_count() {
        if [ -f "$CYBERLEARN_PROGRESS_FILE" ] && command -v jq >/dev/null 2>&1; then
            jq -r '.completed_labs | length' "$CYBERLEARN_PROGRESS_FILE" 2>/dev/null || echo "0"
        else
            echo "0"
        fi
    }
    
    get_total_labs_count() {
        echo "5"
    }
    
    get_module_status() {
        module="$1"
        if [ -f "$CYBERLEARN_PROGRESS_FILE" ] && command -v jq >/dev/null 2>&1; then
            jq -r ".completed_modules[]? | select(. == \"$module\")" "$CYBERLEARN_PROGRESS_FILE" 2>/dev/null && echo "completed" || echo "not_started"
        else
            echo "not_started"
        fi
    }
    
    get_module_description() {
        module="$1"
        case "$module" in
            basics) echo "Bases de la cybersécurité" ;;
            network) echo "Sécurité réseau" ;;
            web) echo "Sécurité web" ;;
            crypto) echo "Cryptographie" ;;
            linux) echo "Sécurité Linux" ;;
            windows) echo "Sécurité Windows" ;;
            mobile) echo "Sécurité mobile" ;;
            forensics) echo "Forensique numérique" ;;
            pentest) echo "Tests de pénétration" ;;
            incident) echo "Incident response" ;;
            *) echo "Module inconnu" ;;
        esac
    }
    
    show_detailed_progress() {
        printf "${CYAN}Progression globale:${RESET}\n"
        total_modules=$(get_total_modules)
        completed_modules=$(get_completed_modules)
        if [ "$total_modules" -gt 0 ]; then
            progress_percent=$((completed_modules * 100 / total_modules))
        else
            progress_percent=0
        fi
        printf "  Modules: %s/%s (%d%%)\n" "$completed_modules" "$total_modules" "$progress_percent"
        printf "  Labs: %s/%s\n" "$(get_completed_labs_count)" "$(get_total_labs_count)"
    }
    
    show_detailed_stats() {
        show_header
        printf "${CYAN}${BOLD}📈 STATISTIQUES DÉTAILLÉES${RESET}\n\n"
        show_detailed_progress
        echo ""
        pause_if_tty
    }
    
    show_badges() {
        printf "${CYAN}Badges obtenus:${RESET}\n"
        if [ -f "$CYBERLEARN_PROGRESS_FILE" ] && command -v jq >/dev/null 2>&1; then
            badges=$(jq -r '.badges[]? // empty' "$CYBERLEARN_PROGRESS_FILE" 2>/dev/null)
            if [ -n "$badges" ]; then
                echo "$badges" | while IFS= read -r badge; do
                    printf "  🏅 %s\n" "$badge"
                done
            else
                echo "  Aucun badge obtenu pour le moment"
            fi
        else
            echo "  Aucun badge obtenu pour le moment"
        fi
    }
    
    show_learning_history() {
        show_header
        printf "${CYAN}${BOLD}📜 HISTORIQUE D'APPRENTISSAGE${RESET}\n\n"
        if [ -f "$CYBERLEARN_PROGRESS_FILE" ] && command -v jq >/dev/null 2>&1; then
            jq -r '.history[]? // empty' "$CYBERLEARN_PROGRESS_FILE" 2>/dev/null | head -20
        else
            echo "Aucun historique disponible"
        fi
        echo ""
        pause_if_tty
    }
    
    reset_progress_confirm() {
        show_header
        printf "${YELLOW}${BOLD}⚠️  RÉINITIALISER LA PROGRESSION${RESET}\n\n"
        if ! [ -t 0 ] || ! [ -t 1 ]; then
            printf "${YELLOW}Réinitialisation interactive uniquement dans un terminal.${RESET}\n"
            sleep 2
            return 1
        fi
        printf "Êtes-vous sûr de vouloir réinitialiser toute votre progression? [y/N]: "
        read confirm
        case "$confirm" in
            [yY]*)
                rm -f "$CYBERLEARN_PROGRESS_FILE"
                printf "${GREEN}✅ Progression réinitialisée${RESET}\n"
                ;;
            *)
                printf "${YELLOW}Opération annulée${RESET}\n"
                ;;
        esac
        sleep 2
    }
    
    start_lab_interactive() {
        show_header
        printf "${CYAN}${BOLD}🚀 DÉMARRER UN LAB${RESET}\n\n"
        printf "Nom du lab: "
        read lab_name
        if [ -n "$lab_name" ]; then
            if command -v start_lab >/dev/null 2>&1; then
                start_lab "$lab_name"
            else
                printf "${YELLOW}⚠️  Fonction start_lab non disponible${RESET}\n"
                printf "${CYAN}💡 Chargez le module labs depuis %s${RESET}\n" "$CYBERLEARN_DIR/utils/labs.sh"
            fi
        fi
        pause_if_tty
    }
    
    list_available_labs() {
        show_header
        printf "${CYAN}${BOLD}📋 LABS DISPONIBLES${RESET}\n\n"
        if command -v list_available_labs >/dev/null 2>&1; then
            list_available_labs
        else
            echo "Labs disponibles:"
            echo "  - web-basics      : Lab sécurité web de base"
            echo "  - network-scan    : Lab scan réseau"
            echo "  - crypto-basics   : Lab cryptographie"
            echo "  - linux-pentest   : Lab pentest Linux"
            echo "  - forensics-basic : Lab forensique de base"
        fi
        echo ""
        pause_if_tty
    }
    
    stop_lab_interactive() {
        show_header
        printf "${CYAN}${BOLD}🛑 ARRÊTER UN LAB${RESET}\n\n"
        if command -v stop_lab >/dev/null 2>&1; then
            printf "Nom du lab à arrêter: "
            read lab_name
            if [ -n "$lab_name" ]; then
                stop_lab "$lab_name"
            fi
        else
            printf "${YELLOW}⚠️  Fonction stop_lab non disponible${RESET}\n"
        fi
        pause_if_tty
    }
    
    show_labs_status() {
        show_header
        printf "${CYAN}${BOLD}📊 STATUT DES LABS${RESET}\n\n"
        if command -v show_labs_status >/dev/null 2>&1; then
            show_labs_status
        else
            if command -v docker >/dev/null 2>&1; then
                echo "Labs Docker actifs:"
                docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "cyberlearn|NAME" || echo "Aucun lab actif"
            else
                echo "Docker n'est pas installé"
            fi
        fi
        echo ""
        pause_if_tty
    }
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║            CYBERLEARN - Apprentissage Cybersécurité              ║"
        echo "║              Plateforme d'Apprentissage Terminal               ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        
        # Afficher la progression globale
        total_modules=$(get_total_modules)
        completed_modules=$(get_completed_modules)
        if [ "$total_modules" -gt 0 ]; then
            progress_percent=$((completed_modules * 100 / total_modules))
        else
            progress_percent=0
        fi
        
        printf "${CYAN}${BOLD}📊 Votre Progression:${RESET}\n"
        printf "   ${GREEN}Modules complétés:${RESET} %s/%s (%d%%)\n" "$completed_modules" "$total_modules" "$progress_percent"
        printf "   ${GREEN}Labs complétés:${RESET} %s/%s\n" "$(get_completed_labs_count)" "$(get_total_labs_count)"
        echo ""
        
        printf "${YELLOW}${BOLD}📚 MENU PRINCIPAL${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        printf "${BOLD}1.${RESET} 📖 Modules de Cours\n"
        printf "${BOLD}2.${RESET} 🧪 Labs Pratiques\n"
        printf "${BOLD}3.${RESET} 📊 Ma Progression\n"
        printf "${BOLD}4.${RESET} 🎯 Exercices & Challenges\n"
        printf "${BOLD}5.${RESET} 🐳 Gérer les Environnements Docker\n"
        printf "${BOLD}6.${RESET} 📝 Certificats & Badges\n"
        printf "${BOLD}7.${RESET} ❓ Aide & Documentation\n"
        printf "${BOLD}0.${RESET} Quitter\n"
        echo ""
        choice=$(cyberlearn_pick_menu "CYBERLEARN - Menu principal" <<'EOF'
Modules de cours|1
Labs pratiques|2
Ma progression|3
Exercices et challenges|4
Gerer environnements Docker|5
Certificats et badges|6
Aide et documentation|7
Quitter|0
EOF
        )
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
            *)
                printf "${RED}❌ Choix invalide: %s${RESET}\n" "$choice"
                sleep 2
                ;;
        esac
    }
    
    # Fonction pour afficher le menu des modules
    show_modules_menu() {
        show_header
        printf "${YELLOW}${BOLD}📖 MODULES DE COURS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        printf "${BOLD}1.${RESET} 🎯 Bases de la Cybersécurité\n"
        printf "${BOLD}2.${RESET} 🌐 Sécurité Réseau\n"
        printf "${BOLD}3.${RESET} 🕸️  Sécurité Web\n"
        printf "${BOLD}4.${RESET} 🔐 Cryptographie\n"
        printf "${BOLD}5.${RESET} 🐧 Sécurité Linux\n"
        printf "${BOLD}6.${RESET} 🪟 Sécurité Windows\n"
        printf "${BOLD}7.${RESET} 📱 Sécurité Mobile\n"
        printf "${BOLD}8.${RESET} 🔍 Forensique Numérique\n"
        printf "${BOLD}9.${RESET} 🛡️  Tests de Pénétration\n"
        printf "${BOLD}10.${RESET} 🚨 Incident Response\n"
        printf "${BOLD}11.${RESET} 📋 Liste tous les modules\n"
        printf "${BOLD}0.${RESET} Retour\n"
        echo ""
        choice=$(cyberlearn_pick_menu "CYBERLEARN - Modules" <<'EOF'
Bases cybersecurite|1
Securite reseau|2
Securite web|3
Cryptographie|4
Securite Linux|5
Securite Windows|6
Securite mobile|7
Forensique numerique|8
Tests de penetration|9
Incident response|10
Lister tous les modules|11
Retour|0
EOF
        )
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
            *)
                printf "${RED}❌ Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
    }
    
    # Fonction pour démarrer un module
    start_module() {
        module_name="$1"
        module_file="$CYBERLEARN_MODULES_DIR/$module_name/module.zsh"
        
        if [ -f "$module_file" ]; then
            . "$module_file"
            if command -v run_module >/dev/null 2>&1; then
                run_module "$module_name"
            else
                printf "${YELLOW}⚠️  Fonction run_module non disponible${RESET}\n"
            fi
        else
            printf "${RED}❌ Module '%s' non trouvé${RESET}\n" "$module_name"
            printf "${YELLOW}💡 Les modules seront créés progressivement${RESET}\n"
            sleep 2
        fi
    }
    
    # Fonction pour lister tous les modules
    list_all_modules() {
        show_header
        printf "${YELLOW}${BOLD}📋 TOUS LES MODULES DISPONIBLES${RESET}\n\n"
        
        modules="basics network web crypto linux windows mobile forensics pentest incident"
        
        for module in $modules; do
            status=$(get_module_status "$module")
            icon="⭕"
            case "$status" in
                completed) icon="✅" ;;
                in_progress) icon="🔄" ;;
            esac
            
            printf "${icon} ${BOLD}%s${RESET} - %s\n" "$module" "$(get_module_description "$module")"
        done
        
        echo ""
        pause_if_tty
    }
    
    # Fonction pour afficher le menu des labs
    show_labs_menu() {
        show_header
        printf "${YELLOW}${BOLD}🧪 LABS PRATIQUES${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        printf "${BOLD}1.${RESET} 🚀 Démarrer un Lab\n"
        printf "${BOLD}2.${RESET} 📋 Lister les Labs Disponibles\n"
        printf "${BOLD}3.${RESET} 🛑 Arrêter un Lab Actif\n"
        printf "${BOLD}4.${RESET} 📊 Statut des Labs\n"
        printf "${BOLD}0.${RESET} Retour\n"
        echo ""
        choice=$(cyberlearn_pick_menu "CYBERLEARN - Labs" <<'EOF'
Demarrer un lab|1
Lister les labs|2
Arreter un lab|3
Statut des labs|4
Retour|0
EOF
        )
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        case "$choice" in
            1|start) start_lab_interactive ;;
            2|list) list_available_labs ;;
            3|stop) stop_lab_interactive ;;
            4|status) show_labs_status ;;
            0) return ;;
            *)
                printf "${RED}❌ Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
    }
    
    # Fonction pour afficher le menu de progression
    show_progress_menu() {
        show_header
        printf "${YELLOW}${BOLD}📊 MA PROGRESSION${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        show_detailed_progress
        
        echo ""
        printf "${BOLD}1.${RESET} 📈 Statistiques Détaillées\n"
        printf "${BOLD}2.${RESET} 🏆 Badges Obtenus\n"
        printf "${BOLD}3.${RESET} 📜 Historique d'Apprentissage\n"
        printf "${BOLD}4.${RESET} 🔄 Réinitialiser la Progression\n"
        printf "${BOLD}0.${RESET} Retour\n"
        echo ""
        choice=$(cyberlearn_pick_menu "CYBERLEARN - Progression" <<'EOF'
Statistiques detaillees|1
Badges obtenus|2
Historique apprentissage|3
Reinitialiser progression|4
Retour|0
EOF
        )
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        case "$choice" in
            1|stats) show_detailed_stats ;;
            2|badges) show_badges_detailed ;;
            3|history) show_learning_history ;;
            4|reset) reset_progress_confirm ;;
            0) return ;;
            *)
                printf "${RED}❌ Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
    }
    
    # Fonction pour afficher le menu des exercices
    show_exercises_menu() {
        show_header
        printf "${YELLOW}${BOLD}🎯 EXERCICES & CHALLENGES${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        printf "${BOLD}1.${RESET} 🎯 Challenge du Jour\n"
        printf "${BOLD}2.${RESET} 📝 Exercices par Module\n"
        printf "${BOLD}3.${RESET} 🏁 Challenges Avancés\n"
        printf "${BOLD}4.${RESET} 🎮 Mode Pratique\n"
        printf "${BOLD}0.${RESET} Retour\n"
        echo ""
        choice=$(cyberlearn_pick_menu "CYBERLEARN - Exercices" <<'EOF'
Challenge du jour|1
Exercices par module|2
Challenges avances|3
Mode pratique|4
Retour|0
EOF
        )
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        case "$choice" in
            1|daily) show_daily_challenge ;;
            2|module) show_module_exercises ;;
            3|advanced) show_advanced_challenges ;;
            4|practice) start_practice_mode ;;
            0) return ;;
            *)
                printf "${RED}❌ Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
    }
    
    # Fonction pour afficher le challenge du jour
    show_daily_challenge() {
        show_header
        printf "${CYAN}${BOLD}🎯 CHALLENGE DU JOUR${RESET}\n\n"
        
        today=$(date +%Y-%m-%d)
        challenge_file="$CYBERLEARN_DATA_DIR/daily_challenges/$today.json"
        
        # Générer un challenge aléatoire basé sur la date
        day_of_year=$(date +%j)
        challenge_num=$((day_of_year % 10))
        
        case "$challenge_num" in
            0) challenge="Basics: Créez un mot de passe fort et vérifiez sa force" ;;
            1) challenge="Network: Scannez votre réseau local et identifiez 3 hôtes actifs" ;;
            2) challenge="Web: Analysez les cookies d'un site web avec curl" ;;
            3) challenge="Crypto: Chiffrez un fichier avec GPG" ;;
            4) challenge="Linux: Analysez les permissions d'un fichier système" ;;
            5) challenge="Network: Capturez 10 paquets avec tcpdump" ;;
            6) challenge="Web: Testez une application web avec OWASP ZAP" ;;
            7) challenge="Basics: Vérifiez l'intégrité d'un fichier avec SHA256" ;;
            8) challenge="Network: Analysez un port ouvert avec nmap" ;;
            9) challenge="Web: Identifiez les vulnérabilités OWASP Top 10 sur un site" ;;
        esac
        
        printf "${GREEN}Challenge:${RESET} %s\n" "$challenge"
        printf "${BLUE}Date:${RESET} %s\n" "$today"
        echo ""
        printf "${YELLOW}💡 Complétez ce challenge pour gagner des points !${RESET}\n"
        echo ""
        printf "${BOLD}1.${RESET} Marquer comme complété\n"
        printf "${BOLD}2.${RESET} Voir les challenges précédents\n"
        printf "${BOLD}0.${RESET} Retour\n"
        echo ""
        choice=$(cyberlearn_pick_menu "CYBERLEARN - Challenge du jour" <<'EOF'
Marquer comme complete|1
Voir challenges precedents|2
Retour|0
EOF
        )
        
        case "$choice" in
            1)
                # Marquer comme complété
                mkdir -p "$CYBERLEARN_DATA_DIR/daily_challenges"
                printf "{\"date\":\"%s\",\"completed\":true,\"challenge\":\"%s\"}\n" "$today" "$challenge" > "$challenge_file"
                printf "${GREEN}✅ Challenge complété ! +10 points${RESET}\n"
                sleep 2
                ;;
            2)
                echo ""
                printf "${CYAN}Challenges précédents:${RESET}\n"
                ls -1 "$CYBERLEARN_DATA_DIR/daily_challenges" 2>/dev/null | tail -5 || echo "Aucun challenge précédent"
                echo ""
                pause_if_tty
                ;;
        esac
    }
    
    # Fonction pour afficher les exercices par module
    show_module_exercises() {
        show_header
        printf "${CYAN}${BOLD}📝 EXERCICES PAR MODULE${RESET}\n\n"
        
        echo "Sélectionnez un module pour voir ses exercices:"
        echo ""
        printf "${BOLD}1.${RESET} Basics\n"
        printf "${BOLD}2.${RESET} Network\n"
        printf "${BOLD}3.${RESET} Web\n"
        printf "${BOLD}0.${RESET} Retour\n"
        echo ""
        choice=$(cyberlearn_pick_menu "CYBERLEARN - Exercices par module" <<'EOF'
Basics|1
Network|2
Web|3
Retour|0
EOF
        )
        
        case "$choice" in
            1) start_module "basics" ;;
            2) start_module "network" ;;
            3) start_module "web" ;;
            0) return ;;
            *)
                printf "${RED}❌ Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
    }
    
    # Fonction pour afficher les challenges avancés
    show_advanced_challenges() {
        show_header
        printf "${CYAN}${BOLD}🏁 CHALLENGES AVANCÉS${RESET}\n\n"
        
        printf "${BOLD}1.${RESET} Capture The Flag (CTF) - Network\n"
        printf "${BOLD}2.${RESET} CTF - Web\n"
        printf "${BOLD}3.${RESET} CTF - Crypto\n"
        printf "${BOLD}4.${RESET} CTF - Forensics\n"
        printf "${BOLD}0.${RESET} Retour\n"
        echo ""
        choice=$(cyberlearn_pick_menu "CYBERLEARN - Challenges avances" <<'EOF'
CTF Network|1
CTF Web|2
CTF Crypto|3
CTF Forensics|4
Retour|0
EOF
        )
        
        case "$choice" in
            1)
                echo ""
                printf "${GREEN}CTF Network:${RESET}\n"
                echo "Objectif: Trouver le flag caché dans un réseau"
                echo "1. Scannez le réseau: nmap -sn 192.168.1.0/24"
                echo "2. Identifiez les services: nmap -sV <target>"
                echo "3. Trouvez le flag dans un service"
                echo ""
                pause_if_tty
                ;;
            2)
                echo ""
                printf "${GREEN}CTF Web:${RESET}\n"
                echo "Objectif: Trouver le flag dans une application web"
                echo "1. Analysez l'application: curl -v http://target"
                echo "2. Testez les vulnérabilités OWASP Top 10"
                echo "3. Trouvez le flag"
                echo ""
                pause_if_tty
                ;;
            3)
                echo ""
                printf "${GREEN}CTF Crypto:${RESET}\n"
                echo "Objectif: Déchiffrer un message"
                echo "1. Identifiez le type de chiffrement"
                echo "2. Utilisez les outils appropriés"
                echo "3. Déchiffrez le flag"
                echo ""
                pause_if_tty
                ;;
            4)
                echo ""
                printf "${GREEN}CTF Forensics:${RESET}\n"
                echo "Objectif: Analyser des données forensiques"
                echo "1. Analysez les fichiers fournis"
                echo "2. Utilisez les outils forensiques"
                echo "3. Trouvez le flag caché"
                echo ""
                pause_if_tty
                ;;
            0) return ;;
            *)
                printf "${RED}❌ Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
    }
    
    # Fonction pour démarrer le mode pratique
    start_practice_mode() {
        show_header
        printf "${CYAN}${BOLD}🎮 MODE PRATIQUE${RESET}\n\n"
        
        echo "Le mode pratique vous permet de pratiquer sans limite."
        echo ""
        printf "${BOLD}1.${RESET} Démarrer un lab Docker\n"
        printf "${BOLD}2.${RESET} Créer un environnement de test\n"
        printf "${BOLD}3.${RESET} Pratiquer avec des outils\n"
        printf "${BOLD}0.${RESET} Retour\n"
        echo ""
        choice=$(cyberlearn_pick_menu "CYBERLEARN - Mode pratique" <<'EOF'
Demarrer un lab Docker|1
Creer environnement de test|2
Pratiquer avec des outils|3
Retour|0
EOF
        )
        
        case "$choice" in
            1) show_labs_menu ;;
            2)
                echo ""
                printf "${GREEN}Création d'un environnement de test...${RESET}\n"
                echo "Utilisez Docker pour créer un environnement isolé:"
                echo "  docker run -it --rm ubuntu:22.04"
                echo ""
                pause_if_tty
                ;;
            3)
                echo ""
                printf "${GREEN}Outils disponibles:${RESET}\n"
                echo "  • nmap - Scanning réseau"
                echo "  • wireshark - Analyse de trafic"
                echo "  • sqlmap - Test SQL injection"
                echo "  • burp suite - Test web"
                echo ""
                pause_if_tty
                ;;
            0) return ;;
            *)
                printf "${RED}❌ Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
    }
    
    # Fonction pour afficher le menu Docker
    show_docker_menu() {
        show_header
        printf "${YELLOW}${BOLD}🐳 GESTION DES ENVIRONNEMENTS DOCKER${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        printf "${BOLD}1.${RESET} 🚀 Démarrer un Environnement\n"
        printf "${BOLD}2.${RESET} 🛑 Arrêter un Environnement\n"
        printf "${BOLD}3.${RESET} 📋 Lister les Environnements\n"
        printf "${BOLD}4.${RESET} 🔧 Construire une Image\n"
        printf "${BOLD}5.${RESET} 🧹 Nettoyer les Containers\n"
        printf "${BOLD}0.${RESET} Retour\n"
        echo ""
        choice=$(cyberlearn_pick_menu "CYBERLEARN - Docker" <<'EOF'
Demarrer un environnement|1
Arreter un environnement|2
Lister environnements|3
Construire une image|4
Nettoyer les containers|5
Retour|0
EOF
        )
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        case "$choice" in
            1|start) docker_start_environment ;;
            2|stop) docker_stop_environment ;;
            3|list) docker_list_environments ;;
            4|build) docker_build_image ;;
            5|clean) docker_cleanup ;;
            0) return ;;
            *)
                printf "${RED}❌ Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
    }
    
    # Fonctions Docker (stubs améliorés)
    docker_start_environment() {
        show_header
        printf "${CYAN}${BOLD}🚀 DÉMARRER UN ENVIRONNEMENT DOCKER${RESET}\n\n"
        echo "Utilisez le menu Labs pour démarrer des environnements spécifiques."
        echo ""
        pause_if_tty
        show_labs_menu
    }
    
    docker_stop_environment() {
        show_header
        printf "${CYAN}${BOLD}🛑 ARRÊTER UN ENVIRONNEMENT DOCKER${RESET}\n\n"
        if command -v docker >/dev/null 2>&1; then
            echo "Containers actifs:"
            docker ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null | grep -E "cyberlearn|NAME" || echo "Aucun container cyberlearn actif"
            echo ""
            printf "Nom du container à arrêter: "
            read container_name
            if [ -n "$container_name" ]; then
                docker stop "$container_name" 2>/dev/null && printf "${GREEN}✅ Container arrêté${RESET}\n" || printf "${RED}❌ Erreur${RESET}\n"
            fi
        else
            printf "${RED}❌ Docker n'est pas installé${RESET}\n"
        fi
        echo ""
        pause_if_tty
    }
    
    docker_list_environments() {
        show_header
        printf "${CYAN}${BOLD}📋 ENVIRONNEMENTS DOCKER${RESET}\n\n"
        if command -v docker >/dev/null 2>&1; then
            printf "${GREEN}Containers actifs:${RESET}\n"
            docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | grep -E "cyberlearn|NAME" || echo "Aucun container cyberlearn actif"
            echo ""
            printf "${YELLOW}Containers arrêtés:${RESET}\n"
            docker ps -a --format "table {{.Names}}\t{{.Status}}" 2>/dev/null | grep cyberlearn || echo "Aucun container cyberlearn arrêté"
        else
            printf "${RED}❌ Docker n'est pas installé${RESET}\n"
        fi
        echo ""
        pause_if_tty
    }
    
    docker_build_image() {
        show_header
        printf "${CYAN}${BOLD}🔧 CONSTRUIRE UNE IMAGE DOCKER${RESET}\n\n"
        echo "Les images des labs sont construites automatiquement lors du démarrage."
        echo "Pour construire manuellement:"
        echo "  docker build -t cyberlearn-<lab-name> <lab-directory>"
        echo ""
        pause_if_tty
    }
    
    docker_cleanup() {
        show_header
        printf "${CYAN}${BOLD}🧹 NETTOYER LES CONTAINERS${RESET}\n\n"
        if command -v docker >/dev/null 2>&1; then
            printf "${YELLOW}⚠️  Suppression des containers cyberlearn arrêtés...${RESET}\n"
            docker ps -a --filter "name=cyberlearn" --format "{{.Names}}" 2>/dev/null | xargs -r docker rm 2>/dev/null || true
            printf "${GREEN}✅ Nettoyage terminé${RESET}\n"
        else
            printf "${RED}❌ Docker n'est pas installé${RESET}\n"
        fi
        echo ""
        pause_if_tty
    }
    
    # Fonction pour afficher le menu des certificats
    show_certificates_menu() {
        show_header
        printf "${YELLOW}${BOLD}📝 CERTIFICATS & BADGES${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        show_badges
        echo ""
        printf "${BOLD}1.${RESET} 📜 Générer un Certificat\n"
        printf "${BOLD}2.${RESET} 🏆 Voir mes Badges\n"
        printf "${BOLD}0.${RESET} Retour\n"
        echo ""
        choice=$(cyberlearn_pick_menu "CYBERLEARN - Certificats" <<'EOF'
Generer un certificat|1
Voir mes badges|2
Retour|0
EOF
        )
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        case "$choice" in
            1|cert) generate_certificate ;;
            2|badges) show_badges_detailed ;;
            0) return ;;
            *)
                printf "${RED}❌ Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
    }
    
    # Fonction pour générer un certificat
    generate_certificate() {
        show_header
        printf "${CYAN}${BOLD}📜 GÉNÉRER UN CERTIFICAT${RESET}\n\n"
        
        completed_modules=$(get_completed_modules)
        total_modules=$(get_total_modules)
        
        if [ "$completed_modules" -ge "$total_modules" ]; then
            printf "${GREEN}✅ Félicitations ! Vous avez complété tous les modules !${RESET}\n"
            echo ""
            echo "Génération du certificat..."
            cert_file="$CYBERLEARN_DATA_DIR/certificate_$(date +%Y%m%d).txt"
            {
                echo "╔════════════════════════════════════════════════════════════════╗"
                echo "║                    CERTIFICAT DE COMPLÉTION                   ║"
                echo "║                  CYBERLEARN - CYBERSÉCURITÉ                  ║"
                echo "╚════════════════════════════════════════════════════════════════╝"
                echo ""
                echo "Ceci certifie que"
                echo ""
                echo "$(whoami)"
                echo ""
                echo "a complété avec succès tous les modules de cybersécurité"
                echo ""
                echo "Date: $(date '+%d/%m/%Y')"
                echo "Modules complétés: $completed_modules/$total_modules"
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
            } > "$cert_file"
            printf "${GREEN}✅ Certificat généré: %s${RESET}\n" "$cert_file"
            cat "$cert_file"
        else
            printf "${YELLOW}⚠️  Vous devez compléter tous les modules pour obtenir le certificat${RESET}\n"
            echo "Progression: $completed_modules/$total_modules modules complétés"
        fi
        echo ""
        pause_if_tty
    }
    
    # Fonction pour afficher les badges détaillés
    show_badges_detailed() {
        show_header
        printf "${CYAN}${BOLD}🏆 MES BADGES${RESET}\n\n"
        
        if command -v jq >/dev/null 2>&1 && [ -f "$CYBERLEARN_PROGRESS_FILE" ]; then
            badges=$(jq -r '.badges[]? // empty' "$CYBERLEARN_PROGRESS_FILE" 2>/dev/null)
            if [ -n "$badges" ]; then
                echo "$badges" | while IFS= read -r badge; do
                    case "$badge" in
                        basics-completed) printf "  🎯 %s - Module Basics complété\n" "$badge" ;;
                        network-completed) printf "  🌐 %s - Module Network complété\n" "$badge" ;;
                        web-completed) printf "  🕸️  %s - Module Web complété\n" "$badge" ;;
                        lab-master) printf "  🧪 %s - 5 labs complétés\n" "$badge" ;;
                        cyber-expert) printf "  🏆 %s - Tous les modules complétés\n" "$badge" ;;
                        *) printf "  🏅 %s\n" "$badge" ;;
                    esac
                done
            else
                echo "  Aucun badge obtenu pour le moment"
                echo ""
                echo "Gagnez des badges en complétant les modules et labs !"
            fi
        else
            echo "  Aucun badge obtenu pour le moment"
        fi
        echo ""
        pause_if_tty
    }
    
    # Fonction pour afficher l'aide
    show_help_menu() {
        show_header
        printf "${CYAN}${BOLD}❓ AIDE & DOCUMENTATION${RESET}\n\n"
        
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
        pause_if_tty
    }
    
    # Si un argument est fourni, lancer directement la commande
    if [ -n "$1" ]; then
        _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
        [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ] && . "$_logdf/scripts/lib/managers_log_posix.sh" && managers_cli_log cyberlearn "$@"
        cmd=$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        
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
                    start)
                        if [ -n "$3" ]; then
                            if command -v start_lab >/dev/null 2>&1; then
                                start_lab "$3"
                            else
                                printf "${YELLOW}⚠️  Fonction start_lab non disponible${RESET}\n"
                            fi
                        else
                            start_lab_interactive
                        fi
                        ;;
                    stop)
                        if [ -n "$3" ]; then
                            if command -v stop_lab >/dev/null 2>&1; then
                                stop_lab "$3"
                            else
                                printf "${YELLOW}⚠️  Fonction stop_lab non disponible${RESET}\n"
                            fi
                        else
                            stop_lab_interactive
                        fi
                        ;;
                    list) list_available_labs ;;
                    status) show_labs_status ;;
                    *)
                        printf "${RED}❌ Usage: cyberlearn lab [start|stop|list|status] [nom]${RESET}\n"
                        return 1
                        ;;
                esac
                ;;
            progress|progression) show_progress_menu ;;
            help|aide|--help|-h) show_help_menu ;;
            *)
                printf "${RED}❌ Commande inconnue: %s${RESET}\n" "$1"
                echo ""
                printf "${YELLOW}Commandes disponibles:${RESET}\n"
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
