#!/bin/sh
# Menu modules de cours + lancement (charge dans cyberlearn()).

show_modules_menu() {
    show_header
    printf "${YELLOW}${BOLD}📖 MODULES DE COURS${RESET}\n"
    manager_ui_section_line "${BLUE}" "${RESET}\n\n"

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
