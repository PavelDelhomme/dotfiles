#!/bin/zsh
# =============================================================================
# HELPMAN - Guide interactif du système d'aide
# =============================================================================
# Description: Guide interactif pour comprendre et utiliser man, help, et le système d'aide
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Guide interactif pour comprendre le système d'aide
# USAGE: helpman
# EXAMPLE: helpman
helpman() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local MAGENTA='\033[0;35m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    DOTFILES_PATH="${DOTFILES_PATH:-$HOME/dotfiles}"
    FUNCTIONS_DIR="$DOTFILES_PATH/zsh/functions"
    
    while true; do
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║              HELPMAN - GUIDE DU SYSTÈME D'AIDE                 ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo ""
        echo -e "${YELLOW}📚 Bienvenue dans le guide interactif du système d'aide !${RESET}"
        echo ""
        echo "Ce guide vous explique comment utiliser les différents outils d'aide"
        echo "disponibles dans vos dotfiles personnalisés."
        echo ""
        echo -e "${BOLD}Menu principal:${RESET}"
        echo ""
        echo "1.  Qu'est-ce que 'man' ?"
        echo "2.  Qu'est-ce que 'help' ?"
        echo "3.  Différences entre 'man' et 'help'"
        echo "4.  Comment utiliser 'man' ?"
        echo "5.  Comment utiliser 'help' ?"
        echo "6.  Exemples pratiques"
        echo "7.  Liste des fonctions disponibles"
        echo "8.  Rechercher une fonction"
        echo "9.  Aide sur le système d'aide lui-même"
        echo "0.  Quitter"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                _show_what_is_man
                ;;
            2)
                _show_what_is_help
                ;;
            3)
                _show_differences
                ;;
            4)
                _show_how_to_use_man
                ;;
            5)
                _show_how_to_use_help
                ;;
            6)
                _show_examples
                ;;
            7)
                _list_functions_interactive
                ;;
            8)
                _search_function_interactive
                ;;
            9)
                _show_help_system_info
                ;;
            0)
                echo ""
                echo -e "${GREEN}Au revoir ! Utilisez 'helpman' à tout moment pour revenir ici.${RESET}"
                echo ""
                return 0
                ;;
            *)
                echo -e "${RED}Choix invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

# Fonction pour expliquer ce qu'est 'man'
_show_what_is_man() {
    local CYAN='\033[0;36m'
    local YELLOW='\033[1;33m'
    local GREEN='\033[0;32m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    QU'EST-CE QUE 'man' ?                       ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
    echo -e "${BOLD}📖 Définition:${RESET}"
    echo ""
    echo "  'man' est une commande qui affiche la documentation complète"
    echo "  d'une fonction ou d'une commande au format 'man page'."
    echo ""
    echo -e "${BOLD}🎯 Utilité:${RESET}"
    echo ""
    echo "  • Documentation complète et détaillée"
    echo "  • Format traditionnel Unix/Linux"
    echo "  • Affichage avec coloration et formatage"
    echo "  • Support des pages man système ET personnalisées"
    echo ""
    echo -e "${BOLD}📋 Types de pages man disponibles:${RESET}"
    echo ""
    echo "  1. ${GREEN}Pages man système${RESET} (commandes Linux standard)"
    echo "     Exemple: man ls, man grep, man find"
    echo ""
    echo "  2. ${GREEN}Pages man personnalisées${RESET} (vos fonctions)"
    echo "     Exemple: man extract, man update, man pathman"
    echo ""
    echo -e "${BOLD}💡 Caractéristiques:${RESET}"
    echo ""
    echo "  • Documentation au format Markdown"
    echo "  • Affichage avec différents viewers (bat, glow, pandoc, etc.)"
    echo "  • Génération automatique depuis les commentaires DESC/USAGE/EXAMPLE"
    echo "  • Support UTF-8 et couleurs"
    echo ""
    echo -e "${YELLOW}💡 Astuce:${RESET} Utilisez 'man <nom_fonction>' pour voir la documentation complète"
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Fonction pour expliquer ce qu'est 'help'
_show_what_is_help() {
    local CYAN='\033[0;36m'
    local YELLOW='\033[1;33m'
    local GREEN='\033[0;32m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                   QU'EST-CE QUE 'help' ?                       ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
    echo -e "${BOLD}📖 Définition:${RESET}"
    echo ""
    echo "  'help' est une commande qui liste et affiche l'aide rapide"
    echo "  de toutes vos fonctions personnalisées."
    echo ""
    echo -e "${BOLD}🎯 Utilité:${RESET}"
    echo ""
    echo "  • Vue d'ensemble de toutes les fonctions"
    echo "  • Aide rapide et concise"
    echo "  • Organisation par catégories"
    echo "  • Recherche facile"
    echo ""
    echo -e "${BOLD}📋 Modes d'utilisation:${RESET}"
    echo ""
    echo "  1. ${GREEN}help${RESET} (sans argument)"
    echo "     → Liste toutes les fonctions organisées par catégories"
    echo ""
    echo "  2. ${GREEN}help <nom_fonction>${RESET}"
    echo "     → Affiche l'aide détaillée d'une fonction spécifique"
    echo ""
    echo "  3. ${GREEN}help <catégorie>${RESET}"
    echo "     → Liste les fonctions d'une catégorie spécifique"
    echo ""
    echo -e "${BOLD}💡 Caractéristiques:${RESET}"
    echo ""
    echo "  • Affichage organisé par répertoires/catégories"
    echo "  • Descriptions tronquées pour lisibilité"
    echo "  • Format compact et coloré"
    echo "  • Extraction automatique depuis DESC/USAGE/EXAMPLE"
    echo ""
    echo -e "${YELLOW}💡 Astuce:${RESET} Utilisez 'help' pour découvrir rapidement les fonctions disponibles"
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Fonction pour expliquer les différences
_show_differences() {
    local CYAN='\033[0;36m'
    local YELLOW='\033[1;33m'
    local GREEN='\033[0;32m'
    local RED='\033[0;31m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║          DIFFÉRENCES ENTRE 'man' ET 'help'                     ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
    echo -e "${BOLD}📊 Tableau comparatif:${RESET}"
    echo ""
    printf "%-20s %-30s %-30s\n" "Caractéristique" "help" "man"
    echo "────────────────────────────────────────────────────────────────────────────────────"
    printf "%-20s ${GREEN}%-30s${RESET} ${YELLOW}%-30s${RESET}\n" "Type" "Aide rapide" "Documentation complète"
    printf "%-20s ${GREEN}%-30s${RESET} ${YELLOW}%-30s${RESET}\n" "Affichage" "Liste compacte" "Page formatée"
    printf "%-20s ${GREEN}%-30s${RESET} ${YELLOW}%-30s${RESET}\n" "Organisation" "Par catégories" "Par fonction"
    printf "%-20s ${GREEN}%-30s${RESET} ${YELLOW}%-30s${RESET}\n" "Recherche" "Vue d'ensemble" "Fonction spécifique"
    printf "%-20s ${GREEN}%-30s${RESET} ${YELLOW}%-30s${RESET}\n" "Format" "Texte simple" "Markdown formaté"
    printf "%-20s ${GREEN}%-30s${RESET} ${YELLOW}%-30s${RESET}\n" "Viewer" "Terminal direct" "bat/glow/pandoc"
    echo ""
    echo -e "${BOLD}🎯 Quand utiliser 'help' ?${RESET}"
    echo ""
    echo "  ✓ Vous voulez découvrir les fonctions disponibles"
    echo "  ✓ Vous cherchez une fonction rapidement"
    echo "  ✓ Vous voulez une vue d'ensemble"
    echo "  ✓ Vous avez besoin d'une aide rapide"
    echo ""
    echo -e "${BOLD}🎯 Quand utiliser 'man' ?${RESET}"
    echo ""
    echo "  ✓ Vous voulez la documentation complète"
    echo "  ✓ Vous connaissez déjà le nom de la fonction"
    echo "  ✓ Vous avez besoin de détails approfondis"
    echo "  ✓ Vous voulez voir des exemples détaillés"
    echo ""
    echo -e "${BOLD}💡 Workflow recommandé:${RESET}"
    echo ""
    echo "  1. Utilisez 'help' pour découvrir les fonctions"
    echo "  2. Utilisez 'help <fonction>' pour un aperçu rapide"
    echo "  3. Utilisez 'man <fonction>' pour la documentation complète"
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Fonction pour expliquer comment utiliser 'man'
_show_how_to_use_man() {
    local CYAN='\033[0;36m'
    local YELLOW='\033[1;33m'
    local GREEN='\033[0;32m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              COMMENT UTILISER 'man' ?                         ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
    echo -e "${BOLD}📖 Syntaxe de base:${RESET}"
    echo ""
    echo "  ${GREEN}man <nom_fonction>${RESET}"
    echo ""
    echo -e "${BOLD}📋 Exemples:${RESET}"
    echo ""
    echo "  ${YELLOW}1. Documentation d'une fonction personnalisée:${RESET}"
    echo "     ${GREEN}man extract${RESET}"
    echo "     → Affiche la documentation complète de la fonction extract"
    echo ""
    echo "  ${YELLOW}2. Documentation d'une commande système:${RESET}"
    echo "     ${GREEN}man ls${RESET}"
    echo "     → Affiche la page man système de la commande ls"
    echo ""
    echo "  ${YELLOW}3. Documentation d'une fonction avec chemin:${RESET}"
    echo "     ${GREEN}man pathman${RESET}"
    echo "     → Affiche la documentation de pathman"
    echo ""
    echo -e "${BOLD}🎯 Fonctionnalités:${RESET}"
    echo ""
    echo "  • ${GREEN}Génération automatique${RESET}: Les pages man sont générées depuis"
    echo "    les commentaires DESC/USAGE/EXAMPLE dans vos fonctions"
    echo ""
    echo "  • ${GREEN}Viewers multiples${RESET}: Utilise automatiquement le meilleur"
    echo "    viewer disponible (bat, glow, pandoc, etc.)"
    echo ""
    echo "  • ${GREEN}Support couleurs${RESET}: Affichage avec coloration syntaxique"
    echo ""
    echo "  • ${GREEN}Support UTF-8${RESET}: Caractères spéciaux et accents supportés"
    echo ""
    echo -e "${BOLD}💡 Astuces:${RESET}"
    echo ""
    echo "  • Utilisez 'q' pour quitter le viewer (si less/bat)"
    echo "  • Les pages man sont stockées dans ~/dotfiles/docs/man/"
    echo "  • Utilisez 'make generate-man' pour régénérer toutes les pages"
    echo ""
    echo -e "${YELLOW}💡 Essayez maintenant:${RESET} man extract"
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Fonction pour expliquer comment utiliser 'help'
_show_how_to_use_help() {
    local CYAN='\033[0;36m'
    local YELLOW='\033[1;33m'
    local GREEN='\033[0;32m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║             COMMENT UTILISER 'help' ?                         ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
    echo -e "${BOLD}📖 Syntaxes disponibles:${RESET}"
    echo ""
    echo "  ${GREEN}1. help${RESET} (sans argument)"
    echo "     → Liste toutes les fonctions organisées par catégories"
    echo ""
    echo "  ${GREEN}2. help <nom_fonction>${RESET}"
    echo "     → Affiche l'aide détaillée d'une fonction spécifique"
    echo ""
    echo "  ${GREEN}3. help <catégorie>${RESET}"
    echo "     → Liste les fonctions d'une catégorie (ex: help dev, help cyber)"
    echo ""
    echo -e "${BOLD}📋 Exemples pratiques:${RESET}"
    echo ""
    echo "  ${YELLOW}1. Découvrir toutes les fonctions:${RESET}"
    echo "     ${GREEN}help${RESET}"
    echo "     → Affiche toutes les fonctions par catégories"
    echo ""
    echo "  ${YELLOW}2. Aide sur une fonction spécifique:${RESET}"
    echo "     ${GREEN}help extract${RESET}"
    echo "     → Affiche DESC, USAGE, et EXAMPLES de extract"
    echo ""
    echo "  ${YELLOW}3. Lister les fonctions d'une catégorie:${RESET}"
    echo "     ${GREEN}help dev${RESET}"
    echo "     → Liste toutes les fonctions de développement"
    echo ""
    echo "  ${YELLOW}4. Rechercher par mot-clé:${RESET}"
    echo "     ${GREEN}help | grep git${RESET}"
    echo "     → Filtre les fonctions contenant 'git'"
    echo ""
    echo -e "${BOLD}🎯 Organisation par catégories:${RESET}"
    echo ""
    echo "  Les fonctions sont organisées selon leur répertoire:"
    echo "  • ${GREEN}dev/${RESET} - Fonctions de développement"
    echo "  • ${GREEN}cyber/${RESET} - Fonctions de cybersécurité"
    echo "  • ${GREEN}misc/${RESET} - Fonctions diverses"
    echo "  • ${GREEN}utils/${RESET} - Utilitaires"
    echo "  • etc."
    echo ""
    echo -e "${YELLOW}💡 Essayez maintenant:${RESET} help"
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Fonction pour montrer des exemples pratiques
_show_examples() {
    local CYAN='\033[0;36m'
    local YELLOW='\033[1;33m'
    local GREEN='\033[0;32m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    EXEMPLES PRATIQUES                           ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
    echo -e "${BOLD}📚 Scénarios d'utilisation:${RESET}"
    echo ""
    echo -e "${YELLOW}Scénario 1: Je veux découvrir les fonctions disponibles${RESET}"
    echo "  ${GREEN}→ help${RESET}"
    echo "  → Affiche toutes les fonctions par catégories"
    echo ""
    echo -e "${YELLOW}Scénario 2: Je cherche une fonction pour extraire des archives${RESET}"
    echo "  ${GREEN}→ help | grep -i extract${RESET}"
    echo "  → Trouve la fonction 'extract'"
    echo "  ${GREEN}→ help extract${RESET}"
    echo "  → Voir l'aide rapide"
    echo "  ${GREEN}→ man extract${RESET}"
    echo "  → Voir la documentation complète"
    echo ""
    echo -e "${YELLOW}Scénario 3: Je veux utiliser une fonction mais j'ai oublié la syntaxe${RESET}"
    echo "  ${GREEN}→ help <nom_fonction>${RESET}"
    echo "  → Affiche DESC, USAGE, et EXAMPLES"
    echo ""
    echo -e "${YELLOW}Scénario 4: Je veux la documentation complète d'une fonction${RESET}"
    echo "  ${GREEN}→ man <nom_fonction>${RESET}"
    echo "  → Documentation détaillée avec formatage"
    echo ""
    echo -e "${BOLD}💡 Workflow recommandé:${RESET}"
    echo ""
    echo "  1. ${GREEN}help${RESET}                    → Découvrir les fonctions"
    echo "  2. ${GREEN}help <fonction>${RESET}         → Aide rapide"
    echo "  3. ${GREEN}man <fonction>${RESET}          → Documentation complète"
    echo ""
    echo -e "${BOLD}🎯 Exemples concrets:${RESET}"
    echo ""
    echo "  ${GREEN}help extract${RESET}"
    echo "  ${GREEN}man extract${RESET}"
    echo "  ${GREEN}help pathman${RESET}"
    echo "  ${GREEN}man pathman${RESET}"
    echo "  ${GREEN}help cyberman${RESET}"
    echo "  ${GREEN}man cyberman${RESET}"
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Fonction pour lister les fonctions de manière interactive
_list_functions_interactive() {
    local CYAN='\033[0;36m'
    local YELLOW='\033[1;33m'
    local GREEN='\033[0;32m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              LISTE DES FONCTIONS DISPONIBLES                  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
    echo "Chargement de la liste des fonctions..."
    echo ""
    
    # Utiliser la commande help si disponible
    if command -v help >/dev/null 2>&1; then
        help | head -100
        echo ""
        echo -e "${YELLOW}💡 Utilisez 'help' dans votre terminal pour voir la liste complète${RESET}"
    else
        echo "⚠️  La commande 'help' n'est pas disponible"
        echo "💡 Assurez-vous que help_system.sh est chargé"
    fi
    
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Fonction pour rechercher une fonction de manière interactive
_search_function_interactive() {
    local CYAN='\033[0;36m'
    local YELLOW='\033[1;33m'
    local GREEN='\033[0;32m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              RECHERCHER UNE FONCTION                           ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
    printf "🔍 Entrez le nom ou un mot-clé de la fonction à rechercher: "
    read -r search_term
    
    if [ -z "$search_term" ]; then
        echo "❌ Terme de recherche vide"
        sleep 1
        return
    fi
    
    echo ""
    echo "Recherche en cours..."
    echo ""
    
    # Utiliser help avec grep si disponible
    if command -v help >/dev/null 2>&1; then
        help | grep -i "$search_term" | head -20
        echo ""
        echo -e "${YELLOW}💡 Utilisez 'help | grep <terme>' pour rechercher dans votre terminal${RESET}"
    else
        echo "⚠️  La commande 'help' n'est pas disponible"
    fi
    
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Fonction pour afficher des infos sur le système d'aide
_show_help_system_info() {
    local CYAN='\033[0;36m'
    local YELLOW='\033[1;33m'
    local GREEN='\033[0;32m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║          INFORMATIONS SUR LE SYSTÈME D'AIDE                   ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
    echo -e "${BOLD}📁 Fichiers du système:${RESET}"
    echo ""
    echo "  • ${GREEN}help_system.sh${RESET} - Système d'aide principal"
    echo "  • ${GREEN}list_functions.py${RESET} - Script Python pour lister les fonctions"
    echo "  • ${GREEN}helpman.zsh${RESET} - Ce guide interactif"
    echo "  • ${GREEN}docs/man/${RESET} - Répertoire des pages man Markdown"
    echo ""
    echo -e "${BOLD}🔧 Comment ça fonctionne:${RESET}"
    echo ""
    echo "  1. Les fonctions contiennent des commentaires spéciaux:"
    echo "     • ${GREEN}DESC:${RESET} Description de la fonction"
    echo "     • ${GREEN}USAGE:${RESET} Syntaxe d'utilisation"
    echo "     • ${GREEN}EXAMPLE:${RESET} Exemples d'utilisation"
    echo ""
    echo "  2. Le système extrait automatiquement ces commentaires"
    echo ""
    echo "  3. 'help' affiche une vue d'ensemble organisée"
    echo ""
    echo "  4. 'man' génère des pages Markdown formatées"
    echo ""
    echo -e "${BOLD}📝 Format des commentaires:${RESET}"
    echo ""
    echo "  # DESC: Description de la fonction"
    echo "  # USAGE: fonction <arg1> [arg2]"
    echo "  # EXAMPLE: fonction test"
    echo "  # EXAMPLE: fonction test arg2"
    echo ""
    echo -e "${BOLD}🛠️  Commandes utiles:${RESET}"
    echo ""
    echo "  • ${GREEN}make generate-man${RESET} - Génère toutes les pages man"
    echo "  • ${GREEN}help${RESET} - Liste toutes les fonctions"
    echo "  • ${GREEN}help <fonction>${RESET} - Aide d'une fonction"
    echo "  • ${GREEN}man <fonction>${RESET} - Documentation complète"
    echo "  • ${GREEN}helpman${RESET} - Ce guide interactif"
    echo ""
    echo -e "${BOLD}💡 Astuces:${RESET}"
    echo ""
    echo "  • Les pages man sont générées automatiquement"
    echo "  • Utilisez 'make generate-man' pour les régénérer"
    echo "  • Les viewers Markdown sont détectés automatiquement"
    echo "  • Le système supporte UTF-8 et les couleurs"
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

