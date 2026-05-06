#!/bin/sh
# Labs interactifs + sous-menu (charge dans cyberlearn()).

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
