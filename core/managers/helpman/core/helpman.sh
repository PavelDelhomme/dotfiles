#!/bin/sh
# =============================================================================
# HELPMAN - Help Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet du système d'aide et documentation
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

# DESC: Guide interactif pour comprendre le système d'aide
# USAGE: helpman
# EXAMPLE: helpman
helpman() {
    # Configuration des couleurs
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    MAGENTA='\033[0;35m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    HELPMAN_DIR="$DOTFILES_DIR/zsh/functions/helpman"
    FUNCTIONS_DIR="$DOTFILES_DIR/zsh/functions"
    
    while true; do
        clear
        printf "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║              HELPMAN - GUIDE DU SYSTÈME D'AIDE                 ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
        echo ""
        
        printf "${BOLD}Bienvenue dans le guide interactif de 'man' et 'help' !${RESET}\n"
        echo "Cet outil vous aidera à comprendre comment utiliser efficacement la documentation."
        echo ""
        printf "${YELLOW}Choisissez une option:${RESET}\n"
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
        read choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        echo ""
        case "$choice" in
            1)
                printf "${BOLD}1. Qu'est-ce que 'man' ?${RESET}\n"
                echo "   La commande 'man' (pour 'manual') est utilisée pour afficher les pages de manuel des commandes système, des fichiers de configuration, des appels système, etc."
                echo "   Elle fournit une documentation complète et détaillée, souvent formatée de manière standardisée (groff/nroff)."
                echo "   Notre système 'man' personnalisé étend cette fonctionnalité pour inclure la documentation de nos fonctions shell personnalisées, en utilisant le format Markdown."
                printf "   ${YELLOW}Appuyez sur 'q' pour quitter la page man.${RESET}\n"
                printf "Appuyez sur Entrée pour continuer... "
                read dummy
                ;;
            2)
                printf "${BOLD}2. Qu'est-ce que 'help' ?${RESET}\n"
                echo "   La commande 'help' (intégrée au shell) est utilisée pour obtenir une aide rapide et concise sur les commandes et fonctions internes du shell."
                echo "   Elle est plus légère que 'man' et est idéale pour un aperçu rapide de l'utilisation, des arguments et des descriptions courtes."
                echo "   Notre système 'help' personnalisé agrège la documentation 'DESC', 'USAGE' et 'EXAMPLE' directement depuis les commentaires de nos scripts de fonctions."
                printf "Appuyez sur Entrée pour continuer... "
                read dummy
                ;;
            3)
                printf "${BOLD}3. Différences entre 'man' et 'help'${RESET}\n"
                printf "   ${BLUE}Man (Manuel):${RESET}\n"
                echo "     - Portée: Documentation complète pour les commandes système, fichiers, appels système, et nos fonctions personnalisées (format Markdown)."
                echo "     - Détail: Très détaillé, inclut souvent des sections comme SYNOPSIS, DESCRIPTION, OPTIONS, EXAMPLES, BUGS, AUTHOR, SEE ALSO."
                echo "     - Format: Traditionnellement formaté avec groff/nroff, mais notre version personnalisée supporte le Markdown avec coloration."
                echo "     - Utilisation: Pour une compréhension approfondie ou lorsque vous avez besoin de toutes les options possibles."
                echo ""
                printf "   ${GREEN}Help (Aide Shell):${RESET}\n"
                echo "     - Portée: Aide rapide pour les commandes et fonctions internes du shell (built-ins) et nos fonctions personnalisées (DESC, USAGE, EXAMPLE)."
                echo "     - Détail: Concis, se concentre sur l'utilisation de base et les arguments essentiels."
                echo "     - Format: Texte brut, affiché directement dans le terminal."
                echo "     - Utilisation: Pour un rappel rapide de la syntaxe ou des options courantes."
                printf "Appuyez sur Entrée pour continuer... "
                read dummy
                ;;
            4)
                printf "${BOLD}4. Comment utiliser 'man' ?${RESET}\n"
                printf "   ${YELLOW}Syntaxe:${RESET} man <nom_fonction>\n"
                printf "   ${YELLOW}Exemples:${RESET}\n"
                echo "     man extract       # Documentation de la fonction extract"
                echo "     man ls            # Page man système pour ls"
                echo "     man cyberman      # Documentation de cyberman"
                echo ""
                printf "   ${YELLOW}Navigation:${RESET}\n"
                echo "     - Espace / Page Down : Page suivante"
                echo "     - b / Page Up : Page précédente"
                echo "     - /mot : Rechercher 'mot'"
                echo "     - n : Résultat suivant"
                echo "     - q : Quitter"
                printf "Appuyez sur Entrée pour continuer... "
                read dummy
                ;;
            5)
                printf "${BOLD}5. Comment utiliser 'help' ?${RESET}\n"
                printf "   ${YELLOW}Syntaxe:${RESET} help <nom_fonction>\n"
                printf "   ${YELLOW}Exemples:${RESET}\n"
                echo "     help extract      # Aide rapide sur extract"
                echo "     help             # Aide générale"
                echo "     help --list      # Liste toutes les fonctions"
                echo "     help --search archive  # Rechercher fonctions contenant 'archive'"
                echo ""
                printf "   ${YELLOW}Options:${RESET}\n"
                echo "     help              # Aide générale"
                echo "     help <fonction>   # Aide sur une fonction spécifique"
                echo "     help --list       # Liste toutes les fonctions disponibles"
                echo "     help --search <mot> # Rechercher des fonctions"
                printf "Appuyez sur Entrée pour continuer... "
                read dummy
                ;;
            6)
                printf "${BOLD}6. Exemples pratiques${RESET}\n"
                printf "   ${GREEN}Exemple 1: Aide rapide${RESET}\n"
                echo "     \$ help extract"
                echo "     # Affiche: DESC, USAGE, EXAMPLE pour extract"
                echo ""
                printf "   ${GREEN}Exemple 2: Documentation complète${RESET}\n"
                echo "     \$ man extract"
                echo "     # Affiche: Documentation complète avec formatage Markdown"
                echo ""
                printf "   ${GREEN}Exemple 3: Liste des fonctions${RESET}\n"
                echo "     \$ help --list"
                echo "     # Liste toutes les fonctions organisées par catégories"
                echo ""
                printf "   ${GREEN}Exemple 4: Recherche${RESET}\n"
                echo "     \$ help --search archive"
                echo "     # Trouve toutes les fonctions liées aux archives"
                printf "Appuyez sur Entrée pour continuer... "
                read dummy
                ;;
            7)
                printf "${BOLD}7. Liste des fonctions disponibles${RESET}\n"
                echo ""
                if [ -f "$HELPMAN_DIR/utils/list_functions.py" ]; then
                    python3 "$HELPMAN_DIR/utils/list_functions.py" "$FUNCTIONS_DIR" 2>/dev/null | head -50 || \
                    echo "⚠️  Erreur lors de la génération de la liste"
                elif command -v list_functions >/dev/null 2>&1; then
                    list_functions 2>/dev/null | head -50 || \
                    echo "⚠️  Erreur lors de la génération de la liste"
                else
                    echo "⚠️  Fonction list_functions non disponible"
                fi
                printf "Appuyez sur Entrée pour continuer... "
                read dummy
                ;;
            8)
                printf "${BOLD}8. Rechercher une fonction${RESET}\n"
                echo ""
                printf "🔍 Terme de recherche: "
                read search_term
                if [ -n "$search_term" ]; then
                    if [ -f "$HELPMAN_DIR/utils/list_functions.py" ]; then
                        python3 "$HELPMAN_DIR/utils/list_functions.py" "$FUNCTIONS_DIR" --search "$search_term" 2>/dev/null | head -30 || \
                        echo "⚠️  Erreur lors de la recherche"
                    elif command -v list_functions >/dev/null 2>&1; then
                        list_functions --search "$search_term" 2>/dev/null | head -30 || \
                        echo "⚠️  Erreur lors de la recherche"
                    else
                        echo "⚠️  Fonction de recherche non disponible"
                    fi
                fi
                printf "Appuyez sur Entrée pour continuer... "
                read dummy
                ;;
            9)
                printf "${BOLD}9. Aide sur le système d'aide lui-même${RESET}\n"
                echo "   Le système d'aide est basé sur des commentaires dans le code source."
                echo ""
                printf "   ${YELLOW}Format de documentation:${RESET}\n"
                echo "     # DESC: Description de la fonction"
                echo "     # USAGE: nom_fonction <arg1> [arg2]"
                echo "     # EXAMPLE: nom_fonction exemple1"
                echo ""
                printf "   ${YELLOW}Génération automatique:${RESET}\n"
                echo "     - Les pages man sont générées automatiquement depuis les commentaires"
                echo "     - Utilisez 'make generate-man' pour régénérer toutes les pages"
                echo ""
                printf "   ${YELLOW}Outils disponibles:${RESET}\n"
                echo "     - help <fonction> : Aide rapide"
                echo "     - man <fonction> : Documentation complète"
                echo "     - helpman : Ce guide interactif"
                printf "Appuyez sur Entrée pour continuer... "
                read dummy
                ;;
            0) return ;;
            *)
                printf "${RED}Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
    done
}
