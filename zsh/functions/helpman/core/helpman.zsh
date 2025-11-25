#!/bin/zsh
# =============================================================================
# HELPMAN - Help Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet du système d'aide et documentation
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoires de base
HELPMAN_DIR="${HELPMAN_DIR:-$HOME/dotfiles/zsh/functions/helpman}"
HELP_SYSTEM_FILE="$HELPMAN_DIR/core/help_system.sh"

# Charger le système d'aide
if [ -f "$HELP_SYSTEM_FILE" ]; then
    source "$HELP_SYSTEM_FILE"
fi

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
        
        echo -e "${BOLD}Bienvenue dans le guide interactif de 'man' et 'help' !${RESET}"
        echo "Cet outil vous aidera à comprendre comment utiliser efficacement la documentation."
        echo ""
        echo -e "${YELLOW}Choisissez une option:${RESET}"
        echo "  1. Qu'est-ce que 'man' ?"
        echo "  2. Qu'est-ce que 'help' ?"
        echo "  3. Différences entre 'man' et 'help'"
        echo "  4. Comment utiliser 'man' ?"
        echo "  5. Comment utiliser 'help' ?"
        echo "  6. Exemples pratiques"
        echo "  7. Liste des fonctions disponibles"
        echo "  8. Rechercher une fonction"
        echo "  9. Aide sur le système d'aide lui-même"
        echo "  0. Quitter"
        echo ""
        printf "${BLUE}Votre choix: ${RESET}"
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        echo ""
        case "$choice" in
            1)
                echo -e "${BOLD}1. Qu'est-ce que 'man' ?${RESET}" | less -R
                echo -e "   La commande 'man' (pour 'manual') est utilisée pour afficher les pages de manuel des commandes système, des fichiers de configuration, des appels système, etc." | less -R
                echo -e "   Elle fournit une documentation complète et détaillée, souvent formatée de manière standardisée (groff/nroff)." | less -R
                echo -e "   Notre système 'man' personnalisé étend cette fonctionnalité pour inclure la documentation de nos fonctions shell personnalisées, en utilisant le format Markdown." | less -R
                echo -e "   ${YELLOW}Appuyez sur 'q' pour quitter la page man.${RESET}" | less -R
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2)
                echo -e "${BOLD}2. Qu'est-ce que 'help' ?${RESET}" | less -R
                echo -e "   La commande 'help' (intégrée au shell) est utilisée pour obtenir une aide rapide et concise sur les commandes et fonctions internes du shell." | less -R
                echo -e "   Elle est plus légère que 'man' et est idéale pour un aperçu rapide de l'utilisation, des arguments et des descriptions courtes." | less -R
                echo -e "   Notre système 'help' personnalisé agrège la documentation 'DESC', 'USAGE' et 'EXAMPLE' directement depuis les commentaires de nos scripts de fonctions." | less -R
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3)
                echo -e "${BOLD}3. Différences entre 'man' et 'help'${RESET}" | less -R
                echo -e "   ${BLUE}Man (Manuel):${RESET}" | less -R
                echo -e "     - ${BOLD}Portée:${RESET} Documentation complète pour les commandes système, fichiers, appels système, et nos fonctions personnalisées (format Markdown)." | less -R
                echo -e "     - ${BOLD}Détail:${RESET} Très détaillé, inclut souvent des sections comme SYNOPSIS, DESCRIPTION, OPTIONS, EXAMPLES, BUGS, AUTHOR, SEE ALSO." | less -R
                echo -e "     - ${BOLD}Format:${RESET} Traditionnellement formaté avec groff/nroff, mais notre version personnalisée supporte le Markdown avec coloration." | less -R
                echo -e "     - ${BOLD}Utilisation:${RESET} Pour une compréhension approfondie ou lorsque vous avez besoin de toutes les options possibles." | less -R
                echo "" | less -R
                echo -e "   ${GREEN}Help (Aide Shell):${RESET}" | less -R
                echo -e "     - ${BOLD}Portée:${RESET} Aide rapide pour les commandes et fonctions internes du shell (built-ins) et nos fonctions personnalisées (DESC, USAGE, EXAMPLE)." | less -R
                echo -e "     - ${BOLD}Détail:${RESET} Concis, se concentre sur l'utilisation de base et les arguments essentiels." | less -R
                echo -e "     - ${BOLD}Format:${RESET} Texte brut, affiché directement dans le terminal." | less -R
                echo -e "     - ${BOLD}Utilisation:${RESET} Pour un rappel rapide de la syntaxe ou des options courantes." | less -R
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4)
                echo -e "${BOLD}4. Comment utiliser 'man' ?${RESET}" | less -R
                echo -e "   ${YELLOW}Syntaxe:${RESET} man <nom_fonction>" | less -R
                echo -e "   ${YELLOW}Exemples:${RESET}" | less -R
                echo -e "     man extract       # Documentation de la fonction extract" | less -R
                echo -e "     man ls            # Page man système pour ls" | less -R
                echo -e "     man cyberman      # Documentation de cyberman" | less -R
                echo -e "" | less -R
                echo -e "   ${YELLOW}Navigation:${RESET}" | less -R
                echo -e "     - Espace / Page Down : Page suivante" | less -R
                echo -e "     - b / Page Up : Page précédente" | less -R
                echo -e "     - /mot : Rechercher 'mot'" | less -R
                echo -e "     - n : Résultat suivant" | less -R
                echo -e "     - q : Quitter" | less -R
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            5)
                echo -e "${BOLD}5. Comment utiliser 'help' ?${RESET}" | less -R
                echo -e "   ${YELLOW}Syntaxe:${RESET} help <nom_fonction>" | less -R
                echo -e "   ${YELLOW}Exemples:${RESET}" | less -R
                echo -e "     help extract      # Aide rapide sur extract" | less -R
                echo -e "     help             # Aide générale" | less -R
                echo -e "     help --list      # Liste toutes les fonctions" | less -R
                echo -e "     help --search archive  # Rechercher fonctions contenant 'archive'" | less -R
                echo -e "" | less -R
                echo -e "   ${YELLOW}Options:${RESET}" | less -R
                echo -e "     help              # Aide générale" | less -R
                echo -e "     help <fonction>   # Aide sur une fonction spécifique" | less -R
                echo -e "     help --list       # Liste toutes les fonctions disponibles" | less -R
                echo -e "     help --search <mot> # Rechercher des fonctions" | less -R
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            6)
                echo -e "${BOLD}6. Exemples pratiques${RESET}" | less -R
                echo -e "   ${GREEN}Exemple 1: Aide rapide${RESET}" | less -R
                echo -e "     \$ help extract" | less -R
                echo -e "     # Affiche: DESC, USAGE, EXAMPLE pour extract" | less -R
                echo -e "" | less -R
                echo -e "   ${GREEN}Exemple 2: Documentation complète${RESET}" | less -R
                echo -e "     \$ man extract" | less -R
                echo -e "     # Affiche: Documentation complète avec formatage Markdown" | less -R
                echo -e "" | less -R
                echo -e "   ${GREEN}Exemple 3: Liste des fonctions${RESET}" | less -R
                echo -e "     \$ help --list" | less -R
                echo -e "     # Liste toutes les fonctions organisées par catégories" | less -R
                echo -e "" | less -R
                echo -e "   ${GREEN}Exemple 4: Recherche${RESET}" | less -R
                echo -e "     \$ help --search archive" | less -R
                echo -e "     # Trouve toutes les fonctions liées aux archives" | less -R
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            7)
                echo -e "${BOLD}7. Liste des fonctions disponibles${RESET}"
                echo ""
                if [ -f "$HELPMAN_DIR/utils/list_functions.py" ]; then
                    python3 "$HELPMAN_DIR/utils/list_functions.py" "$FUNCTIONS_DIR" | less -R
                elif command -v list_functions >/dev/null 2>&1; then
                    list_functions | less -R
                else
                    echo "⚠️  Fonction list_functions non disponible"
                fi
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            8)
                echo -e "${BOLD}8. Rechercher une fonction${RESET}"
                echo ""
                printf "🔍 Terme de recherche: "
                read -r search_term
                if [ -n "$search_term" ]; then
                    if [ -f "$HELPMAN_DIR/utils/list_functions.py" ]; then
                        python3 "$HELPMAN_DIR/utils/list_functions.py" "$FUNCTIONS_DIR" --search "$search_term" | less -R
                    elif command -v list_functions >/dev/null 2>&1; then
                        list_functions --search "$search_term" | less -R
                    else
                        echo "⚠️  Fonction de recherche non disponible"
                    fi
                fi
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            9)
                echo -e "${BOLD}9. Aide sur le système d'aide lui-même${RESET}" | less -R
                echo -e "   Le système d'aide est basé sur des commentaires dans le code source." | less -R
                echo -e "" | less -R
                echo -e "   ${YELLOW}Format de documentation:${RESET}" | less -R
                echo -e "     # DESC: Description de la fonction" | less -R
                echo -e "     # USAGE: nom_fonction <arg1> [arg2]" | less -R
                echo -e "     # EXAMPLE: nom_fonction exemple1" | less -R
                echo -e "" | less -R
                echo -e "   ${YELLOW}Génération automatique:${RESET}" | less -R
                echo -e "     - Les pages man sont générées automatiquement depuis les commentaires" | less -R
                echo -e "     - Utilisez 'make generate-man' pour régénérer toutes les pages" | less -R
                echo -e "" | less -R
                echo -e "   ${YELLOW}Outils disponibles:${RESET}" | less -R
                echo -e "     - help <fonction> : Aide rapide" | less -R
                echo -e "     - man <fonction> : Documentation complète" | less -R
                echo -e "     - helpman : Ce guide interactif" | less -R
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
}
