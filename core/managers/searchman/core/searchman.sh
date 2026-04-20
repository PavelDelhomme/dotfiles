#!/bin/sh
# =============================================================================
# SEARCHMAN - Search Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet de recherche et exploration
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

# DESC: Gestionnaire interactif complet pour la recherche et l'exploration
# USAGE: searchman [command]
# EXAMPLE: searchman
# EXAMPLE: searchman history git
# EXAMPLE: searchman files "*.py"
searchman() {
    # Configuration des couleurs
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                   SEARCHMAN - Search Manager                   ║"
        echo "║               Gestionnaire de Recherche                        ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
        echo
    }
    
    # Recherche dans l'historique avec filtres avancés
    # DESC: Recherche avancée dans l'historique avec filtres
    # USAGE: search_history_advanced
    search_history_advanced() {
        show_header
        printf "${YELLOW}🔍 Recherche avancée dans l'historique${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        printf "Terme à rechercher: "
        read pattern
        if [ -z "$pattern" ]; then
            printf "${RED}❌ Terme de recherche requis${RESET}\n"
            sleep 2
            return
        fi
        
        printf "\n${CYAN}Options de recherche:${RESET}\n"
        echo "  1. Recherche simple"
        echo "  2. Recherche par date (dernières 24h)"
        echo "  3. Recherche par commande spécifique"
        echo "  4. Recherche avec contexte"
        echo
        printf "Type de recherche [1-4]: "
        read search_type
        
        case "$search_type" in
            1)
                printf "\n${CYAN}Résultats pour '$pattern':${RESET}\n"
                if [ "$SHELL_TYPE" = "zsh" ] && command -v fc >/dev/null 2>&1; then
                    fc -l 1 | grep -i "$pattern" | tail -20 | while IFS= read -r line; do
                        printf "${GREEN}%s${RESET}\n" "$line"
                    done
                elif [ -n "$HISTFILE" ] && [ -f "$HISTFILE" ]; then
                    grep -i "$pattern" "$HISTFILE" | tail -20 | while IFS= read -r line; do
                        printf "${GREEN}%s${RESET}\n" "$line"
                    done
                else
                    printf "${YELLOW}⚠️  Historique non disponible${RESET}\n"
                fi
                ;;
            2)
                printf "\n${CYAN}Résultats des dernières 24h pour '$pattern':${RESET}\n"
                if [ "$SHELL_TYPE" = "zsh" ] && command -v fc >/dev/null 2>&1; then
                    yesterday=$(date -d "yesterday" +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d 2>/dev/null || echo "")
                    today=$(date +%Y-%m-%d)
                    fc -l 1 | grep -i "$pattern" | grep -E "$today|$yesterday" | tail -20
                elif [ -n "$HISTFILE" ] && [ -f "$HISTFILE" ]; then
                    grep -i "$pattern" "$HISTFILE" | tail -20
                else
                    printf "${YELLOW}⚠️  Historique non disponible${RESET}\n"
                fi
                ;;
            3)
                printf "\n${CYAN}Commandes contenant '$pattern':${RESET}\n"
                if [ "$SHELL_TYPE" = "zsh" ] && command -v fc >/dev/null 2>&1; then
                    fc -l 1 | grep -i "$pattern" | awk '{for(i=2;i<=NF;i++) printf "%s ", $i; print ""}' | sort | uniq -c | sort -rn | head -10
                elif [ -n "$HISTFILE" ] && [ -f "$HISTFILE" ]; then
                    grep -i "$pattern" "$HISTFILE" | awk '{for(i=2;i<=NF;i++) printf "%s ", $i; print ""}' | sort | uniq -c | sort -rn | head -10
                else
                    printf "${YELLOW}⚠️  Historique non disponible${RESET}\n"
                fi
                ;;
            4)
                printf "\n${CYAN}Recherche avec contexte pour '$pattern':${RESET}\n"
                if [ "$SHELL_TYPE" = "zsh" ] && command -v fc >/dev/null 2>&1; then
                    fc -l 1 | grep -n -i "$pattern" | head -20 | while IFS=: read -r line_num content; do
                        printf "${GREEN}Ligne $line_num:${RESET} $content\n"
                    done
                elif [ -n "$HISTFILE" ] && [ -f "$HISTFILE" ]; then
                    grep -n -i "$pattern" "$HISTFILE" | head -20 | while IFS=: read -r line_num content; do
                        printf "${GREEN}Ligne $line_num:${RESET} $content\n"
                    done
                else
                    printf "${YELLOW}⚠️  Historique non disponible${RESET}\n"
                fi
                ;;
        esac
        
        echo
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Recherche de fichiers avec critères multiples
    # DESC: Recherche avancée dans les fichiers avec options
    # USAGE: search_files_advanced
    search_files_advanced() {
        show_header
        printf "${YELLOW}📁 Recherche avancée de fichiers${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        printf "Répertoire de recherche (défaut: %s): " "$PWD"
        read search_dir
        search_dir="${search_dir:-$PWD}"
        
        if [ ! -d "$search_dir" ]; then
            printf "${RED}❌ Répertoire inexistant${RESET}\n"
            sleep 2
            return
        fi
        
        printf "\n${CYAN}Type de recherche:${RESET}\n"
        echo "  1. Par nom de fichier"
        echo "  2. Par contenu"
        echo "  3. Par extension"
        echo "  4. Par taille"
        echo "  5. Par date de modification"
        echo "  6. Recherche combinée"
        echo
        printf "Type [1-6]: "
        read search_type
        
        case "$search_type" in
            1)
                printf "Nom du fichier (avec wildcards): "
                read filename
                printf "\n${CYAN}Fichiers trouvés:${RESET}\n"
                find "$search_dir" -name "*$filename*" -type f 2>/dev/null | head -20 | while IFS= read -r file; do
                    size=$(du -h "$file" 2>/dev/null | cut -f1)
                    date=$(stat -c %y "$file" 2>/dev/null | cut -d' ' -f1 || stat -f "%Sm" -t "%Y-%m-%d" "$file" 2>/dev/null || echo "N/A")
                    printf "${GREEN}%-50s${RESET} ${BLUE}%8s${RESET} ${YELLOW}%s${RESET}\n" "$(basename "$file")" "$size" "$date"
                    echo "  $file"
                done
                ;;
            2)
                printf "Contenu à rechercher: "
                read content
                printf "\n${CYAN}Fichiers contenant '$content':${RESET}\n"
                grep -r -l "$content" "$search_dir" 2>/dev/null | head -20 | while IFS= read -r file; do
                    printf "${GREEN}%s${RESET}\n" "$file"
                    grep -n "$content" "$file" 2>/dev/null | head -2 | while IFS= read -r match; do
                        printf "  ${YELLOW}%s${RESET}\n" "$match"
                    done
                done
                ;;
            3)
                printf "Extension (sans le point): "
                read extension
                printf "\n${CYAN}Fichiers .$extension trouvés:${RESET}\n"
                find "$search_dir" -name "*.$extension" -type f 2>/dev/null | head -20 | while IFS= read -r file; do
                    size=$(du -h "$file" 2>/dev/null | cut -f1)
                    printf "${GREEN}%-50s${RESET} ${BLUE}%8s${RESET}\n" "$(basename "$file")" "$size"
                done
                ;;
            4)
                echo "Taille: +100M (plus de 100MB), -1M (moins de 1MB), etc."
                printf "Critère de taille: "
                read size
                printf "\n${CYAN}Fichiers correspondant à '$size':${RESET}\n"
                find "$search_dir" -size "$size" -type f 2>/dev/null | head -20 | while IFS= read -r file; do
                    filesize=$(du -h "$file" 2>/dev/null | cut -f1)
                    printf "${GREEN}%-50s${RESET} ${BLUE}%8s${RESET}\n" "$(basename "$file")" "$filesize"
                done
                ;;
            5)
                echo "Exemples: -1 (dernier jour), -7 (dernière semaine), +30 (plus de 30 jours)"
                printf "Jours depuis modification: "
                read days
                printf "\n${CYAN}Fichiers modifiés il y a $days jours:${RESET}\n"
                find "$search_dir" -mtime "$days" -type f 2>/dev/null | head -20 | while IFS= read -r file; do
                    date=$(stat -c %y "$file" 2>/dev/null | cut -d' ' -f1 || stat -f "%Sm" -t "%Y-%m-%d" "$file" 2>/dev/null || echo "N/A")
                    printf "${GREEN}%-50s${RESET} ${YELLOW}%s${RESET}\n" "$(basename "$file")" "$date"
                done
                ;;
            6)
                printf "Nom (optionnel): "
                read name
                printf "Extension (optionnel): "
                read ext
                printf "Contenu (optionnel): "
                read content
                
                printf "\n${CYAN}Recherche combinée:${RESET}\n"
                find "$search_dir" -type f \
                    ${name:+-name "*$name*"} \
                    ${ext:+-name "*.$ext"} \
                    2>/dev/null | while IFS= read -r file; do
                    if [ -n "$content" ]; then
                        if grep -q "$content" "$file" 2>/dev/null; then
                            printf "${GREEN}%s${RESET}\n" "$file"
                        fi
                    else
                        printf "${GREEN}%s${RESET}\n" "$file"
                    fi
                done | head -20
                ;;
        esac
        
        echo
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Recherche de processus
    # DESC: Recherche et gestion de processus
    # USAGE: search_processes
    search_processes() {
        show_header
        printf "${YELLOW}⚙️ Recherche de processus${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        printf "Nom du processus à rechercher: "
        read process_name
        
        if [ -z "$process_name" ]; then
            printf "${RED}❌ Nom de processus requis${RESET}\n"
            sleep 2
            return
        fi
        
        printf "\n${CYAN}Processus trouvés:${RESET}\n"
        ps aux 2>/dev/null | grep -i "$process_name" | grep -v grep | head -20 | while IFS= read -r line; do
            printf "${GREEN}%s${RESET}\n" "$line"
        done
        
        echo
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Recherche dans les logs
    # DESC: Recherche dans les fichiers de log
    # USAGE: search_logs
    search_logs() {
        show_header
        printf "${YELLOW}📜 Recherche dans les logs${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        printf "Terme à rechercher: "
        read search_term
        
        if [ -z "$search_term" ]; then
            printf "${RED}❌ Terme de recherche requis${RESET}\n"
            sleep 2
            return
        fi
        
        printf "\n${CYAN}Type de recherche:${RESET}\n"
        echo "  1. Logs système (/var/log)"
        echo "  2. Logs utilisateur (~/.local/share)"
        echo "  3. Logs application spécifique"
        echo "  4. Recherche récursive dans répertoire"
        echo "  5. Fichier de log spécifique"
        echo
        printf "Type [1-5]: "
        read log_type
        
        case "$log_type" in
            1)
                printf "\n${CYAN}Recherche dans /var/log:${RESET}\n"
                find /var/log -type f -name "*.log" 2>/dev/null | head -10 | while IFS= read -r log_file; do
                    if grep -q -i "$search_term" "$log_file" 2>/dev/null; then
                        printf "${GREEN}%s${RESET}\n" "$log_file"
                        grep -i "$search_term" "$log_file" 2>/dev/null | tail -5
                        echo
                    fi
                done
                ;;
            2)
                printf "\n${CYAN}Recherche dans ~/.local/share:${RESET}\n"
                find "$HOME/.local/share" -type f -name "*.log" 2>/dev/null | head -10 | while IFS= read -r log_file; do
                    if grep -q -i "$search_term" "$log_file" 2>/dev/null; then
                        printf "${GREEN}%s${RESET}\n" "$log_file"
                        grep -i "$search_term" "$log_file" 2>/dev/null | tail -5
                        echo
                    fi
                done
                ;;
            3)
                printf "Nom de l'application: "
                read app_name
                printf "\n${CYAN}Recherche dans logs $app_name:${RESET}\n"
                find "$HOME" -type f -name "*$app_name*.log" 2>/dev/null | head -10 | while IFS= read -r log_file; do
                    if grep -q -i "$search_term" "$log_file" 2>/dev/null; then
                        printf "${GREEN}%s${RESET}\n" "$log_file"
                        grep -i "$search_term" "$log_file" 2>/dev/null | tail -5
                        echo
                    fi
                done
                ;;
            4)
                printf "Répertoire de recherche: "
                read log_dir
                if [ -d "$log_dir" ]; then
                    printf "\n${CYAN}Recherche récursive dans $log_dir:${RESET}\n"
                    find "$log_dir" -type f -name "*.log" 2>/dev/null | head -10 | while IFS= read -r log_file; do
                        if grep -q -i "$search_term" "$log_file" 2>/dev/null; then
                            printf "${GREEN}%s${RESET}\n" "$log_file"
                            grep -i "$search_term" "$log_file" 2>/dev/null | tail -5
                            echo
                        fi
                    done
                else
                    printf "${RED}❌ Répertoire inexistant${RESET}\n"
                fi
                ;;
            5)
                printf "Chemin du fichier de log: "
                read log_file
                if [ -f "$log_file" ]; then
                    printf "\n${CYAN}Recherche dans $log_file:${RESET}\n"
                    grep -i "$search_term" "$log_file" | tail -20
                else
                    printf "${RED}❌ Fichier de log inexistant${RESET}\n"
                fi
                ;;
        esac
        
        echo
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Recherche de fonctions et commandes (adapté selon shell)
    # DESC: Recherche dans les fonctions définies
    # USAGE: search_zsh_functions
    search_functions() {
        show_header
        printf "${YELLOW}🔧 Recherche de fonctions${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        printf "\n${CYAN}Type de recherche:${RESET}\n"
        echo "  1. Fonctions chargées"
        echo "  2. Alias définis"
        echo "  3. Variables d'environnement"
        echo "  4. Commandes disponibles"
        echo
        printf "Type [1-4]: "
        read search_type
        
        printf "Motif de recherche: "
        read pattern
        
        case "$search_type" in
            1)
                if [ "$SHELL_TYPE" = "zsh" ]; then
                    typeset -f | grep -i "$pattern" | head -20
                elif [ "$SHELL_TYPE" = "bash" ]; then
                    declare -f | grep -i "$pattern" | head -20
                else
                    printf "${YELLOW}⚠️  Fonctions non disponibles dans ce shell${RESET}\n"
                fi
                ;;
            2)
                if [ "$SHELL_TYPE" = "zsh" ]; then
                    alias | grep -i "$pattern" | head -20
                elif [ "$SHELL_TYPE" = "bash" ]; then
                    alias | grep -i "$pattern" | head -20
                else
                    printf "${YELLOW}⚠️  Alias non disponibles dans ce shell${RESET}\n"
                fi
                ;;
            3)
                env | grep -i "$pattern" | head -20
                ;;
            4)
                printf "${CYAN}Commandes disponibles contenant '$pattern':${RESET}\n"
                compgen -c 2>/dev/null | grep -i "$pattern" | head -20 | while IFS= read -r cmd; do
                    printf "${GREEN}%s${RESET}\n" "$cmd"
                done
                ;;
        esac
        
        echo
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Statistiques de recherche
    # DESC: Affiche des statistiques sur les recherches
    # USAGE: search_statistics
    search_statistics() {
        show_header
        printf "${YELLOW}📊 Statistiques de recherche${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        printf "\n${CYAN}Statistiques du répertoire courant:${RESET}\n"
        total_files=$(find . -type f 2>/dev/null | wc -l | tr -d ' ')
        total_dirs=$(find . -type d 2>/dev/null | wc -l | tr -d ' ')
        echo "  Fichiers: $total_files"
        echo "  Dossiers: $total_dirs"
        
        printf "\n${CYAN}Extensions les plus courantes:${RESET}\n"
        find . -type f -name "*.*" 2>/dev/null | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -10 | while IFS= read -r line; do
            count=$(echo "$line" | awk '{print $1}')
            ext=$(echo "$line" | awk '{print $2}')
            printf "  ${GREEN}%3d${RESET} × ${BLUE}.%s${RESET}\n" "$count" "$ext"
        done
        
        printf "\n${CYAN}Processus actifs:${RESET}\n"
        total_processes=$(ps aux 2>/dev/null | wc -l | tr -d ' ')
        echo "  Total de processus: $total_processes"
        
        printf "\n${CYAN}Utilisateurs connectés:${RESET}\n"
        who 2>/dev/null | while IFS= read -r line; do
            printf "  %s\n" "$line"
        done
        
        echo
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Gestion des arguments rapides
    if [ -n "$1" ]; then
        _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
        [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ] && . "$_logdf/scripts/lib/managers_log_posix.sh" && managers_cli_log searchman "$@"
    fi
    case "$1" in
        history)
            if [ -n "$2" ]; then
                search_history_advanced
            else
                search_history_advanced
            fi
            return 0
            ;;
        files)
            search_files_advanced
            return 0
            ;;
        process)
            search_processes
            return 0
            ;;
        logs)
            search_logs
            return 0
            ;;
        functions)
            search_functions
            return 0
            ;;
        stats)
            search_statistics
            return 0
            ;;
    esac
    
    # Menu principal
    while true; do
        show_header
        printf "${GREEN}Menu Principal${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo
        echo "  ${BOLD}1${RESET}  🔍 Recherche avancée dans l'historique"
        echo "  ${BOLD}2${RESET}  📁 Recherche avancée de fichiers"
        echo "  ${BOLD}3${RESET}  ⚙️ Recherche de processus"
        echo "  ${BOLD}4${RESET}  📜 Recherche dans les logs"
        echo "  ${BOLD}5${RESET}  🔧 Recherche de fonctions"
        echo "  ${BOLD}6${RESET}  📊 Statistiques de recherche"
        echo
        echo "  ${BOLD}h${RESET}  📚 Aide"
        echo "  ${BOLD}q${RESET}  🚪 Quitter"
        echo
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        printf "Votre choix: "
        read choice
        
        case "$choice" in
            1) search_history_advanced ;;
            2) search_files_advanced ;;
            3) search_processes ;;
            4) search_logs ;;
            5) search_functions ;;
            6) search_statistics ;;
            h|H)
                show_header
                printf "${CYAN}📚 Aide - SEARCHMAN${RESET}\n"
                printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
                echo
                echo "SEARCHMAN est un gestionnaire de recherche complet."
                echo
                echo "Fonctionnalités:"
                echo "  • Recherche avancée dans l'historique avec contexte"
                echo "  • Recherche de fichiers multi-critères"
                echo "  • Gestion et monitoring des processus"
                echo "  • Exploration des logs système"
                echo "  • Recherche dans les fonctions et alias"
                echo "  • Statistiques d'utilisation détaillées"
                echo
                echo "Raccourcis:"
                echo "  searchman                  - Lance le gestionnaire"
                echo "  searchman history <terme>  - Recherche dans l'historique"
                echo "  searchman files <motif>    - Recherche de fichiers"
                echo "  searchman process <nom>     - Recherche de processus"
                echo
                printf "Appuyez sur Entrée pour continuer... "
                read dummy
                ;;
            q|Q)
                printf "${GREEN}Au revoir!${RESET}\n"
                break
                ;;
            *)
                printf "${RED}Option invalide${RESET}\n"
                sleep 1
                ;;
        esac
    done
}
