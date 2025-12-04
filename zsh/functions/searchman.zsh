#!/bin/zsh
# =============================================================================
# SEARCHMAN - Search Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet de recherche et exploration
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Gestionnaire interactif complet pour la recherche et l'exploration. Permet de rechercher dans l'historique, les fichiers, le code source, et d'explorer le système de fichiers avec des filtres avancés.
# USAGE: searchman [command]
# EXAMPLE: searchman
# EXAMPLE: searchman history git
# EXAMPLE: searchman files "*.py"
searchman() {
    # Configuration des couleurs
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
        echo "║                   SEARCHMAN - Search Manager                   ║"
        echo "║               Gestionnaire de Recherche ZSH                   ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo
    }
    
    # Recherche dans l'historique ZSH avec filtres avancés
    # DESC: Recherche avancée dans l'historique ZSH avec filtres
    # USAGE: search_history_advanced
    # EXAMPLE: search_history_advanced
    search_history_advanced() {
        show_header
        echo -e "${YELLOW}🔍 Recherche avancée dans l'historique${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        read "pattern?Terme à rechercher: "
        if [[ -z "$pattern" ]]; then
            echo -e "${RED}❌ Terme de recherche requis${RESET}"
            sleep 2
            return
        fi
        
        echo -e "\n${CYAN}Options de recherche:${RESET}"
        echo "  1. Recherche simple"
        echo "  2. Recherche par date (dernières 24h)"
        echo "  3. Recherche par commande spécifique"
        echo "  4. Recherche avec contexte"
        echo
        read -k 1 "search_type?Type de recherche [1-4]: "
        echo
        
        case "$search_type" in
            1)
                echo -e "\n${CYAN}Résultats pour '$pattern':${RESET}"
                fc -l 1 | grep -i "$pattern" | tail -20 | while read num date time cmd; do
                    printf "${GREEN}%5s${RESET} ${BLUE}%s %s${RESET} %s\n" "$num" "$date" "$time" "$cmd"
                done
                ;;
            2)
                echo -e "\n${CYAN}Résultats des dernières 24h pour '$pattern':${RESET}"
                local yesterday=$(date -d "yesterday" +%Y-%m-%d)
                fc -l 1 | grep -i "$pattern" | grep -E "$(date +%Y-%m-%d)|$yesterday" | tail -20
                ;;
            3)
                echo -e "\n${CYAN}Commandes contenant '$pattern':${RESET}"
                history | grep -i "$pattern" | awk '{$1=""; print $0}' | sort | uniq -c | sort -rn | head -10
                ;;
            4)
                echo -e "\n${CYAN}Recherche avec contexte pour '$pattern':${RESET}"
                local results=$(fc -l 1 | grep -n -i "$pattern")
                echo "$results" | while IFS=: read line_num content; do
                    echo -e "${GREEN}Ligne $line_num:${RESET} $content"
                    # Afficher contexte (ligne précédente et suivante)
                    local prev=$((line_num - 1))
                    local next=$((line_num + 1))
                    if [[ $prev -gt 0 ]]; then
                        local prev_cmd=$(fc -l 1 | sed -n "${prev}p")
                        echo -e "  ${YELLOW}Avant:${RESET} $prev_cmd"
                    fi
                    if fc -l 1 | sed -n "${next}p" &>/dev/null; then
                        local next_cmd=$(fc -l 1 | sed -n "${next}p")
                        echo -e "  ${YELLOW}Après:${RESET} $next_cmd"
                    fi
                    echo
                done | head -20
                ;;
        esac
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Recherche de fichiers avec critères multiples
    # DESC: Recherche avancée dans les fichiers avec options
    # USAGE: search_files_advanced
    # EXAMPLE: search_files_advanced
    search_files_advanced() {
        show_header
        echo -e "${YELLOW}📁 Recherche avancée de fichiers${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        read "search_dir?Répertoire de recherche (défaut: $PWD): "
        search_dir="${search_dir:-$PWD}"
        
        if [[ ! -d "$search_dir" ]]; then
            echo -e "${RED}❌ Répertoire inexistant${RESET}"
            sleep 2
            return
        fi
        
        echo -e "\n${CYAN}Type de recherche:${RESET}"
        echo "  1. Par nom de fichier"
        echo "  2. Par contenu"
        echo "  3. Par extension"
        echo "  4. Par taille"
        echo "  5. Par date de modification"
        echo "  6. Recherche combinée"
        echo
        read -k 1 "search_type?Type [1-6]: "
        echo
        
        case "$search_type" in
            1)
                read "filename?Nom du fichier (avec wildcards): "
                echo -e "\n${CYAN}Fichiers trouvés:${RESET}"
                find "$search_dir" -name "*$filename*" -type f 2>/dev/null | head -20 | while read file; do
                    local size=$(du -h "$file" 2>/dev/null | cut -f1)
                    local date=$(stat -c %y "$file" 2>/dev/null | cut -d' ' -f1)
                    printf "${GREEN}%-50s${RESET} ${BLUE}%8s${RESET} ${YELLOW}%s${RESET}\n" "$(basename "$file")" "$size" "$date"
                    echo "  $file"
                done
                ;;
            2)
                read "content?Contenu à rechercher: "
                echo -e "\n${CYAN}Fichiers contenant '$content':${RESET}"
                grep -r -l "$content" "$search_dir" 2>/dev/null | head -20 | while read file; do
                    echo -e "${GREEN}$file${RESET}"
                    grep -n "$content" "$file" | head -2 | while read match; do
                        echo -e "  ${YELLOW}$match${RESET}"
                    done
                done
                ;;
            3)
                read "extension?Extension (sans le point): "
                echo -e "\n${CYAN}Fichiers .$extension trouvés:${RESET}"
                find "$search_dir" -name "*.$extension" -type f 2>/dev/null | head -20 | while read file; do
                    local size=$(du -h "$file" 2>/dev/null | cut -f1)
                    printf "${GREEN}%-50s${RESET} ${BLUE}%8s${RESET}\n" "$(basename "$file")" "$size"
                done
                ;;
            4)
                echo "Taille: +100M (plus de 100MB), -1M (moins de 1MB), etc."
                read "size?Critère de taille: "
                echo -e "\n${CYAN}Fichiers correspondant à '$size':${RESET}"
                find "$search_dir" -size "$size" -type f 2>/dev/null | head -20 | while read file; do
                    local filesize=$(du -h "$file" 2>/dev/null | cut -f1)
                    printf "${GREEN}%-50s${RESET} ${BLUE}%8s${RESET}\n" "$(basename "$file")" "$filesize"
                done
                ;;
            5)
                echo "Exemples: -1 (dernier jour), -7 (dernière semaine), +30 (plus de 30 jours)"
                read "days?Jours depuis modification: "
                echo -e "\n${CYAN}Fichiers modifiés il y a $days jours:${RESET}"
                find "$search_dir" -mtime "$days" -type f 2>/dev/null | head -20 | while read file; do
                    local date=$(stat -c %y "$file" 2>/dev/null | cut -d' ' -f1)
                    printf "${GREEN}%-50s${RESET} ${YELLOW}%s${RESET}\n" "$(basename "$file")" "$date"
                done
                ;;
            6)
                read "name?Nom (optionnel): "
                read "ext?Extension (optionnel): "
                read "content?Contenu (optionnel): "
                
                local find_cmd="find \"$search_dir\" -type f"
                [[ -n "$name" ]] && find_cmd="$find_cmd -name \"*$name*\""
                [[ -n "$ext" ]] && find_cmd="$find_cmd -name \"*.$ext\""
                
                echo -e "\n${CYAN}Recherche combinée:${RESET}"
                eval "$find_cmd" 2>/dev/null | while read file; do
                    if [[ -n "$content" ]]; then
                        if grep -q "$content" "$file" 2>/dev/null; then
                            echo -e "${GREEN}$file${RESET}"
                        fi
                    else
                        echo -e "${GREEN}$file${RESET}"
                    fi
                done | head -20
                ;;
        esac
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Recherche de processus
    # DESC: Recherche dans les processus en cours d'exécution
    # USAGE: search_processes
    # EXAMPLE: search_processes
    search_processes() {
        show_header
        echo -e "${YELLOW}⚙️ Recherche de processus${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        read "process_name?Nom du processus à rechercher: "
        if [[ -z "$process_name" ]]; then
            echo -e "${RED}❌ Nom de processus requis${RESET}"
            sleep 2
            return
        fi
        
        echo -e "\n${CYAN}Processus correspondant à '$process_name':${RESET}"
        printf "${BOLD}%-8s %-8s %-8s %-8s %-50s${RESET}\n" "PID" "PPID" "CPU%" "MEM%" "COMMANDE"
        echo "────────────────────────────────────────────────────────────────────────────────"
        
        ps aux | grep -i "$process_name" | grep -v grep | while read user pid ppid cpu mem vsz rss tty stat start time cmd; do
            printf "${GREEN}%-8s${RESET} ${BLUE}%-8s${RESET} ${YELLOW}%-8s${RESET} ${MAGENTA}%-8s${RESET} ${CYAN}%-50.50s${RESET}\n" \
                   "$pid" "$ppid" "$cpu" "$mem" "$cmd"
        done
        
        echo -e "\n${CYAN}Actions disponibles:${RESET}"
        echo "  k) Tuer un processus"
        echo "  i) Informations détaillées"
        echo "  t) Top des processus similaires"
        echo "  q) Retour"
        echo
        read -k 1 "action?Action [k/i/t/q]: "
        echo
        
        case "$action" in
            k|K)
                read "pid?PID du processus à tuer: "
                if [[ "$pid" =~ ^[0-9]+$ ]]; then
                    read -k 1 "confirm?Confirmer la terminaison du PID $pid? [y/N]: "
                    echo
                    if [[ "$confirm" =~ ^[Yy]$ ]]; then
                        kill "$pid" 2>/dev/null && echo -e "${GREEN}✅ Processus $pid terminé${RESET}" || echo -e "${RED}❌ Erreur${RESET}"
                    fi
                fi
                ;;
            i|I)
                read "pid?PID pour infos détaillées: "
                if [[ "$pid" =~ ^[0-9]+$ ]]; then
                    echo -e "\n${CYAN}Informations détaillées pour PID $pid:${RESET}"
                    ps -p "$pid" -o pid,ppid,user,cpu,mem,vsz,rss,tty,stat,start,time,cmd 2>/dev/null
                fi
                ;;
            t|T)
                echo -e "\n${CYAN}Top des processus contenant '$process_name':${RESET}"
                ps aux | grep -i "$process_name" | grep -v grep | sort -k3 -rn | head -10
                ;;
        esac
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Recherche dans les logs système
    # DESC: Recherche dans différents types de logs système (journal, auth, kernel, applications, personnalisés)
    # USAGE: search_logs
    # EXAMPLE: search_logs
    search_logs() {
        show_header
        echo -e "${YELLOW}📜 Recherche dans les logs${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        echo -e "\n${CYAN}Sources de logs disponibles:${RESET}"
        echo "  1. Journal système (journalctl)"
        echo "  2. Logs d'authentification"
        echo "  3. Logs du kernel"
        echo "  4. Logs d'applications"
        echo "  5. Logs personnalisés"
        echo
        read -k 1 "log_type?Type de log [1-5]: "
        echo
        
        read "search_term?Terme à rechercher: "
        read "time_range?Période (1h, 1d, 1w) [défaut: 1d]: "
        time_range="${time_range:-1d}"
        
        case "$log_type" in
            1)
                echo -e "\n${CYAN}Journal système:${RESET}"
                if command -v journalctl &> /dev/null; then
                    journalctl --since="$time_range ago" | grep -i "$search_term" | tail -20
                else
                    echo -e "${RED}❌ journalctl non disponible${RESET}"
                fi
                ;;
            2)
                echo -e "\n${CYAN}Logs d'authentification:${RESET}"
                sudo grep -i "$search_term" /var/log/auth.log /var/log/secure 2>/dev/null | tail -20
                ;;
            3)
                echo -e "\n${CYAN}Logs du kernel:${RESET}"
                dmesg | grep -i "$search_term" | tail -20
                ;;
            4)
                echo -e "\n${CYAN}Logs d'applications:${RESET}"
                sudo find /var/log -name "*.log" -exec grep -l "$search_term" {} \; 2>/dev/null | head -5 | while read logfile; do
                    echo -e "${GREEN}$logfile:${RESET}"
                    sudo grep -i "$search_term" "$logfile" | tail -3
                    echo
                done
                ;;
            5)
                read "log_file?Chemin du fichier de log: "
                if [[ -f "$log_file" ]]; then
                    echo -e "\n${CYAN}Recherche dans $log_file:${RESET}"
                    grep -i "$search_term" "$log_file" | tail -20
                else
                    echo -e "${RED}❌ Fichier de log inexistant${RESET}"
                fi
                ;;
        esac
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Recherche de fonctions et commandes ZSH
    # DESC: Recherche dans les fonctions ZSH définies
    # USAGE: search_zsh_functions
    # EXAMPLE: search_zsh_functions
    search_zsh_functions() {
        show_header
        echo -e "${YELLOW}🔧 Recherche de fonctions ZSH${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        echo -e "\n${CYAN}Type de recherche:${RESET}"
        echo "  1. Fonctions chargées"
        echo "  2. Alias définis"
        echo "  3. Variables d'environnement"
        echo "  4. Commandes disponibles"
        echo "  5. Historique des fonctions"
        echo
        read -k 1 "search_type?Type [1-5]: "
        echo
        
        read "pattern?Motif de recherche: "
        
        case "$search_type" in
            1)
                echo -e "\n${CYAN}Fonctions chargées contenant '$pattern':${RESET}"
                typeset -f | grep -B1 -A5 -i "$pattern" | head -30
                ;;
            2)
                echo -e "\n${CYAN}Alias contenant '$pattern':${RESET}"
                alias | grep -i "$pattern" | while read line; do
                    echo -e "${GREEN}$line${RESET}"
                done
                ;;
            3)
                echo -e "\n${CYAN}Variables d'environnement contenant '$pattern':${RESET}"
                env | grep -i "$pattern" | while read line; do
                    local var=$(echo "$line" | cut -d= -f1)
                    local val=$(echo "$line" | cut -d= -f2-)
                    printf "${GREEN}%-30s${RESET} = ${BLUE}%s${RESET}\n" "$var" "$val"
                done
                ;;
            4)
                echo -e "\n${CYAN}Commandes disponibles contenant '$pattern':${RESET}"
                compgen -c | grep -i "$pattern" | head -20 | while read cmd; do
                    if command -v "$cmd" &>/dev/null; then
                        local location=$(which "$cmd" 2>/dev/null)
                        printf "${GREEN}%-20s${RESET} ${BLUE}%s${RESET}\n" "$cmd" "$location"
                    fi
                done
                ;;
            5)
                echo -e "\n${CYAN}Historique des fonctions contenant '$pattern':${RESET}"
                fc -l 1 | grep -E "(function|^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*\(\))" | grep -i "$pattern" | tail -10
                ;;
        esac
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Statistiques de recherche
    # DESC: Affiche des statistiques détaillées sur l'historique, fichiers, processus et utilisateurs
    # USAGE: search_statistics
    # EXAMPLE: search_statistics
    search_statistics() {
        show_header
        echo -e "${YELLOW}📊 Statistiques de recherche${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        echo -e "\n${CYAN}Historique ZSH:${RESET}"
        local total_commands=$(fc -l 1 | wc -l)
        echo "  Total de commandes: $total_commands"
        
        echo -e "\n${CYAN}Top 10 des commandes les plus utilisées:${RESET}"
        history | awk '{print $2}' | sort | uniq -c | sort -rn | head -10 | while read count cmd; do
            printf "  ${GREEN}%3d${RESET} × ${BLUE}%s${RESET}\n" "$count" "$cmd"
        done
        
        echo -e "\n${CYAN}Fichiers dans le répertoire courant:${RESET}"
        local total_files=$(find . -type f 2>/dev/null | wc -l)
        local total_dirs=$(find . -type d 2>/dev/null | wc -l)
        echo "  Fichiers: $total_files"
        echo "  Dossiers: $total_dirs"
        
        echo -e "\n${CYAN}Extensions les plus courantes:${RESET}"
        find . -type f -name "*.*" 2>/dev/null | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -10 | while read count ext; do
            printf "  ${GREEN}%3d${RESET} × ${BLUE}.%s${RESET}\n" "$count" "$ext"
        done
        
        echo -e "\n${CYAN}Processus actifs:${RESET}"
        local total_processes=$(ps aux | wc -l)
        echo "  Total de processus: $total_processes"
        
        echo -e "\n${CYAN}Utilisateurs connectés:${RESET}"
        who | while read user tty date time; do
            echo "  $user ($tty) depuis $date $time"
        done
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Menu principal
    while true; do
        show_header
        echo -e "${GREEN}Menu Principal${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo
        echo "  ${BOLD}1${RESET}  🔍 Recherche avancée dans l'historique"
        echo "  ${BOLD}2${RESET}  📁 Recherche avancée de fichiers"
        echo "  ${BOLD}3${RESET}  ⚙️ Recherche de processus"
        echo "  ${BOLD}4${RESET}  📜 Recherche dans les logs"
        echo "  ${BOLD}5${RESET}  🔧 Recherche de fonctions ZSH"
        echo "  ${BOLD}6${RESET}  📊 Statistiques de recherche"
        echo
        echo "  ${BOLD}h${RESET}  📚 Aide"
        echo "  ${BOLD}q${RESET}  🚪 Quitter"
        echo
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        read -k 1 "choice?Votre choix: "
        echo
        
        case "$choice" in
            1) search_history_advanced ;;
            2) search_files_advanced ;;
            3) search_processes ;;
            4) search_logs ;;
            5) search_zsh_functions ;;
            6) search_statistics ;;
            h|H)
                show_header
                echo -e "${CYAN}📚 Aide - SEARCHMAN${RESET}"
                echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
                echo
                echo "SEARCHMAN est un gestionnaire de recherche complet pour ZSH."
                echo
                echo "Fonctionnalités:"
                echo "  • Recherche avancée dans l'historique avec contexte"
                echo "  • Recherche de fichiers multi-critères"
                echo "  • Gestion et monitoring des processus"
                echo "  • Exploration des logs système"
                echo "  • Recherche dans les fonctions et alias ZSH"
                echo "  • Statistiques d'utilisation détaillées"
                echo
                echo "Raccourcis:"
                echo "  searchman                  - Lance le gestionnaire"
                echo "  searchman history <terme>  - Recherche dans l'historique"
                echo "  searchman files <motif>    - Recherche de fichiers"
                echo "  searchman process <nom>    - Recherche de processus"
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            q|Q)
                echo -e "${GREEN}Au revoir!${RESET}"
                break
                ;;
            *)
                echo -e "${RED}Option invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

# Alias et raccourcis
alias sm='searchman'
alias search-manager='searchman'

# Accès direct aux fonctions
if [[ "$1" == "history" && -n "$2" ]]; then
    echo "🔍 Recherche dans l'historique: $2"
    fc -l 1 | grep -i "$2" | tail -10
elif [[ "$1" == "files" && -n "$2" ]]; then
    echo "📁 Recherche de fichiers: $2"
    find . -name "*$2*" -type f 2>/dev/null | head -10
elif [[ "$1" == "process" && -n "$2" ]]; then
    echo "⚙️ Recherche de processus: $2"
    ps aux | grep -i "$2" | grep -v grep
fi

# Message d'initialisation - désactivé pour éviter l'avertissement Powerlevel10k
# echo "🔍 SEARCHMAN chargé - Tapez 'searchman' ou 'sm' pour démarrer"
