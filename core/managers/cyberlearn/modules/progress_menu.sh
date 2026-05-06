#!/bin/sh
# Sous-menu progression (charge dans cyberlearn()).

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
